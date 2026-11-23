#!/usr/bin/env bash
# Style the LightDM GTK greeter like macOS (WhiteSur + Sonoma wallpaper). Needs sudo.
set -e
sudo mkdir -p /usr/share/backgrounds/mac
sudo cp "$HOME/.local/share/backgrounds/mac/Sonoma-dark.jpg" /usr/share/backgrounds/mac/
sudo cp -r "$HOME/.themes/WhiteSur-Dark" /usr/share/themes/
sudo cp -r "$HOME/.local/share/icons/WhiteSur-dark" "$HOME/.local/share/icons/Bibata-Modern-Ice" /usr/share/icons/
sudo cp -a /etc/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf.bak
sudo sed -i -e 's#^background = .*#background = /usr/share/backgrounds/mac/Sonoma-dark.jpg#' \
  -e 's#^theme-name = .*#theme-name = WhiteSur-Dark#' -e 's#^icon-theme-name = .*#icon-theme-name = WhiteSur-dark#' \
  -e 's#^cursor-theme-name = .*#cursor-theme-name = Bibata-Modern-Ice#' -e 's#^font-name = .*#font-name = Inter 11#' \
  /etc/lightdm/lightdm-gtk-greeter.conf
sudo mkdir -p /var/lib/lightdm/.config/gtk-3.0
sudo cp "$(dirname "$0")/greeter-gtk.css" /var/lib/lightdm/.config/gtk-3.0/gtk.css
sudo chown -R lightdm:lightdm /var/lib/lightdm/.config
sudo sed -i -e 's#^hide-user-image = .*#hide-user-image = false#' -e 's#^position = .*#position = 50%,center 46%,center#' /etc/lightdm/lightdm-gtk-greeter.conf
echo "login screen styled"
