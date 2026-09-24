# Nix setup for fish shell
# This ensures Nix paths are available in all fish sessions

# Set Nix profile paths
if test -d /nix/var/nix/profiles/default
    set -gx NIX_PROFILES "/nix/var/nix/profiles/default $HOME/.nix-profile"
end

# Add Nix paths to PATH if not already present
if test -d "$HOME/.nix-profile/bin"
    if not contains "$HOME/.nix-profile/bin" $PATH
        set -gx PATH "$HOME/.nix-profile/bin" $PATH
    end
end

if test -d /nix/var/nix/profiles/default/bin
    if not contains /nix/var/nix/profiles/default/bin $PATH
        set -gx PATH /nix/var/nix/profiles/default/bin $PATH
    end
end

# Set NIX_PATH when channels are available.
set -l nix_channels "$HOME/.local/state/nix/profiles/channels"
set -l nix_defexpr "$HOME/.nix-defexpr/channels"

if test -e "$nix_channels/nixpkgs"
    set -gx NIX_PATH "nixpkgs=$nix_channels/nixpkgs:$nix_defexpr"
else if test -e "$nix_defexpr/nixpkgs"
    set -gx NIX_PATH "nixpkgs=$nix_defexpr/nixpkgs:$nix_defexpr"
else if test -d "$nix_defexpr"
    set -gx NIX_PATH "$nix_defexpr"
end

# Set NIX_SSL_CERT_FILE for macOS
if test -f /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt
    set -gx NIX_SSL_CERT_FILE /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt
end
