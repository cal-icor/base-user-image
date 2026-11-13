#!/usr/bin/env python3
"""Checks for the LAION-fMRI stack and the one regression it can cause.

laion-fmri needs awscli, which pins docutils<=0.19 and so downgrades the 0.23
that fica (otter-grader's config library) pulls in. That downgrade breaks
sphinx, which nothing on the hub runs, but it must never reach otter-grader
itself -- so these tests pin both ends of that.
"""


def test_laion_fmri_imports():
    import laion_fmri

    assert laion_fmri.__version__ >= "0.2.0"


def test_main_experiment_subjects():
    # Before 0.2.0 this listed the bucket, so it started returning the two
    # mapping-only participants once they were uploaded and broke any loop
    # that then asked for their (nonexistent) main-experiment files.
    import laion_fmri

    main = laion_fmri.get_subjects()
    assert "sub-04" not in main
    assert "sub-08" not in main

    mapping = laion_fmri.get_subjects("mapping")
    assert "sub-04" in mapping
    assert "sub-08" in mapping


def test_neuroimaging_stack():
    import nibabel
    import nilearn  # noqa: F401
    import s3fs  # noqa: F401

    assert nibabel.__version__ >= "5.0"


def test_otter_survives_the_docutils_downgrade():
    # The reason this file exists. If a future bump lets awscli's docutils pin
    # reach otter, grading breaks on every hub, not just the fMRI course.
    import fica
    import otter
    from otter.check.notebook import Notebook  # noqa: F401

    class _Cfg(fica.Config):
        value = fica.Key(default=1)

    assert _Cfg().value == 1
    assert otter.__version__


def test_betas_h5_is_range_readable():
    # load_betas only works because the GLMsingle h5 is contiguous and
    # uncompressed, so h5py over s3fs can fetch byte ranges. The .nii.gz copy
    # of the same betas cannot. If upstream ever ships it compressed, every
    # ROI read silently turns into a 1.2 GB download.
    import h5py
    import s3fs

    key = (
        "laion-fmri/derivatives/glmsingle-tedana/sub-01/ses-01/func/"
        "sub-01_ses-01_task-images_space-T1w_desc-GLMsingle_model.h5"
    )
    fs = s3fs.S3FileSystem(anon=True)
    with fs.open(key, "rb") as handle, h5py.File(handle, "r") as h5:
        betas = h5["betasmd"]
        assert betas.compression is None
        assert betas.chunks is None
        assert betas[1000:1010].shape == (10, 1, 1, betas.shape[-1])


if __name__ == "__main__":
    test_laion_fmri_imports()
    test_main_experiment_subjects()
    test_neuroimaging_stack()
    test_otter_survives_the_docutils_downgrade()
    test_betas_h5_is_range_readable()
