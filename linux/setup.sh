#!/usr/bin/env bash
#
# setup.sh — Bootstrap a fresh Debian system with Hyprland desktop
#
# Run as your regular user with sudo access configured.
# Do NOT run as root.
#
# Usage (from a fresh machine, once git is available):
#   git clone https://github.com/louen/config-files.git ~/devel/config-files
#   bash ~/devel/config-files/linux/setup.sh
#
# Or, if you only have wget:
#   wget -O setup.sh https://raw.githubusercontent.com/louen/config-files/main/linux/setup.sh
#   bash setup.sh   # will clone the repo automatically

set -euo pipefail

# ─── Helpers ──────────────────────────────────────────────────────────────────

bold=$'\e[1m'; red=$'\e[0;31m'; green=$'\e[0;32m'
yellow=$'\e[1;33m'; blue=$'\e[0;34m'; cyan=$'\e[0;36m'; reset=$'\e[0m'

info()    { printf '%s[INFO]%s %s\n' "$cyan$bold"   "$reset" "$*"; }
ok()      { printf '%s[ OK ]%s %s\n' "$green$bold"  "$reset" "$*"; }
warn()    { printf '%s[WARN]%s %s\n' "$yellow$bold" "$reset" "$*"; }
err()     { printf '%s[ERR ]%s %s\n' "$red$bold"    "$reset" "$*" >&2; }
section() { printf '\n%s══════════════════════════════\n  %s\n══════════════════════════════%s\n' \
            "$blue$bold" "$*" "$reset"; }

die()         { err "$*"; exit 1; }
press_enter() { printf '%s[>>>]%s Press Enter to continue (Ctrl-C to abort)... ' "$yellow$bold" "$reset"; read -r; }

yes_no() {
    local q="$1" default="${2:-y}" hint ans
    [[ "$default" == y ]] && hint="[Y/n]" || hint="[y/N]"
    while true; do
        printf '%s[ ? ]%s %s %s ' "$yellow$bold" "$reset" "$q" "$hint"; read -r ans
        ans="${ans:-$default}"
        case "$ans" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) warn "Please answer y or n." ;;
        esac
    done
}

ask() { printf '%s[ ? ]%s %s' "$yellow$bold" "$reset" "$*"; read -r REPLY; }


# ─── Pre-flight ───────────────────────────────────────────────────────────────

section "Pre-flight checks"

[[ $EUID -ne 0 ]] || die "Do not run as root. Run as your regular user (sudo will be called when needed)."
sudo -v             || die "sudo access is required. Configure /etc/sudoers for $USER first, then re-run."

CURRENT_USER="$(id -un)"
info "Running as: $CURRENT_USER"

if ! ping -c1 -W3 debian.org &>/dev/null; then
    warn "Cannot reach debian.org — check your network connection."
    press_enter
fi

ok "Pre-flight passed"


# ─── Repo ─────────────────────────────────────────────────────────────────────

section "Config repository"

# If run from inside the repo (normal case), use the repo root.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$( dirname "$SCRIPT_DIR" )"

if [[ ! -d "$REPO_DIR/.git" ]]; then
    # Script was downloaded standalone — need to clone.
    DEFAULT_DIR="$HOME/devel/config-files"
    ask "Where should the config repo be cloned? [default: $DEFAULT_DIR] "
    REPO_DIR="${REPLY:-$DEFAULT_DIR}"
    REPO_DIR="${REPO_DIR/#\~/$HOME}"
fi

REPO_URL="https://github.com/louen/config-files.git"

if [[ -d "$REPO_DIR/.git" ]]; then
    info "Repo found at $REPO_DIR — pulling latest..."
    git -C "$REPO_DIR" pull
else
    info "Cloning $REPO_URL → $REPO_DIR"
    mkdir -p "$(dirname "$REPO_DIR")"
    git clone "$REPO_URL" "$REPO_DIR"
fi

ok "Repo ready: $REPO_DIR"


# ─── APT sources ──────────────────────────────────────────────────────────────

section "APT sources"

# Detect current Debian suite (e.g. forky, trixie, bookworm…)
SUITE="$(. /etc/os-release && echo "$VERSION_CODENAME")"
info "Detected Debian suite: $SUITE"

# Ensure non-free and non-free-firmware components are enabled (needed for Nvidia).
DEBIAN_SOURCES="/etc/apt/sources.list.d/debian.sources"
if [[ -f "$DEBIAN_SOURCES" ]]; then
    if ! grep -q "non-free-firmware" "$DEBIAN_SOURCES"; then
        warn "non-free / non-free-firmware components not found in $DEBIAN_SOURCES."
        warn "These are required for the Nvidia driver."
        warn "Edit $DEBIAN_SOURCES and add 'contrib non-free non-free-firmware' to Components, then re-run."
        press_enter
    else
        ok "non-free components present in $DEBIAN_SOURCES"
    fi
