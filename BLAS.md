# BLAS in minc-toolkit-v2

The superbuild detects BLAS once at the top level and exports it as the
imported target `BLAS::BLAS`. Subprojects (in-tree via `add_subdirectory`,
or out-of-tree via `ExternalProject_Add`) all consume that single target,
so the link line is identical regardless of which vendor was selected.

## User knobs

Pass these at top-level configure time:

| Cache var | Default | Meaning |
| --- | --- | --- |
| `MT_USE_BLAS`      | `ON`   | If `OFF`, BLAS is not used at all. Detection is skipped even if a system BLAS is present, and `BLAS::BLAS` / `LAPACKE::LAPACKE` become empty stub targets. Subprojects with optional BLAS code paths (BEaST SPAMS, patch_morphology NNLS) compile that code out. |
| `BLAS_FROM_SOURCE` | `OFF`  | If `ON`, build OpenBLAS from source via `ExternalProject_Add`; system BLAS is ignored entirely. Opt-in. Requires `MT_USE_BLAS=ON`. |
| `BLAS_PREFERENCE`  | `Auto` | Preferred system BLAS. One of `Auto`, `OpenBLAS`, `MKL`, `Apple`, `Netlib`. Ignored when `BLAS_FROM_SOURCE=ON` or `MT_USE_BLAS=OFF`. |

`MT_USE_BLAS=OFF` and `BLAS_FROM_SOURCE=ON` are mutually exclusive — configure
fails with a clear error if both are set. When `MT_USE_BLAS=ON`,
`BLAS_FROM_SOURCE=ON` short-circuits detection and `BLAS_PREFERENCE` has no
effect.

`MT_BUILD_OPENBLAS` is kept as a deprecated alias: `-DMT_BUILD_OPENBLAS=ON`
is silently mapped to `-DBLAS_FROM_SOURCE=ON` with a warning.

### Disabling BLAS entirely

```sh
# Force a BLAS-free build, even if libopenblas / libmkl / Accelerate is installed.
cmake -B build -DMT_USE_BLAS=OFF
```

This is the right choice on:

- Minimal containers / embedded systems where you don't want to pull in a
  multi-megabyte BLAS dependency for the few optional code paths that use it.
- Build hosts where the system BLAS is broken, or unsupported (e.g. an older
  Accelerate-only macOS where the LAPACKE C interface is unavailable and you
  don't want OpenBLAS from source either).
- CI matrix entries that explicitly cover the "no BLAS" configuration.

Effect of `MT_USE_BLAS=OFF`:

- No `find_package(BLAS)` is invoked anywhere in the superbuild.
- `BLAS::BLAS` / `LAPACKE::LAPACKE` are empty interface targets (so
  `if(TARGET ...)` checks still resolve), but they carry no link libraries and
  no `HAVE_LAPACKE` compile definition.
- `blas_external_project_args()` emits empty `-DBLAS_LIBRARIES=`, empty
  `-DBLAS_MKL_MODE=`, etc. The EP children (BEaST, patch_morphology) gate
  their BLAS-using code on these variables being non-empty, so the code
  compiles out cleanly.
- BEaST's SPAMS sparse-segmentation path stays off (it is off by default
  anyway — `MT_SPARSE_BEAST=OFF`).
- patch_morphology's NNLS path stays off (`HAVE_OPENBLAS=OFF`, gated in
  `patch_morphology/src/CMakeLists.txt`).

## How `BLAS_PREFERENCE` maps to detection

| Preference | Maps to | Notes |
| --- | --- | --- |
| `Auto`     | `BLA_VENDOR=""`         | Lets `find_package(BLAS)` pick whatever it finds first. |
| `OpenBLAS` | `BLA_VENDOR=OpenBLAS`   | |
| `MKL`      | `find_package(MKL CONFIG)` first; on failure, `BLA_VENDOR=Intel10_64lp` | See *Intel oneAPI MKL* below. |
| `Apple`    | `BLA_VENDOR=Apple`      | macOS Accelerate framework. |
| `Netlib`   | `BLA_VENDOR=Generic`    | Reference Netlib BLAS. |

