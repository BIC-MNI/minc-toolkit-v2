# -*-makefile-*-    <-- an Emacs control
# This is a make file inclusion, to be included in all the
# Netpbm make files.

# This file is meant to contain rules that are substantially the same
# in each of the pbm, pgm, ppm, and pnm subdirectory makes, to avoid
# duplication of effort.

# The following variables must be set in any make file that uses these
# rules:
#
# SRCDIR: The top level directory of Netpbm source code.
# BUILDDIR: The top level directory into which Netpbm is built (built,
#   not installed).
# SUBDIR: The directory, relative to BUILDDIR, of the current directory.
#   It is also the directory, relative to SRCDIR, of source directory that
#   corresponds to the current directory.  Note that you build in the 
#   current directory, using files from the source directory.
# SUBDIRS: list of subdirectories in which certain targets (e.g. 'clean')
#   should be made recursively.
# PKGDIR_DEFAULT: The place to put the packaged stuff for 'make package'
#   if the user doesn't put "pkgdir=" on the Make command line.
# PKGMANDIR: The subdirectory (e.g. "man" or "share/man" of the package
#   directory root in which man pages should be packaged.
# OBJECTS: .o files to be built from .c files with the standard rule.
# PORTBINARIES: list of conventional executables to be built with the standard
#   rule
# MATHBINARIES: obsolete.
# DATAFILES: list of files that should be installed in the "data" directory.
# NETPBMLIBSUFFIX: the suffix, e.g. "so" for the main libraries we build,
#   whatever type they may be.
# STATICLIBSUFFIX: the suffix, e.g. "a" on a static library.  This need
#   not be defined if the user doesn't want to build a static libraries in 
#   addition to the main libraries.
# BINARIES: list of all the executables that need to be installed.
# INSTALL: command to use to copy files to where they belong
# INSTALL_PERM_BIN: file permissions for installed binaries
# INSTALL_PERM_LIB: ...same for libraries
# INSTALL_PERM_HDR: ...same for headers
# INSTALL_PERM_MAN: ...same for man pages
# MERGE_OBJECTS: list of object files that go into the merged executable
#   from the current directory (not subdirectories).  All of these are to
#   be built with the standard rule for merged objects.  These names are
#   relative to the current make directory (must not start with / ).
# MERGEBINARIES: list of the programs that, in a merge build, are invoked
#   via the merged Netpbm program
# CC: C compiler command 
# CPPFLAGS: C preprocessor options
# CFLAGS: C compiler general options
# LD: linker command
# LINKERISCOMPILER: 'Y' if the linker invoked by LD is actually a compiler
#   front end, so takes linker options in a different format
# LDFLAGS: linker options 
# LIBS or LOADLIBES: names of libraries to be added to all links
# INCLUDES: Compiler option string to establish the search path for include
#   files when compiling things or computing dependencies (make dep).
#   current directory, corresponding source tree directory, and ./importinc
#   are implied, so should not be in here.

# In addition, there is CADD, which is extra C compilation flags and
# is intended to be set on a make command line (e.g. 'make CADD=-g')
# for flags that apply just to a particular build.

# In addition, there is CFLAGS_PERSONAL, which is extra C
# compilation flags and is expected to be set via environment variable
# for flags that are particular to the person doing the build and not
# specific to Netpbm.

include $(SRCDIR)/Makefile.version

INCLUDES2 := $(INCLUDES) -I$(SRCDIR)/$(SUBDIR) -I. -I importinc

ifeq ($(NETPBMLIBTYPE),unixstatic)
  NETPBMLIBFNAME = libnetpbm.$(STATICLIBSUFFIX)
else
  NETPBMLIBFNAME = $(NETPBMSHLIBPREFIX)netpbm$(DLLVER).$(NETPBMLIBSUFFIX)
endif
NETPBMLIB = $(BUILDDIR)/lib/$(NETPBMLIBFNAME)

BUNDLED_URTLIB = $(BUILDDIR)/urt/librle.a

# LIBS and LOADLIBES are commonly set as environment variables.
# LOADLIBES is used by GNU Make's implicit .c->.o rule.  LIBS is used by
# GNU Autoconf.

LDLIBS = $(LOADLIBES) $(LIBS)

