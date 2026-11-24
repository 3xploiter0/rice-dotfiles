#!/usr/bin/env bash
# ==========================================================================
#  3xploiter0 rice — Catppuccin Mocha Kali (XFCE) + hacking workflow
#  Safe install: desktop look, terminals, and the pentest toolkit.
#  Does NOT touch GRUB, the boot splash, or the login screen.
#
#  Usage:   ./install.sh          (run as your normal user, sudo when prompted)
#  Repo dir is auto-detected. Existing configs are backed up first.
# ==========================================================================
set -u
REPO="$(cd "$(dirname "$0")" && pwd)"
BK="$HOME/.rice-restore-$(date +%Y%m%d-%H%M%S)"
B=$'\e[38;2;137;180;250m'; G=$'\e[38;2;166;227;161m'; Y=$'\e[38;2;249;226;175m'; R=$'\e[38;2;243;139;168m'; D=$'\e[38;2;108;112;134m'; X=$'\e[0m'
say(){ printf "\n${B}==>${X} %s\n" "$1"; }
ok(){ printf "  ${G}✓${X} %s\n" "$1"; }
warn(){ printf "  ${Y}!${X} %s\n" "$1"; }

[ "$(id -u)" -eq 0 ] && { echo "${R}Run as your normal user, not root.${X}"; exit 1; }
command -v xfconf-query >/dev/null || warn "XFCE not detected — the look won't apply, but tools will install."

cat <<BANNER
${B}
   3xploiter0 rice installer — Catppuccin Mocha Kali
${D}   look + terminals + hacking toolkit · safe (no boot/login changes)
   backups -> $BK${X}
BANNER
printf "Continue? [y/N] "; read -r a; case "$a" in y|Y) ;; *) echo "aborted"; exit 0;; esac

# ---------------------------------------------------------------- packages
say "Installing packages (sudo)"
APT=(
  # look
  papirus-icon-theme bibata-cursor-theme fonts-inter picom rofi
  libinput-tools python3-pil
  xfce4-docklike-plugin xfce4-panel-profiles conky-all cmatrix
  # terminals + shell
  alacritty starship tmux zoxide bat eza fd-find fzf ripgrep zsh-syntax-highlighting zsh-autosuggestions
  neovim tree-sitter-cli
  # build + media (xwinwrap, live wallpaper, fastfetch logo)
  build-essential libx11-dev libxext-dev libxrender-dev libxinerama-dev
  ffmpeg mpv feh imagemagick figlet xdotool xclip pipx
  # hacking toolkit
  feroxbuster nuclei httpx-toolkit gobuster ffuf subfinder chisel seclists
  enum4linux-ng whatweb hashcat john hashid rlwrap xterm ansifilter
  fastfetch btop cava tty-clock unattended-upgrades
)
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${APT[@]}" || warn "some packages failed (continuing)"
ok "packages"

# ---------------------------------------------------------------- fonts
say "Fonts (JetBrainsMono Nerd Font)"
mkdir -p "$HOME/.local/share/fonts"
if [ -d "$REPO/.local/share/fonts/JetBrainsMonoNerd" ]; then
  cp -rn "$REPO/.local/share/fonts/JetBrainsMonoNerd" "$HOME/.local/share/fonts/"
else
  curl -sL -o /tmp/JBM.tar.xz https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz \
    && mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNerd" \
    && tar -xf /tmp/JBM.tar.xz -C "$HOME/.local/share/fonts/JetBrainsMonoNerd"
fi
# UI font — Hanken Grotesk (free, Claude-like)
mkdir -p "$HOME/.local/share/fonts/HankenGrotesk"
curl -fsSL -o "$HOME/.local/share/fonts/HankenGrotesk/HankenGrotesk.ttf" \
  "https://github.com/google/fonts/raw/main/ofl/hankengrotesk/HankenGrotesk%5Bwght%5D.ttf" 2>/dev/null || warn "Hanken Grotesk download failed (Inter fallback)"
fc-cache -f >/dev/null 2>&1; ok "fonts"

# ---------------------------------------------------------------- backup + copy configs
say "Backing up existing configs -> $BK"
mkdir -p "$BK"
copy() { # src-in-repo  dest
  local s="$REPO/$1" d="$2"
  [ -e "$s" ] || return 0
  [ -e "$d" ] && { mkdir -p "$BK/$(dirname "$1")"; cp -a "$d" "$BK/$1" 2>/dev/null; }
  if [ -d "$s" ]; then
    # Merge into an existing directory. `cp -a src dest` would create dest/basename
    # instead, which hides every file one level too deep on a re-install.
    mkdir -p "$d"; cp -a "$s/." "$d/"
  else
    mkdir -p "$(dirname "$d")"; cp -a "$s" "$d"
  fi
}
say "Installing dotfiles + scripts"
for p in .zshrc .tmux.conf \
         .config/starship.toml .config/alacritty .config/picom .config/rofi \
         .config/libinput-gestures .config/plank .config/cherrytree \
         .config/conky .config/nvim .config/fastfetch .config/btop .config/cava \
         .config/hack .config/gtk-3.0 .config/gtk-4.0 .config/qterminal.org \
         .local/bin \
         .local/share/themes .local/share/icons .local/share/qtermwidget6 .local/share/qterminal \
         .local/share/gtksourceview-3.0 \
         .local/share/gtksourceview-4 .local/share/gtksourceview-5 \
         .local/share/backgrounds .local/share/plank .local/share/applications; do
  copy "$p" "$HOME/$p"
