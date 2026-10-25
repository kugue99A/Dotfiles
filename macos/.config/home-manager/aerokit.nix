{ pkgs, ... }:

let
  version = "0.1.2";
  release = pkgs.fetchurl {
    url = "https://github.com/jomatsu/aerokit/releases/download/v${version}/AeroKit-${version}.zip";
    sha256 = "9af5711743e096a3e6d71c5c6449b1d0ae7e09a4044849dbae29d6bec3ee7b4a";
  };
  aerokit = pkgs.stdenvNoCC.mkDerivation {
    pname = "aerokit";
    inherit version;

    src = pkgs.fetchzip {
      url = "https://github.com/jomatsu/aerokit/archive/refs/tags/v${version}.tar.gz";
      sha256 = "0q4zddqg1f9ly5qk3zwprv1fi9gyrgsr9nmiw8fwyflyyi2fzjs0";
    };

    # SwiftUI requires the host's Apple toolchain and macOS SDK. The local Nix
    # daemon runs with sandboxing disabled, so listing these paths as
    # __impureHostDeps would additionally require a root-owned global allowlist.
    dontStrip = true;
    nativeBuildInputs = [ pkgs.makeWrapper pkgs.unzip ];

    postPatch = ''
      cp ${./aerokit/AeroSpaceSocketRunner.swift} packages/app/Sources/AeroKitCore/AeroSpaceSocketRunner.swift
    '';

    buildPhase = ''
      runHook preBuild
      export DEVELOPER_DIR=$(/usr/bin/xcode-select -p)
      export SDKROOT=$(/usr/bin/xcrun --sdk macosx --show-sdk-path)
      export CLANG_MODULE_CACHE_PATH="$TMPDIR/clang-module-cache"
      export SWIFTPM_MODULECACHE_OVERRIDE="$TMPDIR/swift-module-cache"
      /usr/bin/swift build --disable-sandbox --package-path packages/app \
        --scratch-path "$PWD/.build" --cache-path "$TMPDIR/swift-cache" \
        --config-path "$TMPDIR/swift-config" --security-path "$TMPDIR/swift-security" \
        --configuration release --product AeroKit --jobs 4
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/Applications" "$out/bin"
      ${pkgs.unzip}/bin/unzip -q ${release} -d "$out/Applications"
      chmod -R u+w "$out/Applications/AeroKit.app"
      install -m755 .build/release/AeroKit "$out/Applications/AeroKit.app/Contents/MacOS/AeroKit"
      /usr/bin/codesign --force --sign - "$out/Applications/AeroKit.app"
      /usr/bin/codesign --verify --deep --strict "$out/Applications/AeroKit.app"
      makeWrapper "$out/Applications/AeroKit.app/Contents/MacOS/AeroKit" "$out/bin/aerokit"

      runHook postInstall
    '';
  };
in
{
  home.packages = [ aerokit ];

  # AeroKit is launched as a macOS login item, so it does not inherit the
  # Nix profile PATH. Make AeroSpace available at one of AeroKit's supported
  # discovery paths instead of assuming a Homebrew installation.
  home.file.".local/bin/aerospace".source = "${pkgs.aerospace}/bin/aerospace";
}
