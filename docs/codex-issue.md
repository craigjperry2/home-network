# Codex Build Failure with Vendored C Libraries (`dontCargoUseSystemLibs`)

## Context

When running `sns` (`sudo nixos-rebuild switch --flake .#s1`) on `s1`, system derivation builds failed during compilation. Although suspected to be an NVIDIA/CUDA driver or kernel module failure, the failure actually originated from `codex-0.167.0` (imported from `nixpkgs-unstable` into system packages in `nix/modules/system/linux.nix`).

## Root Cause

### 1. Nixpkgs Rust `cargoUseSystemLibs` Hook
Nixpkgs' Rust build infrastructure (`pkgs/build-support/rust/hooks/cargo-setup-hook.sh`) injects a hook called `cargoUseSystemLibs` in `preConfigureHooks`. Its goal is to un-vendor common C libraries embedded in Cargo `-sys` crates and force dynamic linking against Nixpkgs packages:

```bash
cargoUseSystemLibs() {
  export SYSTEM_DEPS_BUILD_INTERNAL="never"
  export AWS_LC_SYS_USE_SYSTEM="1"
  export OPENSSL_NO_VENDOR="1"
  export LIBZ_SYS_STATIC="0"
  export LIBSQLITE3_SYS_USE_PKG_CONFIG="1"
  export ZSTD_SYS_USE_PKG_CONFIG="1"
  ...
}
```

### 2. Missing Build Inputs in Upstream `codex`
In upstream Nixpkgs (`pkgs/by-name/co/codex/package.nix`), `codex` declared `openssl` in `buildInputs`, but did not declare `aws-lc` or `zstd`.

When Cargo executed during `buildPhase`:
1. `aws-lc-sys-0.45.0` detected `AWS_LC_SYS_USE_SYSTEM=1`.
2. It searched system include paths for AWS-LC headers (specifically `openssl/base.h`).
3. Finding only standard OpenSSL headers (which lack `base.h`), it panicked:
   ```text
   cargo:warning=Ignoring candidate AWS-LC at /nix/store/...-openssl-3.5.9-dev: Failed to read .../include/openssl/base.h: No such file or directory (os error 2)
   thread 'main' panicked at /build/codex-0.167.0-vendor/source-registry-0/aws-lc-sys-0.45.0/builder/main.rs:767:9:
   AWS_LC_SYS_USE_SYSTEM=1 requires a system-installed AWS-LC, but none was found.
   Set AWS_LC_SYS_SYSTEM_DIR to point at an install, provide OPENSSL_DIR, or unset AWS_LC_SYS_USE_SYSTEM to build from source.
   ```
4. If `aws-lc` was manually added to `buildInputs`, the build then failed on `zstd-sys` because `ZSTD_SYS_USE_PKG_CONFIG=1` expected `libzstd.pc`, which was also not present in `buildInputs`.

### 3. Why Hydra and the Binary Cache Had No Pre-built Binary
Normally, packages in `nixpkgs-unstable` are pre-built by Hydra and downloaded as binary substitutes from `cache.nixos.org`. However, because of this exact upstream packaging error, Hydra's build for `codex-0.167.0` also failed. With no binary cached in `cache.nixos.org`, Nix fell back to building the derivation from source locally on `s1`.

## Fix

In `nix/modules/system/linux.nix`, override `codex` to disable the `cargoUseSystemLibs` hook:

```nix
nixpkgs.overlays = [
  (
    _: _prev: {
      inherit (unstable) claude-code github-copilot-cli herdr nixd alejandra statix deadnix;
      codex = unstable.codex.overrideAttrs {
        dontCargoUseSystemLibs = true;
      };
    }
  )
];
```

Setting `dontCargoUseSystemLibs = true` prevents the hook from registering into `preConfigureHooks`, allowing Cargo to compile the vendored C code bundled within `aws-lc-sys` and `zstd-sys` cleanly.

## Alternatives Considered

1. **Stable Channel `pkgs.codex` (v0.146.0):**
   - The stable release channel (`nixos-26.05`) packages `codex-0.146.0`, which evaluated and built successfully on Hydra.
   - It is available as a pre-built binary on `cache.nixos.org` (~140 MiB download, 0 compilation time).
2. **Upstream GitHub Release Musl Binaries:**
   - OpenAI publishes static musl pre-compiled binaries on GitHub releases (`codex-x86_64-unknown-linux-musl.tar.gz`).
   - A custom derivation could unpack that binary directly without compiling Rust code from source.
