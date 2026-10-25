# Put the PREFIRE_MSK sibling packages on PYTHONPATH (the PYTHONPATH method in PREFIRE_MSK/README.md).
# Usage, from anywhere: source /path/to/prefire-msk-bundle/bundle_env.sh
_bundle_root="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
export PYTHONPATH="${_bundle_root}/PREFIRE_ML_MSK/source:${_bundle_root}/PREFIRE_PRD_GEN/source:${_bundle_root}/PREFIRE_tools/source/python${PYTHONPATH:+:${PYTHONPATH}}"
unset _bundle_root
