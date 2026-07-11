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

On Apple Silicon, the n64 formula uses GNU sed, propagates Homebrew prerequisite
paths, disables GDB by default for compatibility, and uses one build job by
default. Set `HOMEBREW_N64_BUILD_GDB=1` to enable GDB or
`HOMEBREW_N64_JOBS=<n>` to choose another job count.

## Optional local sources

Online Git sources remain the default. Local source directories can be selected
without editing the formulae:

```sh
LOCAL_TAP=/absolute/path/to/homebrew-tap
N64_DIR=/absolute/path/to/n64
ARMIPS_DIR=/absolute/path/to/armips

brew tap ootrlocal/toolchain "$LOCAL_TAP"

export HOMEBREW_N64_SOURCE_DIR="$N64_DIR"
export HOMEBREW_N64_HEAD_URL="$(python3 -c 'import pathlib,sys; print(pathlib.Path(sys.argv[1]).resolve().as_uri())' "$N64_DIR")"

export HOMEBREW_ARMIPS_SOURCE_DIR="$ARMIPS_DIR"
export HOMEBREW_ARMIPS_HEAD_URL="$(python3 -c 'import pathlib,sys; print(pathlib.Path(sys.argv[1]).resolve().as_uri())' "$ARMIPS_DIR")"

HOMEBREW_NO_AUTO_UPDATE=1 brew install --HEAD --build-from-source \
  ootrlocal/toolchain/armips ootrlocal/toolchain/n64
```

The `*_SOURCE_DIR` variables select the source used for compilation. The
matching `*_HEAD_URL` variables avoid an upstream Git fetch for offline builds.
GNU toolchain archives can be selected with `N64_TOOLCHAIN_ARCHIVE_DIR`,
`BINUTILS_ARCHIVE`, `GCC_ARCHIVE`, `NEWLIB_ARCHIVE`, and `GDB_ARCHIVE`.

## Brewfile

```ruby
tap "ootrandomizer/tap"
brew "armips", args: ["HEAD"]
brew "n64", args: ["HEAD"]
```
