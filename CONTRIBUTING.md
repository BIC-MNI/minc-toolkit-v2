# Contributing to MINC Toolkit

Please follow the [Code of Conduct](CODE_OF_CONDUCT.md) in project discussions.
Bug reports, documentation improvements, and focused fixes are welcome through
[issues](https://github.com/BIC-MNI/minc-toolkit-v2/issues) and
[pull requests](https://github.com/BIC-MNI/minc-toolkit-v2/pulls).
Search existing issues and pull requests before starting. For larger changes,
discuss the approach in an issue first to coordinate with the maintainers.

## Choose the right repository

This repository assembles multiple packages using Git submodules and CMake
external projects. Changes to the toolkit configuration, packaging, or bundled
versions belong here. Changes to a package's implementation belong in that
package's repository; see [.gitmodules](.gitmodules) for submodule URLs. Link
related package and toolkit pull requests when a change needs both. A toolkit
submodule update should identify the old and new commits and explain why the
new revision is needed.

## Set up a development checkout

Fork the repository and create a focused branch from `master`. Clone your fork
with submodules (replace `YOUR-USERNAME` below):

```sh
git clone --recursive https://github.com/YOUR-USERNAME/minc-toolkit-v2.git
cd minc-toolkit-v2
git checkout -b my-change
```

For an existing checkout, initialize its recorded submodule revisions with
`git submodule update --init --recursive`. Avoid updating every submodule to
its latest branch tip as part of an unrelated change.

## Configure and build

Use a C and C++ toolchain and CMake. The root `CMakeLists.txt` declares a minimum
CMake version of 3.6.1; the minimum alone does not establish compatibility with
every newer CMake release. The [README](README.md#dependencies) lists dependency
packages, including Perl, Bison, Flex, bc, and JPEG libraries. Visual tools also
need X11 and OpenGL development libraries. The bundled OpenBLAS build requires
a Fortran compiler when `MT_BUILD_OPENBLAS` is enabled. External projects download
sources during the build, so allow network access and sufficient disk space.

The README documents Linux dependency installation; macOS packaging is also
represented by the `homebrew` directory and Apple-specific CMake configuration.
Report the exact operating system and toolchain used rather than assuming a
configuration works on every platform.

Use a separate build directory. This example uses the default build options and
a user-writable installation prefix:

```sh
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$HOME/minc-development"
cmake --build .
```

Inspect options with `ccmake ..` if available. For example, `MT_BUILD_LITE`
disables ITK and visual tools, while `MT_BUILD_VISUAL_TOOLS` enables the visual
packages. The README recommends using the bundled libraries rather than
system-provided versions. Record any `USE_SYSTEM_*` overrides when reporting a
problem. Choose options appropriate to the code being changed; a lite build
does not exercise changes to disabled packages.

Installation is optional for development. To exercise installation, run
`cmake --build . --target install` from the configured build directory, using a
prefix you can write. Source the installed `minc-toolkit-config.sh` to set up
the toolkit environment before checking installed commands.

## Validate a change

CTest is included by the root CMake configuration. For changes that affect
code or the build, configure with `-DBUILD_TESTING=ON`, build, then run from the
build directory:

```sh
ctest -N
ctest --output-on-failure
```

`ctest -N` lists the tests registered by that configuration. External packages
have their own testing settings, and some bundled dependencies explicitly
disable their tests. A passing top-level test run therefore does not imply that
every dependency was tested. Include relevant package tests or an installed
command check when needed to exercise the changed behavior.

For documentation-only changes, check the instructions, referenced paths, and
formatting; a full toolkit build is usually unnecessary. State which checks
were actually run and describe any checks that could not be performed.

## Prepare commits and a pull request

Follow the formatting and conventions in the files being changed. Keep fixes
focused, preserve existing license notices, and avoid unrelated formatting,
generated build files, or submodule updates.

Each commit should have a descriptive subject and explain the reason for a
non-obvious change in its body. Include the relevant issue reference when one
exists. Do not put private imaging data or credentials in commits, logs, or
attachments; use a small shareable reproducer for bug reports.

Open the pull request against `master` in `BIC-MNI/minc-toolkit-v2`. Include:

- The problem and the resulting behavior, with a related issue link if available.
- The scope of the change, including any dependency or submodule revisions.
- The validation performed and its result. For build or runtime checks, include
  the operating system, compiler, CMake version, and relevant configuration options.
- Any known limitations or untested configurations.

For a bug report, provide the toolkit version or commit, the affected command
and exact arguments, expected and observed behavior, and relevant error output.
Respond to review in the same pull request so the discussion stays together.
See [AGENTS.md](AGENTS.md) for the corresponding repository work checklist.
