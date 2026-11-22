# 🐉 3xploiter0 rice — Catppuccin Mocha Kali

A complete **Catppuccin Mocha** rice for **Kali Linux (XFCE)** with a full **hacking workflow** baked in — installed with one command.

Themed desktop, macOS-style feels, animated eye candy, and a pentest toolkit that turns a fresh box into a working HTB/THM rig in seconds.

![HTB workspace](docs/workspace.png)

---

## 🎨 Palette

| Role | Color | Hex |
|---|---|---|
| Base / background | 🟣 dark | `#1e1e2e` |
| Crust / panel | ⬛ | `#11111b` |
| Surface | 🟪 | `#313244` |
| Text | ⚪ | `#a6adc8` (low-glare) |
| Mauve (accent) | 🟣 | `#cba6f7` |
| Blue | 🔵 | `#89b4fa` |
| Pink | 🌸 | `#f5c2e7` |
| Teal | 🩵 | `#94e2d5` |
| Peach | 🟠 | `#fab387` |
| Green / Yellow / Red | ✅ | `#a6e3a1` · `#f9e2af` · `#f38ba8` |

---

## 📖 Command reference

Every command is documented with an example in **[COMMANDS.md](COMMANDS.md)**.
In a terminal: `cheat` (quick list), `cheat <section>` (enum/ports/web/ad/crack/linux/windows…), and **`ex <command>`** to print one example — e.g. `ex payload`.

## ✨ Highlights

- **Catppuccin Mocha everywhere** — window theme, GTK, Flat-Remix Purple icons, Bibata Ice cursor, JetBrainsMono Nerd Font, themed Alacritty / QTerminal / btop / Neovim, starship prompt
- **Anime wallpapers** — a curated `anime-*.jpg` rotation (`anime-yq2mll.jpg` by default), no gradient placeholders; cycle with `wal-cycle`
- **macOS replica look** — real WhiteSur traffic-light close/minimize/maximize buttons on every app window, frosted glass menu bar + dock, rounded windows, soft shadows, centered clock, Launchpad (`F4`), Mission Control (`F3`), hot corners
- **Eye candy** — animated video wallpaper (`livewp`), wallpaper-driven auto-theming (`wal-cycle`), a desktop HUD (conky), window animations + blur (picom)
- **Hacking workflow** — one-command box setup, auto-recon, VPN toggle, reverse-shell generator, report builder, terminal auto-logging
- **Self-maintaining** — weekly auto-update + unattended security patches
- **Backed up + shareable** — everything lives in this repo

| Launchpad | Matrix lock |
|---|---|
| ![Launchpad](docs/launchpad.png) | ![Matrix](docs/matrix.png) |

---

## 🚀 Install

Run as your **normal user** (it uses `sudo` when needed) on Kali/XFCE:

```bash
git clone https://github.com/3xploiter0/rice-dotfiles ~/rice
cd ~/rice
./install.sh
```

- Existing configs are **backed up** to `~/.rice-restore-<date>/` first.
- **Safe install:** desktop look + terminals + toolkit. It does **not** touch GRUB, the boot splash, or the login screen.
- When it finishes: **log out and back in**, open a terminal, and run **`cheat`**.

---

## ⌨️ Commands

Run **`cheat`** any time for the full, colored list (`cheat htb`, `cheat tmux`, `cheat desktop`…), or open [`cheatsheet/rice-card.html`](cheatsheet/rice-card.html).

### Hacking workflow
| Command | Does |
|---|---|
| `vpn htb` · `vpn thm` · `vpn down` | Connect/disconnect a `.ovpn` (put files in `~/vpn/`) |
| `htb <ip> <box>` | Target + folders + tmux workspace (nmap, listener, notes) |
| `recon <ip>` | Full port scan → auto service enum (web/SMB/FTP…) |
| `recon-web <domain>` | subfinder → httpx → nuclei *(authorized scope only)* |
| `addhost <ip> <name>` | Add/remove an `/etc/hosts` entry |
| `serve` / `gettools` | HTTP file server (IP pre-filled) / stage linpeas·winpeas·pspy·chisel |
| `revshell` | Reverse shells (bash/python/php/ps…), copies to clipboard |
| `pwncat-cs -lp 4444` | Smart reverse-shell catcher (auto TTY) |
| `note "…"` · `loot <f>` | Timestamped note / grab a file into the box's `loot/` |
| `crack <hash\|file>` | Auto-detect hash type → hashcat vs rockyou |
| `report <box>` | Build a markdown pentest report from notes + logs |
| `status` | One glance: VPN, target, box, listeners, tmux |

### Desktop
| Keys | Does |
|---|---|
| `Super+Return` / `Super+Space` | Terminal / app launcher |
| `F4` / `F3` | Launchpad / Mission Control |
| `Super+Ctrl+Space` | Next wallpaper |
| `Super+1..5` / `+Shift` | Switch / move to workspace |
| Three-finger swipe left/right | Switch desktop/workspace (needs `libinput-gestures` + touchpad) |
| `livewp on` · `wal-cycle` | Live video wallpaper · recolor from wallpaper |

QTerminal's menu bar is hidden (`MenuVisible=false`), so `session · action · edit · view · help` no longer overlaps the window controls.

---

## 🧩 What's inside

```
install.sh              one-command installer (portable, backs up first)
.zshrc .tmux.conf       shell + tmux (Catppuccin Mocha, auto-logging)
.config/               alacritty, picom (glass), rofi, nvim (LazyVim), conky, fastfetch, btop, cava, libinput-gestures
.local/bin/            all the helper commands above
.local/share/          WhiteSur-MacOS xfwm theme, icons config, qterminal/gtksourceview themes, wallpapers
scripts/               generate-xfwm-theme.py (regenerates the traffic-light theme)
xfce-xml/              panel + dock + window-manager + keybind settings
cheatsheet/            printable HTML reference card
```

Self-update: a systemd user timer runs `update` weekly (nuclei templates + config backup/push), and `unattended-upgrades` handles apt security patches.

---

## ↩️ Uninstall

```bash
cd ~/rice        # the folder you cloned into
./uninstall.sh
```

It stops the rice (picom, conky, dock, live wallpaper, weekly timer), removes the
helper commands and configs it added, and **restores your previous configs** from
the backup `install.sh` made (`~/.rice-restore-<date>/`). Log out and back in
afterwards.

Packages are left installed (they're harmless on their own); the uninstaller
prints the `apt remove` line if you also want to drop the extras. If you no longer
have the cloned folder, re-clone it and run `./uninstall.sh` from there.

---

## ⚠️ Notes

- Built and tested on **Kali Linux rolling, XFCE (X11)**. Other XFCE distros may need small tweaks.
- The Nerd Font isn't bundled (too large for git) — the installer downloads it automatically.
- Wallpapers are included for convenience; swap in your own from `~/.local/share/backgrounds/omarchy/`.
- Three-finger swipes need a physical libinput touchpad. Kali has no `libinput-gestures` apt package, so the installer fetches the upstream script into `~/.local/bin` and uses `libinput-tools`. It also adds your user to the `input` group and enables autostart; **log out and back in once** before swiping. Without a touchpad, use `Super+1..5` or `Ctrl+Alt+Left/Right`. You can re-run just this part with `bash scripts/install-gestures.sh`.
- Use the recon/scanning tools **only against systems you're authorized to test.**

Made for fun. PRs and issues welcome.