else
    warn "Could not find $DEBIAN_SOURCES — verify that non-free repos are enabled before proceeding."
    press_enter
fi


# ─── System packages ──────────────────────────────────────────────────────────

section "System packages"

PKGS_BASE=(
    git vim zsh htop curl wget gnupg apt-transport-https ca-certificates
)

PKGS_DESKTOP=(
    hyprland kitty waybar wofi hyprlock hypridle hyprpaper
    greetd tuigreet
    pamixer imv
    fonts-firacode
    pipewire wireplumber pipewire-pulse
)

PKGS_NVIDIA=(
    nvidia-driver firmware-misc-nonfree
)

sudo apt-get update

info "Installing base packages..."
sudo apt-get install -y "${PKGS_BASE[@]}"

info "Installing Hyprland desktop packages..."
sudo apt-get install -y "${PKGS_DESKTOP[@]}"

info "Installing Nvidia drivers..."
sudo apt-get install -y "${PKGS_NVIDIA[@]}"

ok "System packages installed"


# ─── External APT repositories (DEB822 format) ────────────────────────────────

section "External APT repositories"

# Helper: add a repo using DEB822 .sources format, then install a package.
# Usage: add_deb822_repo <name> <keyring_path> <key_url> <sources_content> <package>
add_deb822_repo() {
    local name="$1" keyring="$2" key_url="$3" sources_content="$4" package="$5"

    if dpkg -s "$package" &>/dev/null; then
        ok "$name already installed"
        return
    fi

    info "Adding $name repo..."
    curl -fsSL "$key_url" | gpg --dearmor | sudo tee "$keyring" > /dev/null
    printf '%s\n' "$sources_content" | sudo tee "/etc/apt/sources.list.d/${name}.sources" > /dev/null
    sudo apt-get update
    sudo apt-get install -y "$package"
    ok "$name installed"
}

# VS Code
add_deb822_repo "vscode" \
    "/usr/share/keyrings/microsoft.gpg" \
    "https://packages.microsoft.com/keys/microsoft.asc" \
    "Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/microsoft.gpg" \
    "code"

# Spotify
add_deb822_repo "spotify" \
    "/usr/share/keyrings/spotify.gpg" \
    "https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg" \
    "Types: deb
URIs: https://repository.spotify.com/
Suites: stable
Components: non-free
Signed-By: /usr/share/keyrings/spotify.gpg" \
    "spotify-client"

# Signal Desktop
add_deb822_repo "signal-desktop" \
    "/usr/share/keyrings/signal-desktop-keyring.gpg" \
    "https://updates.signal.org/desktop/apt/keys.asc" \
    "Types: deb
URIs: https://updates.signal.org/desktop/apt
Suites: xenial
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/signal-desktop-keyring.gpg" \
    "signal-desktop"

# 1Password (also requires a debsig policy for package verification)
if ! dpkg -s 1password &>/dev/null; then
    info "Adding 1Password repo..."

    KEYRING_1P="/usr/share/keyrings/1password-archive-keyring.gpg"
    curl -fsSL "https://downloads.1password.com/linux/keys/1password.asc" \
        | gpg --dearmor | sudo tee "$KEYRING_1P" > /dev/null

    printf 'Types: deb\nURIs: https://downloads.1password.com/linux/debian/amd64/\nSuites: stable\nComponents: main\nSigned-By: %s\n' \
        "$KEYRING_1P" \
        | sudo tee /etc/apt/sources.list.d/1password.sources > /dev/null

    # debsig policy (required by the 1Password package itself)
    DEBSIG_POL_DIR="/etc/debsig/policies/AC2D62742012EA22"
    DEBSIG_KEY_DIR="/usr/share/debsig/keyrings/AC2D62742012EA22"
    sudo mkdir -p "$DEBSIG_POL_DIR" "$DEBSIG_KEY_DIR"
    sudo curl -fsSL "https://downloads.1password.com/linux/debian/debsig/1password.pol" \
        -o "$DEBSIG_POL_DIR/1password.pol"
    curl -fsSL "https://downloads.1password.com/linux/keys/1password.asc" \
        | gpg --dearmor | sudo tee "$DEBSIG_KEY_DIR/debsig.gpg" > /dev/null

    sudo apt-get update
    sudo apt-get install -y 1password
    ok "1Password installed"
else
    ok "1Password already installed"
fi


# ─── Shell ────────────────────────────────────────────────────────────────────

section "Shell (zsh)"

ZSH_BIN="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_BIN" ]]; then
    info "Changing default shell to zsh..."
    sudo chsh -s "$ZSH_BIN" "$CURRENT_USER"
    ok "Default shell → zsh (takes effect on next login)"
