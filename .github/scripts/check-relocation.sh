#!/bin/bash
# Check that an unpacked toolkit tree works from a prefix the build never named.
#
# The superbuild configures with CMAKE_INSTALL_PREFIX=/opt/minc/<version>, but
# the tarball unpacks anywhere. Every run path, every vendored library and every
# data path must therefore resolve relative to wherever the tree landed. This
# script is the gate for that claim, and ci.yml and release.yml both call it.
#
# Usage: check-relocation.sh <unpacked-prefix> <minimal|full>

set -euo pipefail

PREFIX=$(cd -- "$1" && pwd -P)
VARIANT=$2
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

# mincstats takes one volume at a time; reading each result back is the check
# that the tool that wrote it produced something usable.
means() { for v in "$@"; do printf '%s mean: ' "$v"; mincstats -quiet -mean "$v"; done; }

echo "=== 1. Config script ==="
# The script finds the prefix through BASH_SOURCE. If it instead reports the
# path baked in at configure time, nothing else in this file means anything.
# shellcheck source=/dev/null
. "$PREFIX/minc-toolkit-config.sh"
[ "${MINC_TOOLKIT:-}" = "$PREFIX" ] \
  || fail "config script set MINC_TOOLKIT=${MINC_TOOLKIT:-unset}, expected $PREFIX"
# Asserted, not assumed: the checks below rely on the config script exporting
# this, and on MNI_DATAPATH alongside it.
[ "${MINC_COMPRESS:-}" = 4 ] || fail "config script did not export MINC_COMPRESS=4"
echo "MINC_TOOLKIT=$MINC_TOOLKIT"
echo "MINC_TOOLKIT_VERSION=${MINC_TOOLKIT_VERSION:-unset}"

echo "=== 2. Dynamic linkage of every shipped ELF object ==="
# Every library the tarball ships, by soname. A system copy of any of these
# winning the search means the vendored build escaped into the distribution's
# libraries, which is the failure this whole job exists to catch.
find "$PREFIX" -name '*.so*' -printf '%f\n' | sort -u > "$WORK/shipped"

mapfile -t objects < <(
  find "$PREFIX" -type f -exec file -N {} + 2>/dev/null \
    | awk -F': ' '/ELF .*(executable|shared object)/ { print $1 }' | sort
)
[ "${#objects[@]}" -gt 0 ] || fail "found no ELF objects under $PREFIX"

: > "$WORK/resolved"
for obj in "${objects[@]}"; do
  # ldd's exit status is not dependable across glibc versions when a dependency
  # is missing, so decide what to skip from the message, not the status.
  out=$(ldd "$obj" 2>&1) || true
  case $out in *'not a dynamic executable'*) continue ;; esac
  if printf '%s\n' "$out" | grep -q 'not found'; then
    printf '%s\n' "$out" | grep 'not found' >&2
    fail "$obj has unresolved libraries"
  fi
  printf '%s\n' "$out" | awk '$2 == "=>" && $3 ~ /^\// { print $3 }' >> "$WORK/resolved"
done
sort -u "$WORK/resolved" -o "$WORK/resolved"
grep -v "^$PREFIX/" "$WORK/resolved" > "$WORK/external" || true

while read -r lib; do
  [ -n "$lib" ] || continue
  case $lib in
    /lib/*|/lib64/*|/usr/lib/*|/usr/lib64/*) ;;
    # Anywhere else means the build tree: a run path or a NEEDED entry pointing
    # at the superbuild staging area, which does not travel with the tarball.
    *) fail "resolves outside the tarball and outside the system library directories: $lib" ;;
  esac
  if grep -qxF "$(basename "$lib")" "$WORK/shipped"; then
    fail "a system copy shadows a library the tarball ships: $lib"
  fi
done < "$WORK/external"

echo "Checked ${#objects[@]} ELF objects. Libraries taken from the host:"
sed 's|.*/||' "$WORK/external" | sort -u | sed 's/^/  /'

echo "=== 3. Every installed command starts ==="
# Run each one with no arguments. Almost all print usage and exit non-zero;
# that is fine and is not what this looks at. What matters is the loader or the
# interpreter giving up, which is what a broken relocation looks like.
#
# A perl script that cannot find a module is a different problem, and not one
# this tarball introduced. Report those, and fail only on a script that is not
# already known to be in that state:
#   normalize_mri, smooth_mask, lgmask  -- ctime.pl, removed from perl core in
#                                          5.16. Fixed in BIC-MNI/inormalize#5
#                                          and BIC-MNI/conglomerate#7; drop these
#                                          three from the list when those pins
#                                          bump, so a regression cannot hide.
#   xfmdecomp.pl                        -- Math::MatrixReal (CPAN)
#   patch_segmentation_pipeline.pl      -- Parallel::ForkManager (CPAN)
# The two CPAN modules stay: nothing ships them, and #238 declares them as
# package dependencies instead.
known_perl_gap='normalize_mri|smooth_mask|lgmask|xfmdecomp[.]pl|patch_segmentation_pipeline[.]pl'
loader_error='error while loading shared libraries|cannot open shared object file|symbol lookup error|undefined symbol'