Anything else fails configure with `Invalid BLAS_PREFERENCE='<value>'`.

## Intel oneAPI MKL

When `BLAS_PREFERENCE=MKL`, the build first tries Intel oneAPI's
`MKLConfig.cmake` package (which provides a curated `MKL::MKL` target with
the right threading/interface choice). If that succeeds, `BLAS::BLAS` wraps
`MKL::MKL` and the standard `find_package(BLAS)` path is bypassed. To make
this work on a host with oneAPI installed:

```sh
# Either source the oneAPI environment...
source /opt/intel/oneapi/setvars.sh

# ...or point CMake at MKLConfig.cmake explicitly:
cmake -B build -DBLAS_PREFERENCE=MKL -DCMAKE_PREFIX_PATH=/opt/intel/oneapi/mkl/latest/lib/cmake/mkl
```

If `MKLConfig.cmake` is not found, the build falls back to
`find_package(BLAS)` with `BLA_VENDOR=Intel10_64lp`. That fallback works
when MKL is installed but oneAPI's CMake config-package isn't on
`CMAKE_PREFIX_PATH` — e.g. older system-package MKL installs.

The configure log emits `BLAS_MKL_MODE=[Config]` or `BLAS_MKL_MODE=[FindBLAS]`
so you can tell which path was taken.

## Two-mode integration contract

Subprojects participate in BLAS in one of two ways. Both end up with the
same `BLAS::BLAS` target available.

### In-tree (`add_subdirectory`)

`BLAS::BLAS` is created at the superbuild scope as `INTERFACE IMPORTED
GLOBAL`, which makes it visible across `add_subdirectory` boundaries.
A subproject's `CMakeLists.txt` simply does:

```cmake
target_link_libraries(my_target PRIVATE BLAS::BLAS)
```

No `find_package(BLAS)` in the subproject — detection is forbidden there.

### Out-of-tree (`ExternalProject_Add`)

ExternalProject children are configured by a separate top-level `cmake`
invocation and can't see the parent's targets. Instead, the parent forwards
the resolved BLAS state via `-D` flags:

```cmake
blas_external_project_args(BLAS_EP_ARGS)

ExternalProject_Add(my_subproject
  ...
  CMAKE_ARGS
    ${BLAS_EP_ARGS}
    -DSUPERBUILD_CMAKE_DIR=${PROJECT_SOURCE_DIR}/cmake
    ...
)
```

`blas_external_project_args()` always emits five flags so the child sees a
uniform shape regardless of which detection path the parent took:

- `-DBLA_VENDOR=...`
- `-DBLAS_LIBRARIES=...`
- `-DBLAS_LINKER_FLAGS=...`
- `-DBLAS_INCLUDE_DIRS=...`
- `-DBLAS_MKL_MODE=...` (`Config` | `FindBLAS` | empty)

The child's own `CMakeLists.txt` reconstructs `BLAS::BLAS` via the shim:

```cmake
include(${SUPERBUILD_CMAKE_DIR}/BLASTargetShim.cmake)
if(BLAS_MKL_MODE STREQUAL "Config")
  find_package(MKL CONFIG REQUIRED)
  blas_create_target_shim("MKL::MKL" "" "")
else()
  blas_create_target_shim("${BLAS_LIBRARIES}" "${BLAS_LINKER_FLAGS}" "${BLAS_INCLUDE_DIRS}")
endif()
target_link_libraries(my_target PRIVATE BLAS::BLAS)
```

The shim is idempotent: on CMake 3.18+ where `find_package(BLAS)` already
created `BLAS::BLAS`, calling it is a no-op.

## Standalone subproject builds

Subprojects (e.g. `patch_morphology/`, `BEaST/`) remain standalone-buildable
outside the superbuild. They guard the superbuild path with `MINC_TOOLKIT_BUILD`:

```cmake
if(NOT MINC_TOOLKIT_BUILD)
  # Standalone: do our own find_package(BLAS) here.
else()
  # Superbuild: reconstruct BLAS::BLAS from the parent's forwarded -D flags.
endif()
```

