#!/usr/bin/env bash
# Style the LightDM GTK greeter like macOS (WhiteSur + Sonoma wallpaper). Needs sudo.
# Safe to re-run: the original greeter config is backed up only once.
set -e

CONF=/etc/lightdm/lightdm-gtk-greeter.conf
CURSOR=WhiteSur-cursors
# WhiteSur cursors ship with the rice; fall back if that install was skipped.
[ -d "$HOME/.local/share/icons/$CURSOR" ] || CURSOR=Bibata-Modern-Ice

sudo mkdir -p /usr/share/backgrounds/mac /usr/share/themes /usr/share/icons
sudo cp "$HOME/.local/share/backgrounds/mac/Sonoma-dark.jpg" /usr/share/backgrounds/mac/

# Merge into system theme dirs — plain `cp -r src dest` nests when dest exists.
sudo mkdir -p /usr/share/themes/WhiteSur-Dark /usr/share/icons/WhiteSur-dark
sudo cp -a "$HOME/.themes/WhiteSur-Dark/." /usr/share/themes/WhiteSur-Dark/
sudo cp -a "$HOME/.local/share/icons/WhiteSur-dark/." /usr/share/icons/WhiteSur-dark/
if [ "$CURSOR" = WhiteSur-cursors ]; then
  sudo mkdir -p "/usr/share/icons/$CURSOR"
  sudo cp -a "$HOME/.local/share/icons/$CURSOR/." "/usr/share/icons/$CURSOR/"
fi

# Keep the first backup (a second run must not back up our own styled config).
[ -f "$CONF.bak" ] || sudo cp -a "$CONF" "$CONF.bak"

sudo sed -i -e 's#^background = .*#background = /usr/share/backgrounds/mac/Sonoma-dark.jpg#' \
  -e 's#^theme-name = .*#theme-name = WhiteSur-Dark#' \
  -e 's#^icon-theme-name = .*#icon-theme-name = WhiteSur-dark#' \
  -e 's#^font-name = .*#font-name = Inter 11#' "$CONF"

# Some keys are absent in Kali's default greeter config — add, don't just sed.
for kv in "cursor-theme-name = $CURSOR" 'hide-user-image = false' 'position = 50%,center 46%,center'; do
  key="${kv%% =*}"
  sudo sed -i -e "s#^$key = .*#$kv#" "$CONF"
  sudo grep -q "^$key =" "$CONF" || echo "$kv" | sudo tee -a "$CONF" >/dev/null
done

sudo mkdir -p /var/lib/lightdm/.config/gtk-3.0
sudo cp "$(dirname "$0")/greeter-gtk.css" /var/lib/lightdm/.config/gtk-3.0/gtk.css
id lightdm >/dev/null 2>&1 && sudo chown -R lightdm:lightdm /var/lib/lightdm/.config || true

if [ -f "$HOME/.face" ]; then
  sudo cp "$HOME/.face" /usr/share/backgrounds/mac/avatar.svg
  sudo chmod a+r /usr/share/backgrounds/mac/avatar.svg
  sudo sed -i '/^default-user-image = /d' "$CONF"
  echo 'default-user-image = /usr/share/backgrounds/mac/avatar.svg' | sudo tee -a "$CONF" >/dev/null
fi
echo "login screen styled (cursor: $CURSOR)"
