#!/usr/bin/env bash
# ==========================================================================
#  3xploiter0 rice — uninstaller
#  Stops the rice, removes the files it installed, and restores your previous
#  configs from the backup install.sh made (~/.rice-restore-<date>/).
#  Does NOT remove apt packages (they're harmless); see the note at the end.
# ==========================================================================
set -u
REPO="$(cd "$(dirname "$0")" && pwd)"
B=$'\e[38;2;122;162;247m'; G=$'\e[38;2;158;206;106m'; Y=$'\e[38;2;224;175;104m'; R=$'\e[38;2;247;118;142m'; D=$'\e[38;2;86;95;137m'; X=$'\e[0m'
say(){ printf "\n${B}==>${X} %s\n" "$1"; }
ok(){ printf "  ${G}✓${X} %s\n" "$1"; }

echo "${R}This removes the 3xploiter0 rice and restores your previous configs.${X}"
printf "Continue? [y/N] "; read -r a; case "$a" in y|Y) ;; *) echo "aborted"; exit 0;; esac

# 1. stop running pieces
say "Stopping running components"
pkill -x picom 2>/dev/null; pkill -x conky 2>/dev/null
pkill -x xwinwrap 2>/dev/null; pkill -f 'mpv -wid' 2>/dev/null
pkill -f "$HOME/.local/bin/hotcorners" 2>/dev/null; pkill -x rofi 2>/dev/null
systemctl --user disable --now rice-update.timer 2>/dev/null
ok "stopped services + timer"

# 2. remove the weekly timer units
rm -f "$HOME/.config/systemd/user/rice-update.service" "$HOME/.config/systemd/user/rice-update.timer"
systemctl --user daemon-reload 2>/dev/null

# 3. remove autostart entries we added
say "Removing autostart entries"
for f in picom conky-hud hotcorners conky crystal-dock; do rm -f "$HOME/.config/autostart/$f.desktop"; done
ok "autostart"

# 4. remove the helper scripts we shipped
say "Removing helper commands"
if [ -d "$REPO/.local/bin" ]; then
  for s in "$REPO"/.local/bin/*; do rm -f "$HOME/.local/bin/$(basename "$s")"; done
fi
ok "scripts"

# 5. remove configs/themes the rice added
say "Removing rice configs + themes"
rm -rf "$HOME/.config/alacritty" "$HOME/.config/picom" "$HOME/.config/conky" \
       "$HOME/.config/rofi/launchpad.rasi" "$HOME/.config/rofi/launchpad-full.rasi" \
       "$HOME/.config/rofi/expose.rasi" "$HOME/.config/rofi/expose-full.rasi" \
       "$HOME/.config/fastfetch/logo.txt" \
       "$HOME/.local/share/themes/Omarchy-TokyoNight" \
       "$HOME/.local/share/qtermwidget6/color-schemes/TokyoNight.colorscheme" \
       "$HOME/.local/share/gtksourceview-3.0/styles/tokyonight.xml" \
       "$HOME/.local/share/gtksourceview-4/styles/tokyonight.xml" \
       "$HOME/.local/share/gtksourceview-5/styles/tokyonight.xml" \
       "$HOME/.local/share/applications/screensavers/matrix.desktop"
ok "configs"

# 6. restore your previous configs from the newest install backup
RESTORE="$(find "$HOME" -maxdepth 1 -type d -name '.rice-restore-*' 2>/dev/null | sort | tail -1)"
if [ -n "$RESTORE" ]; then
  say "Restoring previous configs from $RESTORE"
  # dotfiles/config dirs (skip the xfce-*.xml we stored flat)
  ( cd "$RESTORE" && find . -mindepth 1 -maxdepth 1 ! -name 'xfce-*.xml' -exec cp -a {} "$HOME/" \; 2>/dev/null )
  # xfce perchannel xml
  XD="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
  for f in "$RESTORE"/xfce-*.xml; do
    [ -e "$f" ] || continue; n="$(basename "$f" | sed 's/^xfce-//')"; cp -a "$f" "$XD/$n"
  done
  ok "restored from backup"
else
  printf "  ${Y}!${X} no ~/.rice-restore-* backup found — configs removed but not replaced.\n"
  printf "    Reset the desktop look via: Settings > Appearance / Window Manager, or reinstall xfce4 defaults.\n"
fi

cat <<DONE

${G}Uninstalled.${X}
${B}Log out and back in${X} for the desktop to return to its previous state.

${D}Packages were left installed${X} (they don't affect anything on their own).
To remove the extras this rice pulled in, review and run e.g.:
  sudo apt remove picom rofi crystal-dock conky-all cmatrix xfce4-docklike-plugin \\
     alacritty && sudo apt autoremove
${D}(Keep tools you use — many are standard pentest utilities.)${X}
DONE