else
    ok "zsh is already the default shell"
fi

info "Installing zsh config symlinks..."
bash "$REPO_DIR/shells/zsh/install-home.sh"
ok "Zsh symlinks done"


# ─── Vim ──────────────────────────────────────────────────────────────────────

section "Vim"

bash "$REPO_DIR/vim/install-home.sh"
ok "Vim symlinks done"


# ─── Hyprland config symlinks ─────────────────────────────────────────────────

section "Hyprland config symlinks"

mkdir -p "$HOME/.config"

symlink_config() {
    local src="$1" dst="$2"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        warn "$dst exists and is not a symlink — backing up to $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    rm -f "$dst"
    ln -s "$src" "$dst"
    ok "  $dst → $src"
}

symlink_config "$REPO_DIR/linux/hypr"   "$HOME/.config/hypr"
symlink_config "$REPO_DIR/linux/kitty"  "$HOME/.config/kitty"
symlink_config "$REPO_DIR/linux/waybar" "$HOME/.config/waybar"
symlink_config "$REPO_DIR/linux/wofi"   "$HOME/.config/wofi"


# ─── Git config ───────────────────────────────────────────────────────────────

section "Git config"

if [[ -f "$HOME/.gitconfig" ]]; then
    info "~/.gitconfig already exists — skipping (edit manually if needed)"
else
    warn "~/.gitconfig will be created from the repo template."
    warn "Your name and email are NOT stored in the repo — you will be prompted."
    ask "git user.name: "
    GIT_NAME="$REPLY"
    ask "git user.email: "
    GIT_EMAIL="$REPLY"

    # Copy the template (aliases, tools, etc.) and fill in personal details.
    # The repo template uses placeholder values for user.name / user.email.
    cp "$REPO_DIR/linux/gitconfig" "$HOME/.gitconfig"
    git config --global user.name  "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    ok "~/.gitconfig written (not tracked in repo)"
fi


# ─── System config (sudo) ─────────────────────────────────────────────────────

section "System configuration (sudo)"

# greetd
info "Configuring greetd..."
sudo tee /etc/greetd/config.toml > /dev/null << 'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --cmd Hyprland"
user = "_greetd"
EOF
ok "greetd configured"

# sudoers — passwordless access for common admin tasks
info "Writing sudoers entry for $CURRENT_USER..."
SUDOERS_FILE="/etc/sudoers.d/$CURRENT_USER"
sudo tee "$SUDOERS_FILE" > /dev/null << EOF
# Package management
$CURRENT_USER ALL=(ALL) NOPASSWD: /usr/bin/apt install *, /usr/bin/apt remove *, /usr/bin/apt purge *, /usr/bin/apt update, /usr/bin/apt upgrade, /usr/bin/apt autoremove
# System logs
$CURRENT_USER ALL=(ALL) NOPASSWD: /usr/bin/journalctl *
# Power management
$CURRENT_USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl poweroff, /usr/bin/systemctl reboot
EOF
sudo chmod 0440 "$SUDOERS_FILE"
if sudo visudo -cf "$SUDOERS_FILE"; then
    ok "sudoers validated: $SUDOERS_FILE"
else
    err "sudoers validation failed — removing $SUDOERS_FILE to be safe"
    sudo rm "$SUDOERS_FILE"
fi

# dhcpcd stop timeout — prevents 90s hang on shutdown
if systemctl list-unit-files dhcpcd.service &>/dev/null; then
    info "Applying dhcpcd stop-timeout fix..."
    sudo mkdir -p /etc/systemd/system/dhcpcd.service.d
    sudo tee /etc/systemd/system/dhcpcd.service.d/timeout.conf > /dev/null << 'EOF'
[Service]
TimeoutStopSec=10
EOF
    sudo systemctl daemon-reload
    ok "dhcpcd timeout override applied"
else
    info "dhcpcd not present — skipping timeout fix"
fi

# Enable greetd as the login manager
info "Enabling greetd..."
sudo systemctl enable greetd
sudo systemctl set-default graphical.target
ok "greetd enabled, graphical.target set as default"


# ─── Conda (Miniforge) ────────────────────────────────────────────────────────

section "Conda (Miniforge)"

CONDA_DIR="$HOME/devel/miniforge3"

if [[ -d "$CONDA_DIR" ]]; then
    ok "Miniforge already installed at $CONDA_DIR"
