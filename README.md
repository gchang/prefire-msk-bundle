# PREFIRE_MSK bundle

The PREFIRE 2B-MSK cloud mask code is split across four repositories from the PREFIRE mission team (UW-PREFIRE). This repository holds them side by side as git submodules, each pinned to its `R01` release, so the whole algorithm can be cloned in one step:

```sh
git clone --recurse-submodules https://github.com/gchang/prefire-msk-bundle.git
```

| Submodule | Upstream | R01 commit | Role |
|---|---|---|---|
| `PREFIRE_MSK` | https://github.com/UW-PREFIRE/PREFIRE_MSK | b33ba76f02d3706836e99cd331dbdca2a2a8f55c | the 2B-MSK product code (`dist/produce_L2.py`) |
| `PREFIRE_ML_MSK` | https://github.com/UW-PREFIRE/PREFIRE_ML_MSK | 8a68a7377c698c4f7fa68fbcc25b25df8a5ce252 | the neural-network cloud mask |
| `PREFIRE_PRD_GEN` | https://github.com/UW-PREFIRE/PREFIRE_PRD_GEN | e3933a389894d1af081b3d0bbac4aa0eb27019bc | NetCDF read and write helpers |
| `PREFIRE_tools` | https://github.com/UW-PREFIRE/PREFIRE_tools | 3b590a6eba09ce596e193ad1e04f636a8b7c3d58 | bitflag utilities |

Nothing inside the submodules is changed. All four are MIT-licensed by the PREFIRE Mission Team; see each submodule's LICENSE. The official ASDC R01 2B-MSK products report `PREFIRE_MSK 1.0.2`, the version in `PREFIRE_MSK/VERSION.txt` at this commit.

## Finding the sibling packages

`PREFIRE_MSK`'s README offers two ways to find its siblings: symbolic links in `PREFIRE_MSK/source/`, or adding each sibling's Python source directory to `PYTHONPATH`. This bundle uses `PYTHONPATH`, so the submodules stay untouched:

```sh
source bundle_env.sh    # from the bundle root; sets PYTHONPATH to the three sibling source directories
```

## Software and data

- Python 3.10 with numpy, netcdf4, xarray and tensorflow 2.14 from conda-forge, as in `PREFIRE_MSK/README.md`, and git (to record the code versions in the product).
- The trained models: `PREFIRE_MSK-larger_ancillary-rev_2025-02-26.zip` (13 MB, MIT) from Zenodo record 17081025 (https://zenodo.org/records/17081025), unzipped inside `PREFIRE_MSK/dist/`, which fills `PREFIRE_MSK/dist/ancillary/` (the code reads the models from there).
- Inputs per orbit: a PREFIRE 1B-RAD granule and the matching AUX-MET granule from NASA LaRC ASDC (Earthdata login), about 85 to 95 MB together.
- The final product needs nothing more. The optional browse image needs matplotlib, cartopy, shapely, geopandas and pandas, plus network access for cartopy's Natural Earth coastlines; set `PRD_GEN_BASIC_ONLY=1` to skip the image and the CMR metadata file and run offline.

## Running one orbit

The mission makes 2B-MSK in two steps: `PREFIRE_MSK` writes a raw file for the whole orbit, then `PREFIRE_PRD_GEN` finalizes it into the archived product (polar latitudes only, with the archive's metadata). From the bundle root:

```sh
source bundle_env.sh
python PREFIRE_MSK/dist/determine_prdgit.py        # records the code versions; produce_L2.py needs it
python PREFIRE_PRD_GEN/dist/determine_prdgit.py    # the same for the finalization step

# Step 1: cloud mask (writes raw-PREFIRE_SAT1_2B-MSK_R01_P00_20241007075724_01877.nc into OUTPUT_DIR)
export PACKAGE_TOP_DIR=$PWD/PREFIRE_MSK ANCILLARY_DATA_DIR=$PWD/PREFIRE_MSK/dist/ancillary \
       OUTPUT_DIR=/path/to/raw PRODUCT_FULLVER=R01_P00 \
       ATRACK_IDX_RANGE_0BI=ATRACK_IDXRANGE_0BASED_INCLUSIVE:0:END \
       L1B_RAD_FILE=/path/to/PREFIRE_SAT1_1B-RAD_R01_P00_20241007075724_01877.nc \
       AUX_MET_FILE=/path/to/PREFIRE_SAT1_AUX-MET_R01_P00_20241007075724_01877.nc
python PREFIRE_MSK/dist/produce_L2.py

# Step 2: finalization into the archived product (the output folder must exist)
mkdir -p /path/to/final
export MKL_NUM_THREADS=1 NUMEXPR_NUM_THREADS=1 OMP_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1 OPENBLAS_NUM_THREADS=1
export PACKAGE_TOP_DIR=$PWD/PREFIRE_PRD_GEN ANCILLARY_DATA_DIR=$PWD/PREFIRE_PRD_GEN/dist/ancillary \
       OUTPUT_PRODUCT_DIR=/path/to/final OUTPUT_OPTIONS="" PRD_GEN_BASIC_ONLY=1 \
       INPUT_FPATH_OR_FPREFIX=/path/to/raw/raw-PREFIRE_SAT1_2B-MSK_R01_P00_20241007075724_01877.nc
python PREFIRE_PRD_GEN/dist/produce_PRD.py
```

Checked on 2026-10-25 from a fresh `git clone --recurse-submodules` with SAT1 orbit 01877 and SAT2 orbit 02040: the final files match the official ASDC R01 2B-MSK granules in every `cloud_mask` value (52,880 and 63,032 footprints) and in both quality flags. Each orbit takes about 7 s and 0.6 GB for step 1 and about 4 s and 0.2 GB for step 2.

The author's own test, `PREFIRE_MSK/test/run.sh`, runs step 1 for two orbits, reading its inputs from `PREFIRE_MSK/test/inputs/` and calling `determine_prdgit.py` itself.