done
chmod +x "$HOME/.local/bin/"* 2>/dev/null
# the Apple menu-bar logo lives in hicolor/scalable/apps — refresh the cache so it resolves
command -v gtk-update-icon-cache >/dev/null 2>&1 && \
  gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1
mkdir -p "$HOME/cyber" && cp -f "$REPO/COMMANDS.md" "$HOME/cyber/COMMANDS.md" 2>/dev/null
ok "dotfiles + scripts"

# fix any hardcoded author paths -> this user
say "Making paths portable ($USER)"
grep -rIlZ '/home/x3xploiter0' "$HOME/.local/bin" "$HOME/.config" "$HOME/.local/share" 2>/dev/null \
  | xargs -0 -r sed -i "s#/home/x3xploiter0#$HOME#g"
# .zshrc is user-owned/gitignored — add the prompt hook only if it isn't there yet
if command -v starship >/dev/null 2>&1 && ! grep -q 'starship init zsh' "$HOME/.zshrc" 2>/dev/null; then
  printf '\n# 3xploiter0 rice — Starship prompt\nexport STARSHIP_CONFIG="$HOME/.config/starship.toml"\neval "$(starship init zsh)"\n' >> "$HOME/.zshrc"
fi
ok "paths"

# ---------------------------------------------------------------- pipx + xwinwrap
say "pipx tools (pywal16, pwncat-cs)"
pipx install pywal16 >/dev/null 2>&1 && ok "pywal16" || warn "pywal16"
pipx install pwncat-cs >/dev/null 2>&1 && ok "pwncat-cs" || warn "pwncat-cs"
pipx ensurepath >/dev/null 2>&1

if ! command -v xwinwrap >/dev/null; then
  say "Building xwinwrap (live wallpaper)"
  t="$(mktemp -d)"; git clone -q --depth 1 https://github.com/mmhobi7/xwinwrap.git "$t" \
    && ( cd "$t" && make >/dev/null 2>&1 && sudo make install >/dev/null 2>&1 ) \
    && ok "xwinwrap" || warn "xwinwrap build failed (live wallpaper only)"
  rm -rf "$t"
fi

# rockyou
[ -f /usr/share/wordlists/rockyou.txt ] || sudo gunzip -kf /usr/share/wordlists/rockyou.txt.gz 2>/dev/null

# ---------------------------------------------------------------- WhiteSur (macOS look)
say "WhiteSur GTK theme + icons + cursors (prebuilt, no sassc needed)"
t="$(mktemp -d)"
if git clone -q --depth 1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git "$t/gtk" \
   && git clone -q --depth 1 https://github.com/vinceliuice/WhiteSur-icon-theme.git "$t/icons" \
   && git clone -q --depth 1 https://github.com/vinceliuice/WhiteSur-cursors.git "$t/cursors"; then
  mkdir -p "$HOME/.themes" "$HOME/.local/share/icons"
  tar -xJf "$t/gtk/release/WhiteSur-Dark.tar.xz" -C "$HOME/.themes"
  ( cd "$t/icons" && ./install.sh -d "$HOME/.local/share/icons" -t default >/dev/null 2>&1 )
  ( cd "$t/cursors" && ./install.sh >/dev/null 2>&1 )
  ok "WhiteSur"
else warn "WhiteSur download failed (look will fall back to defaults)"; fi
rm -rf "$t"

