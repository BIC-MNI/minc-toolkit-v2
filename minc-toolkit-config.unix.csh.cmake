# minc-toolkit configuration parameters for @MINC_TOOLKIT_VERSION_FULL@
setenv MINC_TOOLKIT @CMAKE_INSTALL_PREFIX@
setenv MINC_TOOLKIT_VERSION "@MINC_TOOLKIT_VERSION_FULL@"
setenv PATH ${MINC_TOOLKIT}/bin:${MINC_TOOLKIT}/pipeline:${PATH}

if ( ! ${?PERL5LIB} ) then
setenv PERL5LIB ${MINC_TOOLKIT}/perl:${MINC_TOOLKIT}/pipeline
else
setenv PERL5LIB ${MINC_TOOLKIT}/perl:${MINC_TOOLKIT}/pipeline:${PERL5LIB}
endif

if ( ! ${?LD_LIBRARY_PATH} ) then
setenv LD_LIBRARY_PATH ${MINC_TOOLKIT}/lib@LIB_SUFFIX@:${MINC_TOOLKIT}/lib@LIB_SUFFIX@/InsightToolkit
else
setenv LD_LIBRARY_PATH ${MINC_TOOLKIT}/lib:${MINC_TOOLKIT}/lib@LIB_SUFFIX@/InsightToolkit:${LD_LIBRARY_PATH}
endif

if ( ! ${?MANPATH} ) then
setenv MANPATH ${MINC_TOOLKIT}/man
else
setenv MANPATH ${MINC_TOOLKIT}/man:${MANPATH}
endif

setenv MNI_DATAPATH ${MINC_TOOLKIT}/../share:${MINC_TOOLKIT}/share

setenv MINC_FORCE_V2 1
setenv MINC_COMPRESS 4
setenv VOLUME_CACHE_THRESHOLD -1
setenv ANTSPATH ${MINC_TOOLKIT}/bin
