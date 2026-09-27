#!/usr/bin/env bash
# ==========================================================================
#  3xploiter0 rice — Tokyo Night Kali (XFCE) + hacking workflow
#  Safe install: desktop look, terminals, and the pentest toolkit.
#  Does NOT touch GRUB, the boot splash, or the login screen.
#
#  Usage:   ./install.sh          (run as your normal user, sudo when prompted)
#  Repo dir is auto-detected. Existing configs are backed up first.
# ==========================================================================
set -u
REPO="$(cd "$(dirname "$0")" && pwd)"
BK="$HOME/.rice-restore-$(date +%Y%m%d-%H%M%S)"
B=$'\e[38;2;122;162;247m'; G=$'\e[38;2;158;206;106m'; Y=$'\e[38;2;224;175;104m'; R=$'\e[38;2;247;118;142m'; D=$'\e[38;2;86;95;137m'; X=$'\e[0m'
say(){ printf "\n${B}==>${X} %s\n" "$1"; }
ok(){ printf "  ${G}✓${X} %s\n" "$1"; }
warn(){ printf "  ${Y}!${X} %s\n" "$1"; }

[ "$(id -u)" -eq 0 ] && { echo "${R}Run as your normal user, not root.${X}"; exit 1; }
command -v xfconf-query >/dev/null || warn "XFCE not detected — the look won't apply, but tools will install."

cat <<BANNER
${B}
   3xploiter0 rice installer — Tokyo Night Kali
${D}   look + terminals + hacking toolkit · safe (no boot/login changes)
   backups -> $BK${X}
BANNER
printf "Continue? [y/N] "; read -r a; case "$a" in y|Y) ;; *) echo "aborted"; exit 0;; esac

# ---------------------------------------------------------------- packages
say "Installing packages (sudo)"
APT=(
  # look
  papirus-icon-theme bibata-cursor-theme fonts-inter picom rofi
  xfce4-docklike-plugin xfce4-panel-profiles conky-all cmatrix
  # terminals + shell
  alacritty tmux zoxide bat eza fd-find fzf ripgrep zsh-syntax-highlighting zsh-autosuggestions
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
fc-cache -f >/dev/null 2>&1; ok "fonts"

# ---------------------------------------------------------------- backup + copy configs
say "Backing up existing configs -> $BK"
mkdir -p "$BK"
copy() { # src-in-repo  dest
  local s="$REPO/$1" d="$2"
  [ -e "$s" ] || return 0
  [ -e "$d" ] && { mkdir -p "$BK/$(dirname "$1")"; cp -a "$d" "$BK/$1" 2>/dev/null; }
  mkdir -p "$(dirname "$d")"; cp -a "$s" "$d"
}
say "Installing dotfiles + scripts"
for p in .zshrc .tmux.conf \
         .config/starship.toml .config/alacritty .config/picom .config/rofi \
         .config/conky .config/nvim .config/fastfetch .config/btop .config/cava \
         .config/hack .config/gtk-3.0 .config/gtk-4.0 .config/qterminal.org \
         .local/bin \
         .local/share/themes .local/share/qtermwidget6 .local/share/gtksourceview-3.0 \
         .local/share/gtksourceview-4 .local/share/gtksourceview-5 \
         .local/share/backgrounds .local/share/applications; do
  copy "$p" "$HOME/$p"
done
chmod +x "$HOME/.local/bin/"* 2>/dev/null
ok "dotfiles + scripts"

# fix any hardcoded author paths -> this user
say "Making paths portable ($USER)"
grep -rlZ '/home/x3xploiter0' "$HOME/.local/bin" "$HOME/.config" 2>/dev/null \
  | xargs -0 -r sed -i "s#/home/x3xploiter0#$HOME#g"
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

# ---------------------------------------------------------------- XFCE look
if command -v xfconf-query >/dev/null; then
  say "Applying XFCE look (panel, theme, keybinds, wallpaper)"
  XD="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"; mkdir -p "$XD"
  # back up + install the perchannel XML (panel/dock, wm theme, fonts, keybinds, desktop)
  for f in "$REPO"/xfce-xml/*.xml; do
    [ -e "$f" ] || continue; n="$(basename "$f")"
    [ -e "$XD/$n" ] && cp -a "$XD/$n" "$BK/xfce-$n" 2>/dev/null
    sed "s#/home/x3xploiter0#$HOME#g" "$f" > "$XD/$n"
  done
  # panel launchers (Launchpad etc)
  mkdir -p "$HOME/.config/xfce4/panel"
  if [ -d "$REPO/xfce-panel-launchers" ]; then
    cp -a "$REPO/xfce-panel-launchers/." "$HOME/.config/xfce4/panel/"
    grep -rlZ '/home/x3xploiter0' "$HOME/.config/xfce4/panel" 2>/dev/null | xargs -0 -r sed -i "s#/home/x3xploiter0#$HOME#g"
  fi
  # default wallpaper -> first bundled one (only if the saved one is missing)
  WP="$HOME/.local/share/backgrounds/omarchy"
  if [ -d "$WP" ]; then
    img="$(find "$WP" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' \) | sort | head -1)"
    for pth in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E 'last-image$'); do
      cur="$(xfconf-query -c xfce4-desktop -p "$pth" 2>/dev/null)"
      [ -f "$cur" ] || xfconf-query -c xfce4-desktop -p "$pth" -s "$img" 2>/dev/null
    done
  fi
  ok "XFCE settings staged (applied on next login / panel restart)"
fi

# ---------------------------------------------------------------- autostart + timer
say "Autostart + weekly self-update"
mkdir -p "$HOME/.config/autostart"
[ -d "$REPO/.config/autostart" ] && { cp -a "$REPO/.config/autostart/." "$HOME/.config/autostart/"; \
  grep -rlZ '/home/x3xploiter0' "$HOME/.config/autostart" 2>/dev/null | xargs -0 -r sed -i "s#/home/x3xploiter0#$HOME#g"; }
if [ -d "$REPO/.config/systemd" ]; then
  cp -a "$REPO/.config/systemd/." "$HOME/.config/systemd/"
  systemctl --user daemon-reload 2>/dev/null
  systemctl --user enable --now rice-update.timer 2>/dev/null && ok "weekly timer"
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