# 'pkgdir' is meant to be set on the make command line.  Results are
# disastrous if PKGDIR is a relative directory, and I don't know any
# way to detect that case and fail, so I just add a '/' to the front
# if it isn't already there.
ifneq ($(pkgdir)x,x)
  PKGDIR = $(patsubst //%, /%, /$(pkgdir))
else
  PKGDIR = $(PKGDIR_DEFAULT)
endif

#===========================================================================
# We build a directory full of symbolic links to the intra-Netpbm public
# header files just so the compile commands don't have to be littered
# with long -I's.
#===========================================================================

# Note that the "root" headers are in the root of the build tree, not
# the source tree.  All generated headers are in the root directory and
# all root directory headers are generated.
IMPORTINC_ROOT_HEADERS := pm_config.h inttypes_netpbm.h version.h

IMPORTINC_LIB_HEADERS := \
  pm.h pbm.h pgm.h ppm.h pnm.h pam.h bitio.h pbmfont.h ppmcmap.h \
  pammap.h colorname.h ppmfloyd.h ppmdraw.h pm_system.h ppmdfont.h \
  pm_gamma.h lum.h

IMPORTINC_LIB_UTIL_HEADERS := \
  bitreverse.h mallocvar.h nstring.h filename.h pm_c_util.h shhopt.h \
  wordaccess.h wordaccess_64_le.h wordaccess_gcc3_be.h wordaccess_gcc3_le.h \
  wordaccess_generic.h intcode.h \

IMPORTINC_HEADERS := \
  $(IMPORTINC_ROOT_HEADERS) \
  $(IMPORTINC_LIB_HEADERS) \
  $(IMPORTINC_LIB_UTIL_HEADERS)

IMPORTINC_ROOT_FILES := $(IMPORTINC_ROOT_HEADERS:%=importinc/%)
IMPORTINC_LIB_FILES := $(IMPORTINC_LIB_HEADERS:%=importinc/%)
IMPORTINC_LIB_UTIL_FILES := $(IMPORTINC_LIB_UTIL_HEADERS:%=importinc/%)

importinc: \
  $(IMPORTINC_ROOT_FILES) \
  $(IMPORTINC_LIB_FILES) \
  $(IMPORTINC_LIB_UTIL_FILES) \

$(IMPORTINC_ROOT_FILES):importinc/%:$(BUILDDIR)/%
	mkdir -p importinc
	rm -f $@
	$(SYMLINK) $< $@

$(IMPORTINC_LIB_FILES):importinc/%:$(SRCDIR)/lib/%
	mkdir -p importinc
	rm -f $@
	$(SYMLINK) $< $@

$(IMPORTINC_LIB_UTIL_FILES):importinc/%:$(SRCDIR)/lib/util/%
	mkdir -p importinc
	rm -f $@
	$(SYMLINK) $< $@


# We build the symbolic links to header files in the current directory
# just so the compile commands don't have to be littered with -I's.

bmp.h tga.h:%:$(SRCDIR)/converter/%
	rm -f $@
	$(SYMLINK) $< $@

ifneq ($(OMIT_VERSION_H_RULE),1)

$(BUILDDIR)/version.h:
	$(MAKE) -C $(dir $@) $(notdir $@)
endif

ifneq ($(OMIT_CONFIG_RULE),1)
$(BUILDDIR)/Makefile.config: $(SRCDIR)/Makefile.config.in
	$(MAKE) -C $(dir $@) $(notdir $@)

$(BUILDDIR)/pm_config.h:
	$(MAKE) -C $(dir $@) $(notdir $@)
endif

ifneq ($(OMIT_INTTYPES_RULE),1)
$(BUILDDIR)/inttypes_netpbm.h:
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/GNUmakefile $(notdir $@)
endif

# Note that any time you do a make on a fresh Netpbm source tree,
# Make notices that 'Makefile.config', which the make files include, does not
# exist and runs the "Makefile.config" target, which runs Configure.
# If the "config" target were to run Configure as well, it would get run
# twice in a row if you did a 'make config' on a fresh Netpbm source tree.
# But we don't want to make "config" just a no-op, because someone might
# try it after Makefile.config already exists, in order to make a new
# Makefile.config.  Issuing a message as follows seems to make sense in 
# both cases.
.PHONY: config
config:
	@echo "To reconfigure the build, run 'configure'"

# Rule to make C source from lex source.
%.c:%.l
	$(LEX) -t $< >$(notdir $@)

# Rule to make regular object files, e.g. pnmtojpeg.o.

$(OBJECTS): %.o: %.c importinc
#############################################################################
# Note that the user may have configured -I options into CFLAGS or CPPFLAGS.
# -I. is needed when builddir != srcdir
# Note about -o: There used to be systems that couldn't handle a space
# between flag and value.  But we found a Solaris gcc on 2003.09.02 that
# actually fails _without_ the space (it invokes Solaris 'as' with the
# following command, which generates a "no input filename" error:
# '/usr/ccs/bin/as -V -Qy -s -o/tmp/hello.o /var/tmp/ccpiNnia.s')
# This rule has had the space since way before that, so it looks like
# the space is no longer a problem for anyone.
#############################################################################
#
# The NDEBUG macro says not to build code that assumes there are no bugs.
# This makes the code go faster.  The main thing it does is tell the C library
# to make assert() a no-op as opposed to generating code to check the
# assertion and crash the program if it isn't really true.  You can add
# -UNDEBUG (in any of various ways) to override this.
#
	$(CC) -c $(INCLUDES2) -DNDEBUG \
	    $(CPPFLAGS) $(CFLAGS) $(CFLAGS_PERSONAL) $(CADD) -o $@ $<

# libopt is a utility program used in the make file below.
LIBOPT = $(BUILDDIR)/buildtools/libopt

ifneq ($(OMIT_BUILDTOOL_RULE),1)
$(LIBOPT) $(TYPEGEN): $(BUILDDIR)/buildtools
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/buildtools/Makefile \
	    SRCDIR=$(SRCDIR) BUILDDIR=$(BUILDDIR) $(notdir $@) 
endif

ifneq ($(OMIT_LIBRARY_RULE),1)
$(NETPBMLIB): $(BUILDDIR)/lib
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/lib/Makefile \
	    SRCDIR=$(SRCDIR) BUILDDIR=$(BUILDDIR) $(notdir $@) 
endif

ifneq ($(OMIT_URT_RULE),1)
$(BUNDLED_URTLIB): $(BUILDDIR)/urt
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/urt/Makefile \
	    SRCDIR=$(SRCDIR) BUILDDIR=$(BUILDDIR) $(notdir $@) 
endif

# Here are some notes from Nelson H. F. Beebe on April 16, 2002:
#
#   There are at least three incompatible kinds of command-line options
#   that tell the compiler to instruct the linker to save library paths in
#   the executable:
#   
#         -Wl,-rpath,/path/to/dir       gcc, g++, FreeBSD, SGI, Sun compilers
#         -rpath /path/to/dir           Compaq/DEC, SGI compilers
#         -Rdir:dir:dir	                Portland Group, Sun compilers
#   
#   Notice that SGI and Sun support two such flavors.
#
#   Plus, Scott Schwartz observed on March 25, 2003 that while his
#   compiler understands -Wl, his linker does not understand -rpath.
#   His compiler is "Sun WorkShop 6 update 2 C 5.3 2001/05/15".
#
#   Plus, Mike Saunders found in December 2003 that his Solaris 8 system
#   (uname -a says 'SunOS cannonball.method.cx 5.8 Generic_108528-14 
#   sun4u sparc SUNW,Ultra-1') with Gcc 2.95.3 requires the syntax
#
#         -Wl,-R,/path/to/dir
#   
#   This is apparently because Gcc invokes this linker for Saunders:
#
#      ld: Software Generation Utilities - Solaris Link Editors: 5.8-1.273
#
#   I'd say there are also Solaris systems where Gcc invokes the GNU linker
#   and then the option would be -Wl,-rpath...
#
#   On IA32 Linux, at least, GNU ld takes -rpath.  It also has a -R option,
#   but it is something else.
#
#   Alan Fry and Snowcrash demonstrated in 2006.11 that neither -rpath
#   nor -R are recognized options on Mac OS X 'ld'.
#
#   http://developer.apple.com/releasenotes/DeveloperTools/RN-dyld/index.html
#   says that on Mac OS X, libraries aren't searched for in directories,
#   but rather specified by full name, so that rpath doesn't make any
#   sense.  On Mac OS X, you use -install_name when you linkedit shared
#   library S to give the complete installed name of S.  This goes into
#   S so that when something linkedits with S, the complete installed
#   name of S goes into the object that uses S.

ifeq ($(NEED_RUNTIME_PATH),Y)
  ifneq ($(NETPBMLIB_RUNTIME_PATH)x,x)
    ifeq ($(LINKERISCOMPILER),Y)
      # Before Netpbm 10.14 (March 2003), it looks like we used -R
      # instead of -Wl,-rpath on all but a few selected platforms as configured
      # by Configure.  But that doesn't make sense, because we also used
      # LD=$(CC) always.  Beebe's notes and Saunders' observation above
      # above indicate that we need
      # -Wl,... everywhere that a compiler is used, whether native or GNU, 
      # to link.
      RPATH = -Wl,$(RPATHOPTNAME),$(NETPBMLIB_RUNTIME_PATH)
    else
      RPATH = $(RPATHOPTNAME)$(NETPBMLIB_RUNTIME_PATH)
    endif
  endif
endif
# Rules for conventional single-object file executables

# Before Netpbm 10.21 (March 2004), we kept separate lists of binaries
# that require the math library and those that don't, so the binaries
# that don't need it wouldn't have to link it.  But now libnetpbm
# contains gamma correction routines, so it needs the math library,
# and that means every Netpbm binary needs the math library, whether
# it calls those routines or not.  So we will phase out the separate
# lists, and for now we treat them identically.

# Note that GNU C library sometimes defines math functions as inline
# functions, so linking the math library isn't really necessary.  Late
# model GNU C libraries do this only if you specify the -ffast-math
# Gcc option (as told by the __FAST_MATH__ preprocessor macro).
# Earlier ones do it regardless of __FAST_MATH__.

MATHLIB ?= -lm
$(PORTBINARIES) $(MATHBINARIES): %: %.o $(NETPBMLIB) $(LIBOPT)
# Note that LDFLAGS might contain -L options, so order is important.
# LDFLAGS is commonly set as an environment variable.
	$(LD) -o $@ $@.o $(MATHLIB) $(shell $(LIBOPT) $(NETPBMLIB)) \
	  $(LDFLAGS) $(LDLIBS) $(RPATH) $(LADD)


# MERGE STUFF

# .o2 is our suffix for an object file that has had it's main() changed
# to e.g. main_pamcut().  We use them for the merge build.

%.o2: %.c importinc
# Note that the user may have configured -I options into CFLAGS.
	$(CC) -c $(INCLUDES2) -DNDEBUG $(CFLAGS) \
	  "-Dmain=main_$*" \
          $(CFLAGS_MERGE) $(CFLAGS_PERSONAL) $(CADD) -o $@ $<

# The "merge try list" is a file full of TRY macro invocations, one for
# each Netpbm program in this directory or any subdirectory that can be
# invoked via the merged Netpbm program.  You will find it #included in
# netpbm.c.

mergetrylist: $(SUBDIRS:%=%/mergetrylist) 
	cat /dev/null $(SUBDIRS:%=%/mergetrylist) >$@
	$(SRCDIR)/buildtools/make_merge.sh $(MERGEBINARIES) >>$@

# The "merge list" is a list of all the object files from this directory and
# any subdirectories that have to be linked into the merged Netpbm program.
# They are absolute paths.

mergelist: $(SUBDIRS:%=%/mergelist) $(MERGE_OBJECTS)
	cat /dev/null $(SUBDIRS:%=%/mergelist) >$@
	echo $(MERGE_OBJECTS:%=$(CURDIR)/%) >>$@

# merge.o is the object file that contains all the code in this directory
# that needs to be linked into the merged Netpbm program.  This is not used
# today, but some day it will be used instead of mergelist (above).

ifeq ($(MERGE_OBJECTS),)
  MERGE_O_OBJECTS = empty.o
else
  MERGE_O_OBJECTS = $(MERGE_OBJECTS)
endif

merge.o: $(SUBDIRS:%=%/merge.o) $(MERGE_O_OBJECTS)
	$(LDRELOC) -o $@ $^

# empty.o is useful in doing a merge build.  Every directory must be able to
# produce a merge.o file, but not every directory has anything to contribute
# to the merge.
empty.o: %.o: %.c
	$(CC) -c $(CFLAGS_PERSONAL) $(CADD) $< -o $@
empty.c:
	cat /dev/null >empty.c

###########################################################################
# PACKAGING / INSTALLING
###########################################################################

# Some maintenance notes about $(INSTALL): Some install programs can
# install multiple files in one shot; others can take only one file at
# a time.  Some have a -c option; others ignore -c.  Some can take
# permissions in mnemonic form (u=rwx,go=rx); others can't, but all
# take the encoded form (755).  Some have a -d option to install
# directories and never install them implicitly.  Others create
# directories only implicitly.  Installbsd and OSF1 Install need a
# space in "-m 755".  Others don't care.  2000.05.17.  OSF1 Install
# takes only one parameter: the source file.  It picks a destination
# directory by default, or you can specify it with a -f option.
# 2000.06.15

# DJGPP can do SYMKINKs for programs but not for ordinary files, so
# it define SYMLINKEXE, other system don't need it
ifeq ($(SYMLINKEXE)x,x)
  SYMLINKEXE := $(SYMLINK)
endif

$(PKGDIR)/%:
	$(SRCDIR)/buildtools/mkinstalldirs $@

.PHONY: install.merge
install.merge: $(NOMERGEBINARIES:%=%_installbin) $(SCRIPTS:%=%_installscript) \
	$(MERGEBINARIES:%=%_installmerge) $(SUBDIRS:%=%/install.merge)

%_installmerge: $(PKGDIR)/bin
	cd $(PKGDIR)/bin ; rm -f $(@:%_installmerge=%)
	cd $(PKGDIR)/bin ; $(SYMLINKEXE) netpbm$(EXE) $(@:%_installmerge=%)

.PHONY: install.bin
install.bin: $(BINARIES:%=%_installbin) $(SCRIPTS:%=%_installscript) \
	$(SUBDIRS:%=%/install.bin)
# Note that on Cygwin, the executables are actually pbmmake.exe, etc.
# Make and Install know that pbmmake.exe counts as pbmmake.

INSTALLBIN_TARGETS = $(BINARIES:%=%_installbin) netpbm_installbin
.PHONY: $(INSTALLBIN_TARGETS)
$(INSTALLBIN_TARGETS): $(PKGDIR)/bin
	$(INSTALL) -c $(STRIPFLAG) -m $(INSTALL_PERM_BIN) \
	  $(@:%_installbin=%) $<

$(SCRIPTS:%=%_installscript): $(PKGDIR)/bin
	$(INSTALL) -c -m $(INSTALL_PERM_BIN) \
	  $(SRCDIR)/$(SUBDIR)/$(@:%_installscript=%) $<

.PHONY: install.data
install.data: $(DATAFILES:%=%_installdata) $(SUBDIRS:%=%/install.data)

.PHONY: $(DATAFILES:%=%_installdata) 
$(DATAFILES:%=%_installdata): $(PKGDIR)/misc
	$(INSTALL) -c -m $(INSTALL_PERM_DATA) \
	  $(SRCDIR)/$(SUBDIR)/$(@:%_installdata=%) $<


.PHONY: install.man install.man1 install.man3 install.man5
install.man: install.man1 install.man3 install.man5 \
	$(SUBDIRS:%=%/install.man)

MANUALS1 = $(BINARIES) $(SCRIPTS)

PKGMANDIR = man

install.man1: $(PKGDIR)/$(PKGMANDIR)/man1 $(MANUALS1:%=%_installman1)

install.man3: $(PKGDIR)/$(PKGMANDIR)/man3 $(MANUALS3:%=%_installman3)

install.man5: $(PKGDIR)/$(PKGMANDIR)/man5 $(MANUALS5:%=%_installman5)

%_installman1: $(PKGDIR)/$(PKGMANDIR)/man1
	perl -w $(SRCDIR)/buildtools/makepointerman $(@:%_installman1=%) \
          $(NETPBM_DOCURL) $< 1 $(MANPAGE_FORMAT) $(INSTALL_PERM_MAN)

%_installman3: $(PKGDIR)/$(PKGMANDIR)/man3
	perl -w $(SRCDIR)/buildtools/makepointerman $(@:%_installman3=%) \
          $(NETPBM_DOCURL) $< 3 $(MANPAGE_FORMAT) $(INSTALL_PERM_MAN)

%_installman5: $(PKGDIR)/$(PKGMANDIR)/man5
	perl -w $(SRCDIR)/buildtools/makepointerman $(@:%_installman5=%) \
          $(NETPBM_DOCURL) $< 5 $(MANPAGE_FORMAT) $(INSTALL_PERM_MAN)

.PHONY: clean

ifneq ($(EXE)x,x)
EXEPATTERN = *$(EXE)
else
EXEPATTERN = 
endif
clean: $(SUBDIRS:%=%/clean) thisdirclean

.PHONY: thisdirclean
thisdirclean:
	-rm -f *.o *.o2 *.a *.so *.so.* *.dll *.dylib *.cat *~ *.i *.s \
	  $(EXEPATTERN) *.def *.lnk \
	  core *.core mergelist mergetrylist *.c1 empty.c \
	  $(BINARIES) pm_types.h
	-rm -rf importinc

.PHONY: distclean
distclean: $(SUBDIRS:%=%/distclean) thisdirclean
	rm -f Makefile.depend

DEP_SOURCES = $(wildcard *.c *.cpp *.cc)

.PHONY: dep
dep: $(SUBDIRS:%=%/dep) importinc
# We use -MG here because of compile.h and version.h.  They need not exist
# before the first make after a clean.

ifneq ($(DEP_SOURCES)x,x)
	$(CC) -MM -MG $(INCLUDES2) $(DEP_SOURCES) >Makefile.depend
endif

# Note: if I stack all these subdirectory targets into one rule, I get
# weird behavior where e.g. make install-nonmerge causes all the
# %/install.bin makes to happen recursively, but then lib/install.lib
# is considered up to date and doesn't get rebuilt.
%/install.bin:
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/$(SUBDIR)/$(dir $@)Makefile \
	    SRCDIR=$(SRCDIR) BUILDDIR=$(BUILDDIR) $(notdir $@) 
%/install.lib:
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/$(SUBDIR)/$(dir $@)Makefile \
	    SRCDIR=$(SRCDIR) BUILDDIR=$(BUILDDIR) $(notdir $@) 
%/install.man:
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/$(SUBDIR)/$(dir $@)Makefile \
	    SRCDIR=$(SRCDIR) BUILDDIR=$(BUILDDIR) $(notdir $@) 
%/install.data:
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/$(SUBDIR)/$(dir $@)Makefile \
	    SRCDIR=$(SRCDIR) BUILDDIR=$(BUILDDIR) $(notdir $@) 
%/install.merge:
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/$(SUBDIR)/$(dir $@)Makefile \
	    SRCDIR=$(SRCDIR) BUILDDIR=$(BUILDDIR) $(notdir $@) 
$(SUBDIRS:%=%/all): %/all: $(CURDIR)/%
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/$(SUBDIR)/$(dir $@)Makefile \
	    SRCDIR=$(SRCDIR) BUILDDIR=$(BUILDDIR) $(notdir $@) 
$(SUBDIRS:%=%/mergetrylist): %/mergetrylist: $(CURDIR)/% FORCE
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/$(SUBDIR)/$(dir $@)Makefile \
	    SRCDIR=$(SRCDIR) BUILDDIR=$(BUILDDIR) $(notdir $@) 
$(SUBDIRS:%=%/mergelist): %/mergelist: $(CURDIR)/% FORCE
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/$(SUBDIR)/$(dir $@)Makefile \
	    SRCDIR=$(SRCDIR) BUILDDIR=$(BUILDDIR) $(notdir $@) 
$(SUBDIRS:%=%/merge.o): %/merge.o: $(CURDIR)/% FORCE
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/$(SUBDIR)/$(dir $@)Makefile \
	    SRCDIR=$(SRCDIR) BUILDDIR=$(BUILDDIR) $(notdir $@) 
$(SUBDIRS:%=%/clean): %/clean: $(CURDIR)/%
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/$(SUBDIR)/$(dir $@)Makefile \
	    SRCDIR=$(SRCDIR) BUILDDIR=$(BUILDDIR) $(notdir $@) 
$(SUBDIRS:%=%/distclean): %/distclean: $(CURDIR)/%
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/$(SUBDIR)/$(dir $@)Makefile \
	    SRCDIR=$(SRCDIR) BUILDDIR=$(BUILDDIR) $(notdir $@) 
$(SUBDIRS:%=%/dep): %/dep: $(CURDIR)/%
	$(MAKE) -C $(dir $@) -f $(SRCDIR)/$(SUBDIR)/$(dir $@)Makefile \
	    SRCDIR=$(SRCDIR) BUILDDIR=$(BUILDDIR) $(notdir $@) 

#Here is the rule to create the subdirectories.  If you're building in the
#source tree, they already exist, but in a separate build directory, they may
#not.

ifneq ($(SUBDIR)x,x)
# This hack stops us from having a warning due to the same target twice
# when we're in the top level directory (because buildtools, etc are in
# SUBDIRS).
  DIRS2 = $(BUILDDIR)/buildtools $(BUILDDIR)/lib $(BUILDDIR)/urt
endif

$(SUBDIRS:%=$(CURDIR)/%) $(DIRS2):
	mkdir $@


# The automatic dependency generation is a pain in the butt and
# totally unnecessary for people just installing the distributed code,
# so to avoid needless failures in the field and a complex build, the
# rule to generate Makefile.depend automatically simply creates an
# empty file.  A developer may do 'make dep' to create a
# Makefile.depend full of real dependencies.

Makefile.depend:
	cat /dev/null >Makefile.depend

include Makefile.depend

FORCE:
