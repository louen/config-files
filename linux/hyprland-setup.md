# Hyprland Desktop Setup Notes

## System
- **Machine:** ASUS Z97-A (desktop, no battery)
- **GPU:** Nvidia (proprietary driver 550.163.01)
- **Kernel:** 6.18.9+deb14-amd64
- **OS:** Debian (Trixie/Testing)
- **Font:** Fira Code (`fonts-firacode` package, not Nerd Font — text labels only, no icons)

## Installed Packages
- `hyprland` — Wayland compositor
- `kitty` — terminal emulator
- `waybar` — status bar
- `wofi` — application launcher
- `hyprlock` — lock screen
- `hypridle` — idle management daemon
- `hyprpaper` — wallpaper
- `greetd` + `tuigreet` — login greeter (user `_greetd` in config)
- `pamixer` — volume control CLI
- `imv` — Wayland image viewer
- `dropboxd` (`~/.local/lib/dropbox/dropboxd`) — Dropbox sync daemon; start manually with `~/.local/lib/dropbox/dropboxd &`, stop with `pkill -f dropboxd`; folder config in `~/.dropbox/info.json`
- `dropbox` CLI (`~/.local/bin/dropbox`) — Python script that queries `dropboxd` via its socket (`~/.dropbox/command_socket`); used by the waybar module; **do not use a symlink for `~/Dropbox`** — if moving the folder, stop the daemon first, move the files, update `info.json`, then restart
- `code` — VS Code (from Microsoft repo)
- `spotify-client` — needed manual .desktop file in `~/.local/share/applications/`

## Config File Locations
All config files live in this repo and are symlinked to `~/.config/`:

| Repo path | Symlink target |
|-----------|---------------|
| `linux/hypr/hyprland.conf` | `~/.config/hypr/hyprland.conf` |
| `linux/hypr/hyprlock.conf` | `~/.config/hypr/hyprlock.conf` |
| `linux/hypr/hypridle.conf` | `~/.config/hypr/hypridle.conf` |
| `linux/hypr/hyprpaper.conf` | `~/.config/hypr/hyprpaper.conf` |
| `linux/waybar/config` | `~/.config/waybar/config` |
| `linux/waybar/style.css` | `~/.config/waybar/style.css` |
| `linux/wofi/style.css` | `~/.config/wofi/style.css` |
| `linux/kitty/kitty.conf` | `~/.config/kitty/kitty.conf` |

## Color Scheme
Everything uses **Gruvbox Dark**:
- Background: `#1d2021` (kitty) / `#282828` (waybar)
- Foreground: `#fbf1c7`
- Accent colors per waybar module (green, blue, purple, orange, yellow, etc.)
- Clock timezones: shades of green
- Wofi: same Gruvbox palette with explicit background on entries (fixes Steam submenu transparency)

## Hyprland Keybinds
| Keybind | Action |
|---------|--------|
| SUPER+Return | Open kitty |
| SUPER+Q | Kill active window |
| SUPER+M | Exit Hyprland |
| SUPER+Space | Open wofi launcher |
| SUPER+Arrows | Focus movement |
| SUPER+ALT+Arrows | Move window |
| SUPER+ALT+F | Fullscreen (mode 0 = real fullscreen) |
| SUPER+1-9 | Switch workspace |
| SUPER+SHIFT+1-9 | Move window to workspace |
| SUPER+Tab / SUPER+SHIFT+Tab | Cycle active workspaces |
| SUPER+Backtick | Cycle windows on current workspace |
| SUPER+SHIFT+Q | Lock screen (hyprlock) |
| XF86Audio keys | Volume up/down/mute via pamixer |

## Waybar Modules (right side)
`disk | dropbox | network | volume | CPU load temp | GPU load temp | date TYO PAR NYC LAX`
- CPU and GPU groups share a label, no separator within group
- Variable-width modules have `min-width` set in CSS to prevent layout shifting
- LAX timezone is bold (local timezone)
- Separators between sections but not between clocks
- GPU stats use `nvidia-smi` custom modules (5s interval)

## Idle / Lock
- **5 min idle:** hyprlock activates
- **10 min idle:** screen turns off (DPMS)
- **Before sleep:** hyprlock activates
- Wallpaper: `~/Pictures/wallpapers/wall.jpg` via hyprpaper

## Known Issues
- **Nvidia DRM warnings** in dmesg (`nv_drm_revoke_modeset_permission`) — harmless, driver 550 on kernel 6.18, upgrade to 560+ should fix
- **Xwayland crashes** — Nvidia driver related, needed for Steam/X11 apps, core dumps disabled with `ulimit -c 0`
- **dhcpcd shutdown hang** — fixed with `TimeoutStopSec=10` override (via `sudo systemctl edit dhcpcd.service`)
- **`halt` vs `poweroff`** — `halt` doesn't power off, use `poweroff` or `systemctl poweroff`
- **ACPI/GPIO resource conflicts** — BIOS firmware quirk on Z97-A, harmless
- **GDM3 installed but unused** — can be removed (`sudo apt remove gdm3`)
- **VMX disabled in BIOS** — enable if VMs needed

## Sudoers
File: `/etc/sudoers.d/louen` (mode 0440, validate with `visudo -cf`)
- Package management: `apt install/remove/purge/update/upgrade/autoremove`
- System logs: `journalctl`
- Power: `systemctl poweroff/reboot`

## Shell Aliases (in shells/aliases)
- `shutdown` → `systemctl poweroff`
- `reboot` → `systemctl reboot`
- `dpkg-purge` → purge packages with leftover config files (`dpkg -l | grep '^rc'`)

## greetd Config
File: `/etc/greetd/config.toml`
- User: `_greetd` (not `greeter`)
- Command: `tuigreet --cmd Hyprland`
- VT: 1
