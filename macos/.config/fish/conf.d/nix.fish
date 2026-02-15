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

# Set NIX_PATH if not set
if not set -q NIX_PATH
    set -gx NIX_PATH "nixpkgs=$HOME/.local/state/nix/profiles/channels/nixpkgs-unstable:$HOME/.nix-defexpr/channels"
end

# Set NIX_SSL_CERT_FILE for macOS
if test -f /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt
    set -gx NIX_SSL_CERT_FILE /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt
end