Standalone builds may use `find_package(BLAS)` directly. The superbuild
contract — "all detection lives in the superbuild layer" — only applies
when `MINC_TOOLKIT_BUILD` is on.

## LAPACKE (the C interface to LAPACK)

CMake ships no `FindLAPACKE` module, so the superbuild defines a parallel
imported target `LAPACKE::LAPACKE` alongside `BLAS::BLAS`. It is always
defined after `include(BLASSetup)` — even when LAPACKE is unavailable —
so subprojects can guard their `<lapacke.h>` includes with
`#ifdef HAVE_LAPACKE` rather than testing `if(TARGET LAPACKE::LAPACKE)`.

| BLAS preference | LAPACKE source | `HAVE_LAPACKE` defined? |
| --- | --- | --- |
| `OpenBLAS` (system or from-source) | bundled in libopenblas; `LAPACKE::LAPACKE` aliases `BLAS::BLAS` | Yes when `lapacke.h` is findable on system, or always when `BLAS_FROM_SOURCE=ON` (the EP is built with `-DLAPACKE=ON`) |
| `MKL` | bundled in libmkl; `LAPACKE::LAPACKE` aliases `BLAS::BLAS` | Yes when `lapacke.h` is findable |
| `Auto` | same as whichever was resolved (typically OpenBLAS) | Yes when `lapacke.h` is findable |
| `Netlib` / `ATLAS` | separate `liblapacke` + standalone `lapacke.h`; both must be present on `CMAKE_LIBRARY_PATH` / `CMAKE_INCLUDE_PATH` (or default search paths) | Yes when both are found, otherwise the target is a stub and a warning is emitted |
| `Apple` | not available — Accelerate exposes only the Fortran LAPACK ABI | **No.** A warning is emitted at configure time and `LAPACKE_VIA_ACCELERATE=0` is added to `INTERFACE_COMPILE_DEFINITIONS` so subprojects can compile-out lapacke-using code |

### Subproject usage pattern

```cmake
# In a subproject's CMakeLists.txt
target_link_libraries(my_target PRIVATE LAPACKE::LAPACKE)
```

```c
// In the source file
#ifdef HAVE_LAPACKE
#include <lapacke.h>
// ... LAPACKE_dgesv, LAPACKE_dgelsd, etc.
#else
// fallback or compile-out
#endif
```

The `target_link_libraries` line is unconditional — `LAPACKE::LAPACKE`
always exists. The `#ifdef HAVE_LAPACKE` is what guards the actual
`lapacke.h` inclusion. On Apple, on Netlib without `liblapacke-dev`, or on
hosts where the OpenBLAS package omits `lapacke.h`, `HAVE_LAPACKE` is
simply not defined and the lapacke-using code is compiled out.

### Apple caveat

If you are on macOS and need LAPACKE, do not use `BLAS_PREFERENCE=Apple`.
Use `BLAS_PREFERENCE=OpenBLAS` (homebrew or `BLAS_FROM_SOURCE=ON`) instead.

## Files

- `cmake-modules/BLASSetup.cmake` — top-level orchestrator, included by root `CMakeLists.txt`
- `cmake-modules/BLASVendorMap.cmake` — `blas_vendor_from_preference()`
- `cmake-modules/BLASMKLSetup.cmake` — MKL config-package + FindBLAS fallback
- `cmake-modules/BLASSourceBuild.cmake` — OpenBLAS-from-source path (`BLAS_FROM_SOURCE=ON`)
- `cmake-modules/BLASTargetShim.cmake` — `blas_create_target_shim()` for CMake < 3.18 and config-package wrapping
- `cmake-modules/BLASExternalProjectArgs.cmake` — `blas_external_project_args()`
- `cmake-modules/LAPACKESetup.cmake` — `lapacke_setup()` (per-implementation LAPACKE handling)
- `cmake-modules/LAPACKETargetShim.cmake` — `lapacke_create_target_shim()` for ExternalProject children
- `tests/blas_integration/` — end-to-end smoke test (3 sub-tests: Auto / OpenBLAS / Netlib)
