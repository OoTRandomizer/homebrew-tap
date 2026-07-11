# OoTRandomizer Tap

## Default online installation

The formulae use the existing release links by default: the patched n64
`arm64-support-rebase` branch and the upstream armips HEAD:

```sh
brew tap ootrandomizer/tap
brew install --HEAD ootrandomizer/tap/armips ootrandomizer/tap/n64
```

`armips` must be version 0.11 or later. The `n64` formula installs the
`mips64-` compiler and binutils used by `OoT-Randomizer/ASM/build.py`.

On Apple Silicon, the formula uses GNU sed for the recursive GCC build,
propagates Homebrew GMP/MPFR/MPC paths, disables the optional GDB component by
default, and builds the toolchain serially. Other platforms keep their existing
build path. Set `HOMEBREW_OOTR_N64_BUILD_GDB=1` to deliberately build GDB, or
`HOMEBREW_OOTR_N64_JOBS=<n>` to change the Apple Silicon job count.

## Optional local sources

The online URLs remain the default. A local tap and local source directories can
be selected without editing either formula:

```sh
LOCAL_TAP=/absolute/path/to/homebrew-tap
N64_DIR=/absolute/path/to/n64
ARMIPS_DIR=/absolute/path/to/armips

brew tap ootrlocal/toolchain "$LOCAL_TAP"

export HOMEBREW_OOTR_N64_SOURCE_DIR="$N64_DIR"
export HOMEBREW_OOTR_N64_HEAD_URL="$(python3 -c 'import pathlib,sys; print(pathlib.Path(sys.argv[1]).resolve().as_uri())' "$N64_DIR")"

export HOMEBREW_OOTR_ARMIPS_SOURCE_DIR="$ARMIPS_DIR"
export HOMEBREW_OOTR_ARMIPS_HEAD_URL="$(python3 -c 'import pathlib,sys; print(pathlib.Path(sys.argv[1]).resolve().as_uri())' "$ARMIPS_DIR")"

HOMEBREW_NO_AUTO_UPDATE=1 brew install --HEAD --build-from-source \
  ootrlocal/toolchain/armips ootrlocal/toolchain/n64
```

The `*_SOURCE_DIR` variables are the actual source used for compilation. The
matching `*_HEAD_URL` variables prevent an upstream Git fetch when operating
offline.

Local GNU toolchain archives can also be selected through the n64 source's
`N64_TOOLCHAIN_ARCHIVE_DIR`, `BINUTILS_ARCHIVE`, `GCC_ARCHIVE`,
`NEWLIB_ARCHIVE`, and `GDB_ARCHIVE` variables.

## Brewfile

```ruby
tap "ootrandomizer/tap"
brew "armips", args: ["HEAD"]
brew "n64", args: ["HEAD"]
```
