# MINC Toolkit v2 (Medical Imaging NetCDF Toolkit)

[![CI](https://github.com/BIC-MNI/minc-toolkit-v2/actions/workflows/ci.yml/badge.svg)](https://github.com/BIC-MNI/minc-toolkit-v2/actions/workflows/ci.yml)
[![Release](https://github.com/BIC-MNI/minc-toolkit-v2/actions/workflows/release.yml/badge.svg)](https://github.com/BIC-MNI/minc-toolkit-v2/actions/workflows/release.yml)

## Introduction

MINC is a medical image file format built on NetCDF (MINC1) and HDF5 (MINC2).
This repository is a superbuild: one CMake project that fetches, patches,
builds, and installs many MINC packages, plus the third-party libraries they
need, into a single directory. The packages were written over three decades by
different authors and do not build together on their own.

You get one install prefix that holds several hundred command-line programs, a
set of Perl pipeline scripts, Perl modules, man pages, a small amount of data,
and the libraries and headers to write your own MINC programs.

- **Install a binary package**: [Install a released package](#install-a-released-package).
- **Install on macOS with Homebrew**: [Install with Homebrew](#install-with-homebrew-macos).
- **Build it yourself**: [Build from source](#build-from-source).
- **Find out what you get**: [What is installed](#what-is-installed).

## Install a released package

Binary packages are on the [Releases
page](https://github.com/BIC-MNI/minc-toolkit-v2/releases). The release workflow
builds them for each `v<major>.<minor>.<patch>` tag:

| Platform | File |
| --- | --- |
| Ubuntu 22.04, 24.04, 26.04 and Debian 11, 12, 13 | `minc-toolkit-v2_<version>_<distro>-<codename>-<variant>_amd64.deb` |
| Fedora 42, 43, 44 | `minc-toolkit-v2-<version>-fc<release>-<variant>.x86_64.rpm` |
| macOS on Apple Silicon | `minc-toolkit-v2-<version>-<runner>-arm64-<variant>.pkg` |
| Any | `minc-toolkit-v2-<version>-src.tar.gz` (source, submodules included) |

Each platform has two variants:

- `minimal` — the core MINC toolkit, including the ITK-based EZminc and
  patch_morphology tools. No ANTs, no Convert3D, no Elastix, and no visual
  tools.
- `full` — everything in `minimal`, plus ANTs, Convert3D, Elastix, and the
  visual tools (Display, Register, ray_trace, ILT, postf, xdisp).

Install on Debian or Ubuntu:

```sh
sudo dpkg -i minc-toolkit-v2_<version>_<distro>-<codename>-<variant>_amd64.deb
sudo apt-get install -fy
```

Install on Fedora:

```sh
sudo dnf install minc-toolkit-v2-<version>-fc<release>-<variant>.x86_64.rpm
```

Install on macOS: open the `.pkg` file. The package is not signed. On the first
run, right-click the file and select **Open** to get past Gatekeeper.

Packages install into `/opt/minc/<version>`. After you install, read
[Set up your shell](#set-up-your-shell).

Releases up to 1.9.18.3 carry only a source tarball. The binary packages listed
above come from the current release workflow.

## Install with Homebrew (macOS)

The [vfonov/minc](https://github.com/vfonov/homebrew-minc) tap is a third-party
alternative to the `.pkg` file:

```sh
brew tap vfonov/minc
brew install --build-from-source minc-toolkit-v2
```

`--build-from-source` is required. The tap publishes no bottle.

What to expect:

- The formula follows the tip of the `develop-1.9.18` branch, not a release tag.
- It builds ITK, ANTs, Elastix, and Convert3D from source. The build takes hours
  and needs several gigabytes of disk space.
- It carries every third-party dependency as a Homebrew resource, so the build
  itself needs no network access.

Set up your shell with the Homebrew path:

```sh
source "$(brew --prefix)/opt/minc-toolkit-v2/minc-toolkit-config.sh"
```

The [Set up your shell](#set-up-your-shell) section lists what that script sets.

This tap is maintained outside this repository. Report problems with the formula
to the tap.

## Build from source

### Get the source

The toolkit is a set of git submodules. CMake will not configure the project
without them.

```sh
git clone --recursive --branch release-1.9.18 \
  https://github.com/BIC-MNI/minc-toolkit-v2.git
cd minc-toolkit-v2
```

If you already cloned the repository without `--recursive`, add the submodules:

```sh
git submodule update --init --recursive
```

Which branch or tag to use:

| Ref | Use |
| --- | --- |
| `release-1.9.18` | Stable branch. Holds the newest 1.9.18 point release. |
| `release-1.9.18.4`, `release-1.9.18.3`, … | Fixed point releases. |
| `develop-1.9.18` | Development branch for the 1.9.18 series. |

You can also download the source tarball from a release. The tarball already
contains every submodule, so it needs no git commands.

### Configure and build

You need CMake 3.10 or newer. Read [Build dependencies](#build-dependencies)
first and install the packages for your system.

This example builds every tool and installs into `/opt/minc/1.9.18`:

```sh
cmake -B build -S . \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/opt/minc/1.9.18 \
  -DMT_BUILD_SHARED_LIBS=ON \
  -DMT_BUILD_ITK_TOOLS=ON \
  -DMT_BUILD_ANTS=ON \
  -DMT_BUILD_C3D=ON \
  -DMT_BUILD_ELASTIX=ON \
  -DMT_BUILD_VISUAL_TOOLS=ON \
  -DMT_USE_OPENMP=ON

cmake --build build -j"$(nproc)"
sudo cmake --install build
```

To pick options in a text menu instead, run `ccmake -B build -S .`.

Notes:

- The build downloads third-party source archives. It needs internet access
  unless you pre-fill the package cache with `-DMT_PACKAGES_PATH=<dir>`.
- A full build takes hours and needs several gigabytes of disk space. ITK, ANTs,
  Convert3D, and Elastix take most of that.
- Set `-DMT_BUILD_LITE=ON` for a fast build with no ITK and no visual tools.
- If you install as root into a system directory, run the build step as your own
  user and only the install step with `sudo`, as shown above.

### Set up your shell

The install writes two shell scripts to the top of the install prefix. Source
the one that matches your shell:

```sh
source /opt/minc/1.9.18/minc-toolkit-config.sh    # sh, bash, zsh
source /opt/minc/1.9.18/minc-toolkit-config.csh   # csh, tcsh
```

Source this file in every shell that uses the toolkit. Add the line to your
`~/.bashrc` (or `~/.profile`) to make it permanent. The programs will not run
correctly without it, whichever prefix you installed into.

The script sets:

| Variable | Purpose |
| --- | --- |
| `MINC_TOOLKIT` | The install prefix. |
| `MINC_TOOLKIT_VERSION` | Version and build date. |
| `PATH` | Adds `bin` and `pipeline`. |
| `PERL5LIB` | Adds `perl` and `pipeline`, so the Perl scripts find their modules. |
| `LD_LIBRARY_PATH` (`DYLD_LIBRARY_PATH` on macOS) | Adds `lib` and `lib/InsightToolkit`. |
| `MNI_DATAPATH` | Colon-separated search path for model and tag data. Read by the `MNI::DataDir` Perl module, which `classify_clean`, `insect`, `compute_icbm_vols`, and other scripts use. |
| `MANPATH` | Adds `man`. |
| `ANTSPATH` | Set to `bin`, which the ANTs shell scripts require. Linux only. |
| `MINC_FORCE_V2=1` | Write MINC2 (HDF5) files by default. |
| `MINC_COMPRESS=4` | Default compression level for new files. |
| `VOLUME_CACHE_THRESHOLD=-1` | Turn off the volume_io block cache. A negative value makes every volume load whole into memory. |

## Build options

Pass these to `cmake` as `-D<option>=ON` or `-D<option>=OFF`.

### What to build

| Option | Default | Effect |
| --- | --- | --- |
| `MT_BUILD_LITE` | `OFF` | Build without ITK and without visual tools. Also forces ANTs, Convert3D, and Elastix off. |
| `MT_BUILD_ITK_TOOLS` | `ON` | Build the ITK-based tools: EZminc, patch_morphology, and the four options below. |
| `MT_BUILD_ANTS` | `ON` | Build ANTs. Needs `MT_BUILD_ITK_TOOLS`. |
| `MT_BUILD_C3D` | `ON` | Build Convert3D. Needs `MT_BUILD_ITK_TOOLS`. |
| `MT_BUILD_ELASTIX` | `ON` | Build Elastix. Needs `MT_BUILD_ITK_TOOLS`. |
| `MT_BUILD_ABC` | `OFF` | Build ABC brain segmentation. Needs `MT_BUILD_ITK_TOOLS`. |
| `MT_BUILD_VISUAL_TOOLS` | `OFF` | Build Display, Register, ray_trace, ILT, postf, and xdisp. Needs OpenGL. |
| `MT_BUILD_SHARED_LIBS` | `OFF` | Build shared libraries instead of static ones. |
| `MT_USE_OPENMP` | `OFF` | Build with OpenMP multi-threading. |
| `MT_BUILD_DCM2MNC_TESTS` | `OFF` | Download dcm2niix test data and run the `dcm2mnc` integration tests. Needs internet access at build time. |

`MT_BUILD_ANTS`, `MT_BUILD_C3D`, `MT_BUILD_ELASTIX`, and `MT_BUILD_ABC` only
appear in the CMake cache after `MT_BUILD_ITK_TOOLS` is on.

### Windowing backend

| Option | Default | Effect |
| --- | --- | --- |
| `MT_USE_GLFW` | `ON` | Use GLFW for the visual tools. Works over SSH and x2go. Forced on for macOS. |
| `USE_SYSTEM_GLUT` | `ON` | Use the system GLUT. Only read when `MT_USE_GLFW=OFF`. |

### BLAS

| Option | Default | Effect |
| --- | --- | --- |
| `MT_USE_BLAS` | `ON` | Use a BLAS library. `OFF` compiles out the optional BLAS code paths in BEaST and patch_morphology. |
| `MT_BUILD_OPENBLAS` | `OFF` | Build OpenBLAS from source and ignore any system BLAS. |
| `BLAS_PREFERENCE` | `Auto` | Which system BLAS to prefer: `Auto`, `OpenBLAS`, `MKL`, `Apple`, or `Netlib`. |

See [BLAS.md](BLAS.md) for the details.

### System libraries

Each `USE_SYSTEM_*` option is a choice between the copy your distribution ships
and a copy the superbuild downloads and builds. `ON` uses the system copy.

| Option | Default |
| --- | --- |
| `USE_SYSTEM_ZLIB` | `OFF` |
| `USE_SYSTEM_NETCDF` | `OFF` |
| `USE_SYSTEM_HDF5` | `OFF` |
| `USE_SYSTEM_GSL` | `OFF` |
| `USE_SYSTEM_FFTW3F` | `OFF` |
| `USE_SYSTEM_FFTW3D` | `OFF` |
| `USE_SYSTEM_JPEG` | `OFF` |
| `USE_SYSTEM_OPENJPEG` | `OFF` |
| `USE_SYSTEM_LIBARCHIVE` | `OFF` |
| `USE_SYSTEM_NIFTI` | `OFF` |
| `USE_SYSTEM_ITK` | `OFF` |
| `USE_SYSTEM_EXPAT_ITK` | `OFF` |
| `USE_SYSTEM_PNG` | `ON` on Apple Silicon, `OFF` elsewhere |

Building everything from source gives the most repeatable result and is the
right choice for a personal install. The release packages use the system
libraries instead, so that the resulting `.deb` and `.rpm` files depend on the
distribution packages.

`USE_SYSTEM_NIFTI` works alongside the ITK tools, but only as of the ITK pinned
in `cmake-modules/BuildITKv4.cmake`. ITK bundles its own NIfTI, and until
[ITK#6756](https://github.com/InsightSoftwareConsortium/ITK/pull/6756) it
renamed the `niftiio` half out of the way but not `znzlib` — so it exported
`znzopen`, `znzread`, `znzseek` and a dozen siblings under their plain names.
A distribution NIfTI exports the same names, and in a tool linking both —
`c3d`, `elastix`, ANTs — ITK's copies interpose over the system `libznz.so` at
runtime, with nothing failing at link time to say so. Both halves are prefixed
now. If you pin an older ITK, keep `USE_SYSTEM_NIFTI=OFF`.

## Build dependencies

Always needed: a C and C++ compiler, CMake 3.10 or newer, Perl, BISON, FLEX, and
`bc`. Add a Fortran compiler if you set `MT_BUILD_OPENBLAS=ON`. ImageMagick is
needed to run the test suite.

### Debian and Ubuntu

```sh
sudo apt-get install \
  build-essential cmake git file bc \
  bison flex perl gfortran imagemagick \
  zlib1g-dev libnetcdf-dev libhdf5-dev \
  libgsl-dev libfftw3-dev libjpeg-dev libopenjp2-7-dev \
  libarchive-dev libexpat1-dev libopenblas-dev
```

For the visual tools, add:

```sh
sudo apt-get install \
  libx11-dev libxi-dev libxmu-dev libxrandr-dev libxext-dev \
  libgl-dev libglu1-mesa-dev libglfw3-dev
```

The `-dev` packages above are only needed for the matching `USE_SYSTEM_*=ON`
options. A default build compiles those libraries itself.

### Fedora and RHEL

```sh
sudo dnf install \
  gcc gcc-c++ gcc-gfortran cmake make git file which bc \
  bison flex perl perl-FindBin perl-File-Path ImageMagick \
  zlib-devel netcdf-devel hdf5-devel gsl-devel \
  fftw-devel libjpeg-turbo-devel openjpeg2-devel \
  libarchive-devel expat-devel openblas-devel
```

For the visual tools, add:

```sh
sudo dnf install \
  libX11-devel libXi-devel libXmu-devel libXrandr-devel libXext-devel \
  mesa-libGL-devel mesa-libGLU-devel glfw-devel
```

### macOS

```sh
brew install cmake bison flex pkg-config libpng glfw
```

macOS ships an old BISON and FLEX. Put the Homebrew versions ahead of the system
ones in your `PATH` before you configure.

### Third-party libraries the superbuild builds

Unless you turn on the matching `USE_SYSTEM_*` option, the build downloads and
compiles: zlib, NetCDF, HDF5, GSL, FFTW3 (single and double precision),
libjpeg-turbo, OpenJPEG, libarchive, NIFTI, ITK 4.14, and GLFW. OpenBLAS is
built only when you set `MT_BUILD_OPENBLAS=ON`.

## What is installed

Everything lands under one prefix, for example `/opt/minc/1.9.18`:

| Directory | Contents |
| --- | --- |
| `bin/` | Command-line programs. Several hundred, depending on which options you set. |
| `pipeline/` | Perl pipeline scripts that chain the programs into whole processing jobs. |
| `perl/` | Perl modules that the scripts use: `MNI::*`, `Getopt::Tabular`, `Text::Format`. |
| `man/man1/` | Man pages for the core MINC programs. |
| `share/` | Data files that programs read at run time. |
| `etc/` | Protocol files for `mritotal`. |
| `lib/`, `include/` | Libraries and headers for writing your own MINC programs. |
| `minc-toolkit-config.sh`, `minc-toolkit-config.csh` | Shell setup. See [Set up your shell](#set-up-your-shell). |

### Programs, by job

**Read and convert files**
`dcm2mnc` converts DICOM to MINC. `nii2mnc` and `mnc2nii` convert to and from
NIfTI. `ecattominc`, `minctoecat`, and `upet2mnc` handle PET formats.
`rawtominc` and `minctoraw` handle raw binary data. `mincconvert` moves a file
between MINC1 and MINC2. `mincinfo`, `mincheader`, `mincdump`, and `minchistory`
report what is in a file. `minc_modify_header` and `mincedit` change the
metadata.

**Process volumes**
`mincmath` and `minccalc` do arithmetic on one or more volumes. `mincaverage`
and `mincbigaverage` average many volumes. `mincblur` smooths. `mincmorph`
does morphological operations. `mincresample` reslices a volume, with or without
a transform. `mincreshape`, `autocrop`, `voliso`, `volcentre`, and `volpad`
change sampling and extent. `mincstats` and `volume_stats` report statistics.
`mincmask`, `mincdefrag`, and `mincnorm` clean up and normalise.

**Correct intensity non-uniformity (N3)**
`nu_correct` runs the whole N3 method. `nu_estimate` and `nu_evaluate` are its
two halves, for when you need to control the steps. See the
[N3 documentation](http://en.wikibooks.org/wiki/MINC/Tools/N3).

**Register images**
`minctracc` performs linear and non-linear registration and implements the
ANIMAL algorithm. `mritotal` registers a T1 brain scan into stereotaxic space.
`mritoself` registers scans of the same subject. `xfmconcat`, `xfminvert`,
`xfmavg`, `xfm2param`, `param2xfm`, and `xfmtool` build and inspect the
resulting transform files.

**Extract the brain**
`mincbeast` segments the brain with a patch-based method. `beast_normalize`
prepares the input. `beast_prepareADNIlib` builds the prior library that
`mincbeast` needs.

**Classify tissue**
`classify` and `classify_clean` label tissue types. `gco_classify` uses graph
cuts. With `MT_BUILD_ITK_TOOLS=ON` you also get `em_classify`, `mrfseg`, and
`gamixture`.

**Work with surfaces and objects**
`convert_object` and `transform_objects` handle the `.obj` surface format.
`subdivide_polygons`, `average_surfaces`, `measure_surface_area`, and
`surface_mask2` operate on cortical surfaces. `vertstats_math` and
`vertstats_stats` do statistics on per-vertex data.

**Look at the data**
`mincpik` writes a PNG or JPEG snapshot of a slice. It needs ImageMagick, and it
is how the pipeline scripts build their quality-control images. `mincview` opens
a quick view of a volume. Both are always installed.

With `MT_BUILD_VISUAL_TOOLS=ON` you also get the interactive viewers: `Display`,
a 3D viewer with manual segmentation; `register`, which shows two volumes side by
side for co-registration; `postf`, which displays statistical results; `xdisp`, a
light X11 viewer; and `ray_trace`, which renders 3D objects to an image.

**Model and simulate**
`mrisim` simulates MRI acquisitions. `make_phantom` builds geometric test
volumes. `glim_image` fits a voxel-wise general linear model.

**ITK-based tools** (need `MT_BUILD_ITK_TOOLS=ON`)
EZminc adds `itk_resample`, `itk_morph`, `itk_convert`, the `mincnlm` and
`minc_anlm` non-local means filters, the `fit_harmonics_grids` distortion
correction tools, and `DemonsRegistration`. patch_morphology adds
`itk_patch_morphology`, `itk_patch_segmentation`, `itk_patch_grading`, and
`itk_minc_nonlocal_filter`. ANTs adds `ANTS`, `antsRegistration`,
`antsApplyTransforms`, `N4BiasFieldCorrection`, `Atropos`, and the rest of the
ANTs programs. Convert3D adds `c3d`. Elastix adds `elastix` and `transformix`.

### Pipeline scripts

`pipeline/` holds about forty Perl scripts from the `bic-pipelines` package.
They join the programs above into complete jobs. `standard_pipeline.pl` drives
the anatomical pipeline by calling one `pipeline_*.pl` script per stage:
non-uniformity correction, registration to stereotaxic space, brain masking,
non-linear registration, tissue classification, segmentation, smoothing, and
volume reports. `infant_pipeline.pl` and `pipeline_longitudinal.pl` handle other
study designs. The `pipeline_qc_*.pl` scripts write quality-control images.

Treat these scripts as reference implementations and as a record of how the BIC
used the tools. They expect models and data that this repository does not
install. Read the script before you run it.

### Data files

| Path | Used by |
| --- | --- |
| `share/N3/average_305_mask_1mm.mnc.gz`, `share/N3/icbm_avg_152_t1_tal_nlin_symmetric_VI_mask.mnc.gz` | Default brain masks for `nu_correct` and `nu_estimate`. |
| `share/classify/*.tag` | Training tag points for `classify`. |
| `share/ILT/labels.map` | Label names used by the ILT figure-layout modules. |
| `etc/mritotal*.cfg` | Preprocessing protocols for `mritotal`. |

### Data files that are not included

Two well-used programs need data that this repository does not ship. Both fail
until you supply it.

- **Stereotaxic models.** `mritotal` registers against an average brain and
  looks for it in `$MINC_TOOLKIT/share/mni-models`. Install the
  `mni_autoreg_model` or `bic-mni-models` package into that directory, or point
  `mritotal` elsewhere with `-modeldir` and `-model`. The Perl scripts that use
  `MNI::DataDir` search `MNI_DATAPATH` instead.
- **BEaST prior library.** `mincbeast` needs a library of prior segmentations.
  Its compiled-in default location is `$MINC_TOOLKIT/share/beast-library-1.0`.
  Build one with `beast_prepareADNIlib`, or take the library from
  [BEaST_library](https://github.com/BIC-MNI/BEaST_library). See `BEaST/README`
  for the file layout the library must have.

### Perl modules that are not included

Two installed scripts need a module from CPAN. Every other program works
without them.

| Script | Module | Debian and Ubuntu | Fedora |
| --- | --- | --- | --- |
| `xfmdecomp.pl` | `Math::MatrixReal` | `libmath-matrixreal-perl` | `perl-Math-MatrixReal` |
| `patch_segmentation_pipeline.pl` | `Parallel::ForkManager` | `libparallel-forkmanager-perl` | `perl-Parallel-ForkManager` |

The `.deb` recommends both packages and the `.rpm` suggests them, so a normal
`apt` or `dnf` install pulls them in. Install them yourself if you use the
relocatable tarball, or build from source.

## Bundled packages

Core MINC packages, all built by default:

| Package | What it is |
| --- | --- |
| [libminc](https://github.com/BIC-MNI/libminc) | The MINC file I/O library, including volume_io. |
| [minc-tools](https://github.com/BIC-MNI/minc-tools) | The low-level `minc*` programs and `dcm2mnc`. |
| [minc-widgets](https://github.com/BIC-MNI/minc-widgets) | Shell and Perl helpers: `volcentre`, `voliso`, `xfmavg`, and others. |
| [bicpl](https://github.com/BIC-MNI/bicpl) | The BIC programming library. Adds 3D object I/O. |
| [EBTKS](https://github.com/BIC-MNI/EBTKS) | Everything But The Kitchen Sink: a C++ image manipulation library. |
| [cxxopts](https://github.com/jarro2783/cxxopts) | Header-only command-line argument parsing, used by oobicpl. |
| [oobicpl](https://github.com/BIC-MNI/oobicpl) | Object-oriented C++ interface to bicpl. |
| [conglomerate](https://github.com/BIC-MNI/conglomerate) | A large set of volume and surface programs. |
| [inormalize](https://github.com/BIC-MNI/inormalize) | Intensity normalisation. |
| [N3](https://github.com/BIC-MNI/N3) | Non-parametric intensity non-uniformity correction. |
| [classify](https://github.com/BIC-MNI/classify) | Tissue classification. |
| [mni_autoreg](https://github.com/BIC-MNI/mni_autoreg) | Linear and non-linear registration. Implements ANIMAL. |
| [glim_image](https://github.com/BIC-MNI/glim_image) | Voxel-wise general linear modelling. |
| [bic-pipelines](https://github.com/BIC-MNI/bic-pipelines) | Brain MRI processing pipelines. |
| [BEaST](https://github.com/BIC-MNI/BEaST) | Patch-based brain extraction. |
| [mrisim](https://github.com/BIC-MNI/mrisim) | MRI acquisition simulator. |
| [mni-perllib](https://github.com/BIC-MNI/mni-perllib) | The `MNI::*` Perl modules the scripts use. |
| [minc_gco](https://github.com/BIC-MNI/minc_gco) | Graph-cut classification. |

Built when `MT_BUILD_ITK_TOOLS=ON`:

| Package | What it is |
| --- | --- |
| [EZminc](https://github.com/BIC-MNI/EZminc) | Easy MINC: a higher-level C++ interface, plus distortion correction, non-local means filtering, MRF classification, and diffeomorphic demons registration. |
| [patch_morphology](https://github.com/NIST-MNI/patch_morphology) | Patch-based segmentation and grading. |
| [ANTs](https://github.com/vfonov/ANTs) | Advanced Normalization Tools, from a fork with MINC support. Build with `MT_BUILD_ANTS`. |
| [Convert3D](http://www.itksnap.org/c3d/) | Multi-purpose image processing. Build with `MT_BUILD_C3D`. |
| [Elastix](https://github.com/SuperElastix/elastix) | Rigid and non-rigid registration. Build with `MT_BUILD_ELASTIX`. |

Built when `MT_BUILD_VISUAL_TOOLS=ON`:

| Package | What it is |
| --- | --- |
| [bicgl](https://github.com/BIC-MNI/bicgl) | OpenGL layer under the viewers. |
| [Display](https://github.com/BIC-MNI/Display) | 3D viewer and manual segmentation. |
| [Register](https://github.com/BIC-MNI/Register) | Interactive co-registration viewer. |
| [ray_trace](https://github.com/BIC-MNI/ray_trace) | 3D object renderer. |
| [ILT](https://github.com/BIC-MNI/ILT) | Image Layout Toolkit. Perl modules that compose figures from volumes and 3D objects. |
| [postf](https://github.com/BIC-MNI/postf) | Viewer for statistical results. X11 only. |
| [xdisp](https://github.com/BIC-MNI/xdisp) | Light X11 image viewer. |

## Licence

Each bundled package keeps its own licence. See [COPYING.txt](COPYING.txt) and
the licence file inside each subdirectory.
