#!/usr/bin/env Rscript

# Function to install R packages
install_packages_with_versions <- function(packages) {
  available <- available.packages()
  to_install <- names(packages)[!(names(packages) %in% rownames(installed.packages()))]

  if (length(to_install) > 0) {
    install.packages(to_install, available = available,
                     versions = packages[to_install],
                     dependencies = TRUE)
  } else {
    cat("All packages are already installed.\n")
  }
}

# List of packages to ensure are installed
required_packages <- c("renv", "remotes", "devtools")

# Check and install required packages
new_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
if (length(new_packages) > 0) {
  install.packages(new_packages)
}

packages = list(
  "BSDA" = "1.2.2",  # https://github.com/cal-icor/base-user-image/issues/171
  "BiocManager" = "1.30.27",  # https://github.com/cal-icor/base-user-image/issues/171
  "BiodiversityR" = "2.18-1",  # https://github.com/cal-icor/base-user-image/issues/171
  "GGally" = "2.4.0", # https://github.com/cal-icor/csumb-user-image/issues/25
  "GrapheR" = "1.9-86-5",  # https://github.com/cal-icor/base-user-image/issues/171
  "HH" = "3.1-53",  # https://github.com/cal-icor/base-user-image/issues/171
  "HistData" = "1.1.0",  # https://github.com/cal-icor/base-user-image/issues/171
  "IRkernel" = "1.3.2", # required for jupyter R kernel
  "Lock5Data" = "3.0.0", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "MESS" = "0.6.0",  # https://github.com/cal-icor/base-user-image/issues/171
  "PairedData" = "1.1.1",  # https://github.com/cal-icor/base-user-image/issues/171
  "PropCIs" = "0.3-0",  # https://github.com/cal-icor/base-user-image/issues/171
  "RColorBrewer" = "1.1-3", # https://github.com/cal-icor/csumb-user-image/issues/1
  "ROCR" = "1.0-12",  # https://github.com/cal-icor/base-user-image/issues/171
  "Rcmdr" = "2.14.1",  # https://github.com/cal-icor/base-user-image/issues/171
  "RcmdrMisc" = "2.10.2",  # https://github.com/cal-icor/base-user-image/issues/171
  "RcmdrPlugin.EBM" = "1.0-10",  # https://github.com/cal-icor/base-user-image/issues/171
  "RcmdrPlugin.EZR" = "1.70",  # https://github.com/cal-icor/base-user-image/issues/171
  "RcmdrPlugin.HH" = "1.1-51",  # https://github.com/cal-icor/base-user-image/issues/171
  "RcmdrPlugin.KMggplot2" = "0.2-7",  # https://github.com/cal-icor/base-user-image/issues/171
  "RcmdrPlugin.survival" = "1.3-2",  # https://github.com/cal-icor/base-user-image/issues/171
  "Rmisc" = "1.5.1",  # https://github.com/cal-icor/base-user-image/issues/171
  "TOSTER" = "0.8.6",  # https://github.com/cal-icor/base-user-image/issues/171
  "Ternary" = "2.3.7",  # https://github.com/cal-icor/base-user-image/issues/171
  "WRS2" = "1.1-7",  # https://github.com/cal-icor/base-user-image/issues/171
  "agRee" = "0.5-3",  # https://github.com/cal-icor/base-user-image/issues/171
  "ape" = "5.8-1",  # https://github.com/cal-icor/base-user-image/issues/171
  "baseline" = "1.3-8",  # https://github.com/cal-icor/base-user-image/issues/171
  "bootstrap" = "2019.6",  # https://github.com/cal-icor/base-user-image/issues/171
  "car" = "3.1-3", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "carData" = "3.0-6",  # dependency of car, pinned for direct library(); https://github.com/cal-icor/base-user-image/issues/171
  "cholera" = "0.9.1",  # https://github.com/cal-icor/base-user-image/issues/171
  "clipr" = "0.8.1",  # https://github.com/cal-icor/base-user-image/issues/171
  "colorspace" = "2.1-2", # https://github.com/cal-icor/csumb-user-image/issues/1
  "combinat" = "0.0-9",  # https://github.com/cal-icor/base-user-image/issues/171
  "confintr" = "1.0.2",  # https://github.com/cal-icor/base-user-image/issues/171
  "contingencytables" = "3.1.0",  # https://github.com/cal-icor/base-user-image/issues/171
  "correlation" = "0.8.8",  # https://github.com/cal-icor/base-user-image/issues/171
  "cranlogs" = "2.1.1",  # https://github.com/cal-icor/base-user-image/issues/171
  "drc" = "3.0-1",  # https://github.com/cal-icor/base-user-image/issues/171
  "effectsize" = "1.0.3",  # https://github.com/cal-icor/base-user-image/issues/171
  "effsize" = "0.8.1",  # https://github.com/cal-icor/base-user-image/issues/171
  "epiR" = "2.0.98",  # https://github.com/cal-icor/base-user-image/issues/171
  "epitools" = "0.5-10.1",  # https://github.com/cal-icor/base-user-image/issues/171
  "esquisse" = "2.1.0", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "exact2x2" = "1.7.0",  # https://github.com/cal-icor/base-user-image/issues/171
  "extrafont" = "0.20", # https://github.com/cal-icor/csumb-user-image/issues/25
  "factoextra" = "2.2.0",  # https://github.com/cal-icor/base-user-image/issues/171
  "flexdashboard" = "0.6.2", # https://github.com/cal-icor/csumb-user-image/issues/25
  "forcats" = "1.0.0", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "forecast" = "8.24.0", # https://github.com/cal-icor/csumb-user-image/issues/25
  "gdalcubes" = "0.7.0",
  "geeM" = "0.10.1",  # https://github.com/cal-icor/base-user-image/issues/171
  "geepack" = "1.3.13",  # https://github.com/cal-icor/base-user-image/issues/171
  "geodist" = "0.1.1",  # https://github.com/cal-icor/base-user-image/issues/171
  "ggThemeAssist" = "0.1.5", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "ggalluvial" = "0.12.5", # https://github.com/cal-icor/csumb-user-image/issues/1
  "ggbeeswarm" = "0.7.2", # https://github.com/cal-icor/csumb-user-image/issues/25
  "ggcorrplot" = "0.1.4.1", # https://github.com/cal-icor/csumb-user-image/issues/25
  "ggdist" = "3.3.3", # https://github.com/cal-icor/csumb-user-image/issues/25
  "ggformula" = "0.12.0", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "gghighlight" = "0.5.0", # https://github.com/cal-icor/csumb-user-image/issues/25
  "ggmosaic" = "0.3.3", # https://github.com/cal-icor/csumb-user-image/issues/1
  "ggpubr" = "0.6.2", # https://github.com/cal-icor/base-user-image/issues/112
  "ggrepel" = "0.9.6", # https://github.com/cal-icor/csumb-user-image/issues/1
  "ggridges" = "0.5.7", # https://github.com/cal-icor/csumb-user-image/issues/25
  "ggtext" = "0.1.2", # https://github.com/cal-icor/csumb-user-image/issues/25
  "ggthemes" = "5.1.0", # https://github.com/cal-icor/csumb-user-image/issues/1
  "googlesheets4" = "1.1.2", # https://github.com/cal-icor/base-user-image/issues/155
  "gplots" = "3.3.0",  # https://github.com/cal-icor/base-user-image/issues/171
  "gtools" = "3.9.5",  # https://github.com/cal-icor/base-user-image/issues/171
  "gtsummary" = "2.5.0", # https://github.com/cal-icor/base-user-image/issues/112
  "gridExtra" = "2.3", # https://github.com/cal-icor/csumb-user-image/issues/25
  "infer" = "1.1.0", # https://github.com/cal-icor/base-user-image/issues/154
  "irr" = "0.85",  # https://github.com/cal-icor/base-user-image/issues/171
  "janitor" = "2.2.1", # https://github.com/cal-icor/csumb-user-image/issues/1
  "knitr" = "1.50", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "leaflet" = "2.2.3", # https://github.com/cal-icor/csumb-user-image/issues/25
  "lmboot" = "0.0.1",  # https://github.com/cal-icor/base-user-image/issues/171
  "lubridate" = "1.9.4", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "magick" = "2.9.0", # https://github.com/cal-icor/csumb-user-image/issues/25
  "mapgl" = "0.4.1",
  "mapproj" = "1.2.12", # https://github.com/cal-icor/csumb-user-image/issues/25
  "maps" = "3.4.3", # https://github.com/cal-icor/csumb-user-image/issues/25
  "mcp" = "0.3.4",  # requires JAGS; https://github.com/cal-icor/base-user-image/issues/171
  "minioclient" = "0.0.6",
  "mlr3misc" = "0.23.0",  # https://github.com/cal-icor/base-user-image/issues/171
  "modeest" = "2.5.0",  # https://github.com/cal-icor/base-user-image/issues/171
  "mosaic" = "1.9.1", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "multcomp" = "1.4-32",  # https://github.com/cal-icor/base-user-image/issues/171
  "naniar" = "1.1.0", # https://github.com/cal-icor/csumb-user-image/issues/1
  "nloptr" = "2.2.1",  # requested as nlopt; nlopt is an unrelated package; https://github.com/cal-icor/base-user-image/issues/171
  "nortest" = "1.0-4",  # https://github.com/cal-icor/base-user-image/issues/171
  "nycflights13" = "1.0.2", # https://github.com/cal-icor/base-user-image/issues/112
  "openintro" = "2.5.0", # https://github.com/cal-icor/csumb-user-image/issues/1
  "ottr" = "1.6.0", # https://github.com/cal-icor/base-user-image/issues/158
  "palmerpenguins" = "0.1.1", # https://github.com/cal-icor/csumb-user-image/issues/25
  "phytools" = "2.5-2",  # https://github.com/cal-icor/base-user-image/issues/171
  "plotly" = "4.11.0", # https://github.com/cal-icor/csumb-user-image/issues/25
  "plyr" = "1.8.9",  # https://github.com/cal-icor/base-user-image/issues/171
  "polycor" = "0.8-2",  # provides polychor(); https://github.com/cal-icor/base-user-image/issues/171
  "psy" = "1.2",  # https://github.com/cal-icor/base-user-image/issues/171
  "psych" = "2.6.5",  # https://github.com/cal-icor/base-user-image/issues/171
  "pwr" = "1.3-0", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "quarto" = "1.5.1",
  "random" = "0.2.7",  # https://github.com/cal-icor/base-user-image/issues/171
  "rattle" = "5.6.2",  # https://github.com/cal-icor/base-user-image/issues/171
  "readr" = "2.2.0", # https://github.com/cal-icor/base-user-image/issues/154
  "reshape2" = "1.4.5",  # https://github.com/cal-icor/base-user-image/issues/171
  "rgl" = "1.3.36",  # https://github.com/cal-icor/base-user-image/issues/171
  "rmarkdown" = "2.29", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "rptR" = "0.9.23",  # https://github.com/cal-icor/base-user-image/issues/171
  "rstac" = "1.0.1",
  "rstatix" = "1.1.0", # https://github.com/cal-icor/base-user-image/issues/154
  "scales" = "1.4.0", # https://github.com/cal-icor/csumb-user-image/issues/25
  "season" = "0.3.16",  # https://github.com/cal-icor/base-user-image/issues/171
  "see" = "0.12.0", # https://github.com/cal-icor/csumb-user-image/issues/1
  "sf" = "1.0-19",
  "shotGroups" = "0.8.4",  # https://github.com/cal-icor/base-user-image/issues/171
  "sjPlot" = "2.9.0", # https://github.com/cal-icor/base-user-image/issues/112
  "socviz" = "1.2", # https://github.com/cal-icor/csumb-user-image/issues/25
  "stars" = "0.6-7",
  "sweep" = "0.2.6", # https://github.com/cal-icor/csumb-user-image/issues/25
  "terra" = "1.8-10",
  "testequavar" = "0.1.5",  # https://github.com/cal-icor/base-user-image/issues/171
  "tidymodels" = "1.3.0", # https://github.com/cal-icor/cal-icor-hubs/issues/163
  "tidyquant" = "1.0.11", # https://github.com/cal-icor/csumb-user-image/issues/25
  "tidyr" = "1.3.1", # https://github.com/cal-icor/cal-icor-hubs/issues/294
  "tidyverse" = "2.0.0",
  "timeSeries" = "4052.112",  # https://github.com/cal-icor/base-user-image/issues/171
  "timetk" = "2.9.1", # https://github.com/cal-icor/csumb-user-image/issues/25
  "vegan" = "2.7-6",  # https://github.com/cal-icor/base-user-image/issues/171
  "viridis" = "0.6.5" # https://github.com/cal-icor/csumb-user-image/issues/1
  # Ensure that every entry have a comma, except the last one.
)

