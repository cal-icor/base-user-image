FROM us-central1-docker.pkg.dev/cal-icor-hubs/user-images/base-python-image:aa924984d219 AS base

USER root
# Set up common env variables
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV NB_USER=jovyan
ENV NB_UID=1000
ENV SHELL=/bin/bash

# These are used by the python, R, and final stages
ENV REPO_DIR=/srv/repo
ENV CONDA_DIR=/srv/conda
ENV R_LIBS_USER=/srv/r
ENV OBITOOLS_DIR=/srv/obitools

# capture default path so we can set the path succinctly later
ENV DEFAULT_PATH=${PATH}

# needed for webpdf notebook exports in the jovyan's environment
ENV PLAYWRIGHT_BROWSERS_PATH=${CONDA_DIR}

RUN apt-get -qq update --yes && \
    apt-get -qq install --yes locales && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Install all apt packages
COPY apt.txt /tmp/apt.txt
RUN apt-get -qq update --yes && \
    apt-get -qq install --yes --no-install-recommends \
        $(grep -v ^# /tmp/apt.txt) && \
    apt-get -qq purge && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/*

# Stop the annoying sudo hint from showing up in the terminal
COPY bash.bashrc /etc/bash.bashrc

# These apt packages must be installed into the base stage since they are in
# system paths rather than /srv.
#
# Pre-built R packages from Posit Package Manager are built against system libs
# in jammy.
#
# After updating R_VERSION and rstudio-server, update Rprofile.site too.
ENV R_VERSION=4.5.1-1.2404.0
ENV LITTLER_VERSION=0.3.21-2.2404.0
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" > /etc/apt/sources.list.d/cran.list
RUN curl --silent --location --fail https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc > /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN apt-get update --yes > /dev/null && \
    apt-get install --yes -qq r-base-core=${R_VERSION} r-base-dev=${R_VERSION} littler=${LITTLER_VERSION} r-cran-littler=${LITTLER_VERSION} > /dev/null

# RStudio Server and Quarto
ENV RSTUDIO_URL=https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2025.09.1-401-amd64.deb
RUN curl --silent --location --fail ${RSTUDIO_URL} > /tmp/rstudio.deb && \
    apt install --no-install-recommends --yes /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb

# For command-line access to quarto, which is installed by rstudio.
RUN ln -s /usr/lib/rstudio-server/bin/quarto/bin/quarto /usr/local/bin/quarto

# Shiny Server
ENV SHINY_SERVER_URL=https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.22.1017-amd64.deb
RUN curl --silent --location --fail ${SHINY_SERVER_URL} > /tmp/shiny-server.deb && \
    apt install --no-install-recommends --yes /tmp/shiny-server.deb && \
    rm /tmp/shiny-server.deb

# R_LIBS_USER is set by default in /etc/R/Renviron, which RStudio loads.
# We uncomment the default, and set what we wanna - so it picks up
# the packages we install. Without this, RStudio doesn't see the packages
# that R does.
# Stolen from https://github.com/jupyterhub/repo2docker/blob/6a07a48b2df48168685bb0f993d2a12bd86e23bf/repo2docker/buildpacks/r.py
# To try fight https://community.rstudio.com/t/timedatectl-had-status-1/72060,
# which shows up sometimes when trying to install packages that want the TZ
# timedatectl expects systemd running, which isn't true in our containers
RUN echo "TZ=${TZ}" >> /etc/R/Renviron && \ 
    sed -i -e '/^R_LIBS_USER=/s/^/#/' /etc/R/Renviron && \
    echo "R_LIBS_USER=${R_LIBS_USER}" >> /etc/R/Renviron && \
    echo "CONDA_DIR=${CONDA_DIR}" >> /etc/R/Renviron

# Install our custom Rprofile.site file
COPY rstudio-config/Rprofile.site /usr/lib/R/etc/Rprofile.site
# Create directory for additional R/RStudio setup code
RUN mkdir /etc/R/Rprofile.site.d
# RStudio needs its own config
COPY rstudio-config/rstudio/rsession.conf /etc/rstudio/rsession.conf
# set up basic rstudio user config
COPY rstudio-config/rstudio/rstudio-prefs.json /etc/rstudio/rstudio-prefs.json
# Use simpler locking strategy
COPY rstudio-config/rstudio/file-locks /etc/rstudio/file-locks


# =============================================================================
# This stage exists to build /srv/r.
FROM base AS srv-r

USER root
# Create user owned R libs dir
# This lets users temporarily install packages
RUN install -d -o ${NB_USER} -g ${NB_USER} ${R_LIBS_USER}

# Install R libraries as our user
USER ${NB_USER}

# Install R packages
COPY install.R /tmp/
RUN /tmp/install.R

# =============================================================================
# This stage exists to build /srv/conda.
FROM base AS srv-conda

# USER root
# Create user owned conda dir
# This lets users temporarily install packages
RUN install -d -o ${NB_USER} -g ${NB_USER} ${CONDA_DIR}

# Install conda environment as our user
USER ${NB_USER}

# Install Conda packages
ENV PATH=${CONDA_DIR}/bin:$PATH
COPY environment.yml /tmp/environment.yml
RUN mamba env update -y -q -n notebook -f /tmp/environment.yml
RUN mamba clean -afy

# =============================================================================
# This stage consumes base and import /srv/r and /srv/conda.
FROM base AS final

USER root
COPY --chown=${NB_USER}:${NB_USER} --from=srv-r /srv/r /srv/r
COPY --chown=${NB_USER}:${NB_USER} --from=srv-conda /srv/conda /srv/conda
COPY --chown=${NB_USER}:${NB_USER} activate-conda.sh /etc/profile.d/activate-conda.sh

USER ${NB_USER}
ENV PATH=${CONDA_DIR}/envs/notebook/bin:${CONDA_DIR}/bin:${R_LIBS_USER}/bin:${DEFAULT_PATH}:/usr/lib/rstudio-server/bin

# Install IR kernelspec. Requires python and R.
RUN R -e "IRkernel::installspec(user = FALSE, prefix='${CONDA_DIR}/envs/notebook')"

# run postBuild script to do any additional setup
COPY --chown=${NB_USER}:${NB_USER} postBuild /tmp/postBuild
RUN chmod +x /tmp/postBuild && /tmp/postBuild && rm -rf /tmp/postBuild

USER root
RUN rm -rf /tmp/*
RUN rm -rf /root/.cache

RUN install -d -o ${NB_USER} -g ${NB_USER} ${REPO_DIR}
COPY --chown=${NB_USER}:${NB_USER} . ${REPO_DIR}

# Add start script
RUN chmod +x "${REPO_DIR}/start"
ENV R2D_ENTRYPOINT="${REPO_DIR}/start"
# Add entrypoint
ENV PYTHONUNBUFFERED=1

USER ${NB_USER}
WORKDIR /home/${NB_USER}

EXPOSE 8888

ENTRYPOINT ["/usr/local/bin/repo2docker-entrypoint"]

# ENTRYPOINT ["tini", "--"]