cd "$WORK"
started=0
: > "$WORK/loader-failed"
: > "$WORK/perl-gap"
for cmd in "$PREFIX"/bin/* "$PREFIX"/pipeline/*; do
  [ -f "$cmd" ] && [ -x "$cmd" ] || continue
  started=$((started + 1))
  # Capped: two commands in the full tarball write enough in 20 seconds to
  # exhaust the command-substitution buffer ("xrealloc: cannot allocate").
  # head closing the pipe also stops them early instead of at the timeout.
  out=$(timeout 20 "$cmd" </dev/null 2>&1 | head -c 65536 || true)
  if line=$(printf '%s' "$out" | grep -m1 -E "$loader_error"); then
    printf '%s: %s\n' "${cmd#"$PREFIX"/}" "$line" >> "$WORK/loader-failed"
  elif line=$(printf '%s' "$out" | grep -m1 "Can't locate"); then
    printf '%s: %s\n' "${cmd#"$PREFIX"/}" "$line" >> "$WORK/perl-gap"
  fi
done
echo "Started $started commands."

if [ -s "$WORK/perl-gap" ]; then
  echo "Perl scripts with an unmet module dependency (not a relocation defect):"
  sed 's/^/  /' "$WORK/perl-gap"
  if grep -qvE "(^|/)($known_perl_gap):" "$WORK/perl-gap"; then
    grep -vE "(^|/)($known_perl_gap):" "$WORK/perl-gap" >&2
    fail "a perl script outside the known set cannot find its modules"
  fi
fi

if [ -s "$WORK/loader-failed" ]; then
  cat "$WORK/loader-failed" >&2
  fail "$(wc -l < "$WORK/loader-failed") command(s) could not load their libraries"
fi

echo "=== 4. Core MINC tools do real work ==="
GEOM="-nelements 64 64 64 -step 2 2 2 -start -64 -64 -64 -center 0 0 0"
# Same geometry as the mni_autoreg ellipse0 test; the defaults do not overlap a
# small volume.
# shellcheck disable=SC2086
make_phantom -clobber -ellipse $GEOM phantom.mnc
# shellcheck disable=SC2086
MINC_COMPRESS=0 make_phantom -clobber -ellipse $GEOM plain.mnc
mincinfo phantom.mnc
minccalc -clobber -expression 'A[0]*2' phantom.mnc doubled.mnc
mincresample -clobber -like phantom.mnc phantom.mnc resampled.mnc
mincblur -clobber -fwhm 4 phantom.mnc blurred
means doubled.mnc resampled.mnc blurred_blur.mnc

# MINC_COMPRESS=4 comes from the config script, so the write above went through
# libminc -> HDF5 -> zlib. Prove the deflate filter really ran instead of
# trusting the variable: the same volume written with compression off is many
# times larger.
packed=$(stat -c%s phantom.mnc)
plain=$(stat -c%s plain.mnc)
echo "phantom.mnc: $packed bytes compressed, $plain bytes uncompressed"
[ "$packed" -lt "$((plain / 2))" ] \
  || fail "MINC_COMPRESS=4 gained nothing ($packed vs $plain); the zlib path did not run"

echo "=== 5. ITK-based MINC tools ==="
# EZminc and patch_morphology are built for both variants, and they are the
# tools that load the vendored ITK out of lib/InsightToolkit.
itk_resample --clobber phantom.mnc itk_resampled.mnc --like phantom.mnc
itk_morph --clobber --exp 'D[1]' phantom.mnc itk_morphed.mnc
itk_distance --clobber phantom.mnc itk_distance.mnc
itk_convert --clobber phantom.mnc phantom.nii   # ITK NIfTI IO
minc_anlm --clobber phantom.mnc denoised.mnc    # ITK + OpenBLAS
means itk_resampled.mnc itk_morphed.mnc itk_distance.mnc denoised.mnc
[ -s phantom.nii ] || fail "itk_convert wrote an empty NIfTI file"

if [ "$VARIANT" != full ]; then
  echo "Variant is $VARIANT; ANTs, C3D, Elastix and ABC are not in this tarball."
  echo "OK: $PREFIX relocated cleanly."
  exit 0
fi

echo "=== 6. Bundled third-party commands ==="
# Named rather than probed: a tool missing from the full tarball has to be red,
# not silently skipped.
for cmd in antsRegistration antsApplyTransforms N4BiasFieldCorrection ImageMath \
           c3d elastix transformix ABC_MINC \
           Display register register_resample postf ray_trace xdisp; do
  [ -x "$PREFIX/bin/$cmd" ] || fail "$cmd is missing from the full tarball"
done

# ANTs and C3D, on the volumes written above.
N4BiasFieldCorrection -d 3 -i phantom.mnc -o n4.mnc
antsApplyTransforms -d 3 -i phantom.mnc -r phantom.mnc -o ants_warped.mnc
ImageMath 3 ants_math.mnc + phantom.mnc 1
c3d phantom.nii -info
c3d phantom.nii -smooth 1mm -o c3d_smoothed.nii
means n4.mnc ants_warped.mnc ants_math.mnc
[ -s c3d_smoothed.nii ] || fail "c3d wrote an empty NIfTI file"

# Elastix needs a parameter file to do anything; its version banner is enough to
# show the binary and its ITK libraries loaded. ABC has neither --version nor
# --help and exits 1 on a usage error, so starting it is the whole check, and
# step 3 already did that.
elastix --version
transformix --version

# The visual tools need a display, so step 3 -- which starts every command and
# only objects to the loader giving up -- is as far as this can go for them.

echo "OK: $PREFIX relocated cleanly."