install_packages_with_versions(packages)

# install GitHub packages
remotes::install_github("hrbrmstr/waffle") # https://github.com/cal-icor/cal-icor-hubs/issues/294
remotes::install_github("rpruim/ISIwithR") # https://github.com/cal-icor/base-user-image/issues/154
remotes::install_github("speegled/fosdata") # https://github.com/cal-icor/base-user-image/issues/117
remotes::install_github("droglenc/NCStats@939e378225f4f1c85c04fb97bd401c2bfc853496")  # 0.4.8.9000; https://github.com/cal-icor/base-user-image/issues/171
remotes::install_github("jbryer/psa@481fceca7c87f10b3243e7674a14feb46e78b3b1")  # 0.1.2; https://github.com/cal-icor/base-user-image/issues/171

# Bioconductor packages. The release pins the versions; 3.21 is the release that
# pairs with R 4.5 (runtime.txt). It ships ggtree 3.16.3 and tanggle 1.14.0.
# Do not bump to 3.23 without moving runtime.txt to R 4.6 first.
BiocManager::install(version = "3.21", ask = FALSE, update = FALSE)  # https://github.com/cal-icor/base-user-image/issues/171
BiocManager::install(c("ggtree", "tanggle"), ask = FALSE, update = FALSE)  # https://github.com/cal-icor/base-user-image/issues/171

# Archived on CRAN, no current release. Installed from the Archive at their last version.
remotes::install_version("digitize", version = "0.0.4", repos = "https://cloud.r-project.org")  # https://github.com/cal-icor/base-user-image/issues/171
remotes::install_version("phylotools", version = "0.2.2", repos = "https://cloud.r-project.org")  # https://github.com/cal-icor/base-user-image/issues/171
remotes::install_version("RcmdrPlugin.mosaic", version = "1.0-7", repos = "https://cloud.r-project.org")  # https://github.com/cal-icor/base-user-image/issues/171
remotes::install_version("tigerstats", version = "0.3.2", repos = "https://cloud.r-project.org")  # https://github.com/cal-icor/base-user-image/issues/171

# Archived AND need GTK2 headers, which Debian no longer ships. Left off deliberately.
# remotes::install_version("RGtk2", version = "2.20.36.3", repos = "https://cloud.r-project.org")  # https://github.com/cal-icor/base-user-image/issues/171
# remotes::install_version("cairoDevice", version = "2.28.2.2", repos = "https://cloud.r-project.org")  # https://github.com/cal-icor/base-user-image/issues/171