else
    info "Downloading Miniforge installer..."
    CONDA_INSTALLER="/tmp/Miniforge3.sh"
    CONDA_BASE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
    wget -q "${CONDA_BASE_URL}"        -O "$CONDA_INSTALLER"
    wget -q "${CONDA_BASE_URL}.sha256" -O "$CONDA_INSTALLER.sha256"

    info "Verifying SHA256 checksum..."
    if ! sha256sum -c "$CONDA_INSTALLER.sha256"; then
        rm "$CONDA_INSTALLER" "$CONDA_INSTALLER.sha256"
        die "Miniforge checksum verification failed — aborting."
    fi
    ok "Checksum verified"
    rm "$CONDA_INSTALLER.sha256"

    info "Installing Miniforge to $CONDA_DIR..."
    bash "$CONDA_INSTALLER" -b -p "$CONDA_DIR"
    rm "$CONDA_INSTALLER"
    ok "Miniforge installed"
fi

# Write the conda shell hook to ~/.zshrc.local to keep the repo's zshrc clean.
touch "$HOME/.zshrc.local"
if grep -q "$CONDA_DIR" "$HOME/.zshrc.local"; then
    ok "Conda hook already present in ~/.zshrc.local"
else
    info "Adding conda shell hook to ~/.zshrc.local..."
    "$CONDA_DIR/bin/conda" shell.zsh hook >> "$HOME/.zshrc.local"
    ok "Conda hook written to ~/.zshrc.local"
fi

# Disable conda's default prompt modification (we use RPROMPT in zshrc instead)
"$CONDA_DIR/bin/conda" config --set changeps1 false
ok "Conda prompt modification disabled"


# ─── Dropbox ──────────────────────────────────────────────────────────────────

section "Dropbox"

DROPBOX_DIR="$HOME/.local/lib/dropbox"
DROPBOX_BIN="$DROPBOX_DIR/dropboxd"

install_dropbox() {
    info "Downloading Dropbox daemon..."
    mkdir -p "$DROPBOX_DIR"
    wget -qO - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf - --strip-components=1 -C "$DROPBOX_DIR"
    ok "Dropbox installed at $DROPBOX_DIR"
}

if [[ -x "$DROPBOX_BIN" ]]; then
    if yes_no "Dropbox already installed. Update it?"; then
        install_dropbox
    else
        ok "Dropbox kept as-is"
    fi
else
    install_dropbox
fi

# Dropbox CLI — Python wrapper that queries dropboxd status via its socket.
# Used by the waybar custom/dropbox module.
DROPBOX_CLI="$HOME/.local/bin/dropbox"
if [[ -x "$DROPBOX_CLI" ]]; then
    ok "Dropbox CLI already installed"
else
    info "Downloading Dropbox CLI..."
    mkdir -p "$HOME/.local/bin"
    curl -fsSL "https://www.dropbox.com/download?dl=packages/dropbox.py" -o "$DROPBOX_CLI"
    chmod +x "$DROPBOX_CLI"
    ok "Dropbox CLI installed at $DROPBOX_CLI"
fi


# ─── Wallpaper ────────────────────────────────────────────────────────────────

section "Wallpaper directory"

mkdir -p "$HOME/Pictures/wallpapers"
if [[ ! -f "$HOME/Pictures/wallpapers/wall.jpg" ]]; then
    warn "~/Pictures/wallpapers/wall.jpg not found."
    warn "hyprpaper expects a file at that path — copy your wallpaper there before rebooting."
else
    ok "Wallpaper present"
fi


# ─── Spotify .desktop fix ─────────────────────────────────────────────────────

section "Spotify .desktop"

SPOTIFY_DESKTOP="$HOME/.local/share/applications/spotify.desktop"
if [[ ! -f "$SPOTIFY_DESKTOP" ]]; then
    mkdir -p "$(dirname "$SPOTIFY_DESKTOP")"
    cat > "$SPOTIFY_DESKTOP" << 'EOF'
[Desktop Entry]
Name=Spotify
Exec=spotify
Icon=spotify
Type=Application
Categories=Audio;Music;
EOF
    ok "Spotify .desktop file created"
else
    ok "Spotify .desktop already exists"
fi


# ─── Done ─────────────────────────────────────────────────────────────────────

section "Setup complete"

printf '%s
Manual steps still needed:
%s
  1. Wallpaper
     Copy your wallpaper to: ~/Pictures/wallpapers/wall.jpg

  2. SSH key (if not already set up)
     ssh-keygen -t ed25519 && cat ~/.ssh/id_ed25519.pub
     Then add the public key to GitHub / wherever needed.

  3. GDM3 cleanup (if it was the previous display manager)
     sudo apt remove gdm3

  4. Nvidia DRM warnings
     Known issue with driver 550 on newer kernels.
     Upgrade to driver 560+ when available to resolve.

  5. VMX / virtualisation
     Enable in BIOS if you need VMs.

  6. Reboot
     Required to load Nvidia drivers, start greetd, and apply shell change.
     Run: systemctl reboot

' "$bold" "$reset"
