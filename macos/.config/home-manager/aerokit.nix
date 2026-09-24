{ pkgs, ... }:

let
  version = "0.1.2";
  aerokit = pkgs.stdenvNoCC.mkDerivation {
    pname = "aerokit";
    inherit version;

    # Upstream signed/notarized universal release. Homebrew is not part of
    # this machine's package management.
    src = pkgs.fetchurl {
      url = "https://github.com/jomatsu/aerokit/releases/download/v${version}/AeroKit-${version}.zip";
      sha256 = "9af5711743e096a3e6d71c5c6449b1d0ae7e09a4044849dbae29d6bec3ee7b4a";
    };

    dontUnpack = true;
    dontBuild = true;
    nativeBuildInputs = [ pkgs.makeWrapper pkgs.unzip ];

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/Applications" "$out/bin"
      ${pkgs.unzip}/bin/unzip -q "$src" -d "$out/Applications"
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