# ---------------------------------------------------------------- XFCE look
if command -v xfconf-query >/dev/null; then
  say "Applying XFCE look (panel, theme, keybinds, wallpaper)"
  XD="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"; mkdir -p "$XD"
  # xfconfd caches every channel in memory and rewrites the XML on logout, so files
  # copied under a running session get silently reverted. Stop it (and the panel)
  # first; dbus re-spawns xfconfd on the next query and it re-reads from disk.
  xfce4-panel --quit >/dev/null 2>&1
  pkill -x xfconfd 2>/dev/null; sleep 1
  # back up + install the perchannel XML (panel/dock, wm theme, fonts, keybinds, desktop)
  for f in "$REPO"/xfce-xml/*.xml; do
    [ -e "$f" ] || continue; n="$(basename "$f")"
    [ -e "$XD/$n" ] && cp -a "$XD/$n" "$BK/xfce-$n" 2>/dev/null
    sed "s#/home/x3xploiter0#$HOME#g" "$f" > "$XD/$n"
  done
  # picom does the compositing — xfwm4's own compositor must be off or they fight
  xfconf-query -c xfwm4 -p /general/use_compositing -n -t bool -s false 2>/dev/null
  # the XML alone isn't always picked up by a running xfsettingsd — set the cursor live
  xfconf-query -c xsettings -p /Net/CursorThemeName -n -t string -s WhiteSur-cursors 2>/dev/null
  command -v gsettings >/dev/null 2>&1 && \
    gsettings set org.gnome.desktop.interface cursor-theme WhiteSur-cursors 2>/dev/null
  # panel launchers (Launchpad etc)
  mkdir -p "$HOME/.config/xfce4/panel"
  if [ -d "$REPO/xfce-panel-launchers" ]; then
    cp -a "$REPO/xfce-panel-launchers/." "$HOME/.config/xfce4/panel/"
    grep -rIlZ '/home/x3xploiter0' "$HOME/.config/xfce4/panel" 2>/dev/null | xargs -0 -r sed -i "s#/home/x3xploiter0#$HOME#g"
  fi
  # wallpaper on every monitor THIS machine has (names differ per PC: eDP-1, eDP, HDMI-1…)
  WP="$HOME/.local/share/backgrounds/mac"
  img="$WP/Sonoma-dark.jpg"
  [ -f "$img" ] || img="$(find "$WP" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' \) 2>/dev/null | sort | head -1)"
  if [ -n "$img" ] && command -v xrandr >/dev/null; then
    for mon in $(xrandr --query | awk '/ connected/{print $1}'); do
      for ws in 0 1 2 3 4; do
        base="/backdrop/screen0/monitor$mon/workspace$ws"
        xfconf-query -c xfce4-desktop -p "$base/last-image"  -n -t string -s "$img" 2>/dev/null
        xfconf-query -c xfce4-desktop -p "$base/image-style" -n -t int    -s 5      2>/dev/null
      done
    done
  fi
  # reload the desktop now so the look shows without waiting for a re-login
  if [ -n "${DISPLAY:-}" ]; then
    (setsid xfwm4 --replace >/dev/null 2>&1 &)
    (setsid xfce4-panel >/dev/null 2>&1 &)
    xfdesktop --reload >/dev/null 2>&1
  fi
  ok "XFCE settings applied"
fi

# ---------------------------------------------------------------- autostart + timer
say "Autostart + weekly self-update"
mkdir -p "$HOME/.config/autostart"
[ -d "$REPO/.config/autostart" ] && { cp -a "$REPO/.config/autostart/." "$HOME/.config/autostart/"; \
  grep -rIlZ '/home/x3xploiter0' "$HOME/.config/autostart" 2>/dev/null | xargs -0 -r sed -i "s#/home/x3xploiter0#$HOME#g"; }
if [ -d "$REPO/.config/systemd" ]; then
  cp -a "$REPO/.config/systemd/." "$HOME/.config/systemd/"
  systemctl --user daemon-reload 2>/dev/null
  systemctl --user enable --now rice-update.timer 2>/dev/null && ok "weekly timer"
fi

# ---------------------------------------------------------------- Plank dock look
# Config/theme are copied above; the binary itself is built by install-plank.sh.
if [ -f "$HOME/.local/share/glib-2.0/schemas/net.launchpad.plank.gschema.xml" ]; then
  say "Applying Plank dock settings"
  SD="$HOME/.local/share/glib-2.0/schemas"
  glib-compile-schemas "$SD" >/dev/null 2>&1
  SCHEMA="net.launchpad.plank.dock.settings:/net/launchpad/plank/dock/dock1/"
  while read -r _ key val; do
    [ -n "${key:-}" ] && GSETTINGS_SCHEMA_DIR="$SD" gsettings set "$SCHEMA" "$key" "$val" 2>/dev/null
  done < "$REPO/xfconf/plank-dock1.txt"
  if [ -x "$HOME/.local/bin/plank" ] && [ -n "${DISPLAY:-}" ] && ! pgrep -x plank >/dev/null; then
    (setsid env GSETTINGS_SCHEMA_DIR="$SD" "$HOME/.local/bin/plank" >/dev/null 2>&1 &)
  fi
  ok "dock"
else
  warn "Plank binary not built yet — run: bash scripts/install-plank.sh"
fi

# ---------------------------------------------------------------- 3-finger gestures
# Kali has no `libinput-gestures` apt package; the helper installs upstream's
# Python script into ~/.local/bin and uses the distro `libinput-tools` binaries.
if [ -f "$REPO/scripts/install-gestures.sh" ]; then
  bash "$REPO/scripts/install-gestures.sh" && ok "gestures configured (re-login if newly added to 'input')"
fi

# default shell -> zsh
if [ "$SHELL" != "$(command -v zsh)" ] && command -v zsh >/dev/null; then
  chsh -s "$(command -v zsh)" 2>/dev/null && ok "default shell -> zsh" || warn "set zsh manually: chsh -s \$(which zsh)"
fi

cat <<DONE

${G}Done!${X}
${D}Backup of what was replaced:${X} $BK
${B}Next:${X}
  1. Log out and back in (loads panel, dock, theme, autostart).
  2. Open a terminal and run  ${G}cheat${X}  to see every command.
  3. Put HTB/THM .ovpn files in  ~/vpn/  then:  ${G}vpn htb${X}
${D}Live wallpaper:${X} livewp on   ${D}·  auto-theme:${X} wal-cycle   ${D}·  status:${X} status
DONE
