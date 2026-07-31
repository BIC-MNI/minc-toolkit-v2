# minc-toolkit configuration parameters for @MINC_TOOLKIT_VERSION_FULL@
# Locate the toolkit from this script's own path so a relocated install needs
# no editing. This file installs at the top of the prefix, so its directory is
# the prefix. BASH_SOURCE is bash-only; every other shell falls back to the
# path baked in at configure time, which is the previous behaviour.
if [ -n "${BASH_SOURCE:-}" ] && [ -f "${BASH_SOURCE}" ]; then
  MINC_TOOLKIT=$(cd -- "$(dirname -- "${BASH_SOURCE}")" && pwd -P)
else
  MINC_TOOLKIT=@CMAKE_INSTALL_PREFIX@
fi
export MINC_TOOLKIT
export MINC_TOOLKIT_VERSION="@MINC_TOOLKIT_VERSION_FULL@"
export PATH=${MINC_TOOLKIT}/bin:${MINC_TOOLKIT}/pipeline:${PATH}
export PERL5LIB=${MINC_TOOLKIT}/perl:${MINC_TOOLKIT}/pipeline${PERL5LIB:+:$PERL5LIB}
export MNI_DATAPATH=${MINC_TOOLKIT}/../share:${MINC_TOOLKIT}/share
export MINC_FORCE_V2=1
export MINC_COMPRESS=4
export VOLUME_CACHE_THRESHOLD=-1
export MANPATH=:${MINC_TOOLKIT}/man${MANPATH:+:$MANPATH}
@MT_ANTSPATH_SH@
