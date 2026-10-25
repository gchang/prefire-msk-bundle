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

- Python 3.10 with numpy, netcdf4, xarray and tensorflow 2.14 from conda-forge, as in `PREFIRE_MSK/README.md`.
- The trained models: `PREFIRE_MSK-larger_ancillary-rev_2025-02-26.zip` (13 MB, MIT) from Zenodo record 17081025 (https://zenodo.org/records/17081025), unzipped inside `PREFIRE_MSK/dist/`, which fills `PREFIRE_MSK/dist/ancillary/` (the code reads the models from there).
- Inputs per orbit: a PREFIRE 1B-RAD granule and the matching AUX-MET granule from NASA LaRC ASDC (Earthdata login).

## Running one orbit

From the bundle root, after `source bundle_env.sh`:

```sh
export PACKAGE_TOP_DIR=$PWD/PREFIRE_MSK ANCILLARY_DATA_DIR=$PWD/PREFIRE_MSK/dist/ancillary \
       OUTPUT_DIR=/path/to/output PRODUCT_FULLVER=R01_P00 \
       ATRACK_IDX_RANGE_0BI=ATRACK_IDXRANGE_0BASED_INCLUSIVE:0:END \
       L1B_RAD_FILE=/path/to/PREFIRE_SAT1_1B-RAD_R01_P00_20241007075724_01877.nc \
       AUX_MET_FILE=/path/to/PREFIRE_SAT1_AUX-MET_R01_P00_20241007075724_01877.nc
python PREFIRE_MSK/dist/produce_L2.py
```

The author's own test, `PREFIRE_MSK/test/run.sh`, does the same for two orbits, reading its inputs from `PREFIRE_MSK/test/inputs/`.
