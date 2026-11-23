#!/usr/bin/env bash
# Install the macOS-style Plymouth boot splash (black, white Apple logo, thin progress bar). Needs sudo.
# Backs up the current initramfs + plymouth config first. Test it with a reboot.
set -e
HERE="$(cd "$(dirname "$0")/.." && pwd)"; K="$(uname -r)"
sudo cp -a "/boot/initrd.img-$K" "/boot/initrd.img-$K.before-macos-splash"
sudo cp -a /etc/plymouth/plymouthd.conf /etc/plymouth/plymouthd.conf.before-macos
sudo rm -rf /usr/share/plymouth/themes/macos
sudo cp -r "$HERE/plymouth/macos" /usr/share/plymouth/themes/macos
sudo chmod -R a+rX /usr/share/plymouth/themes/macos
sudo plymouth-set-default-theme macos
sudo update-initramfs -u -k "$K"
echo "boot splash installed. Reboot to see it."
echo "Undo: sudo cp /etc/plymouth/plymouthd.conf.before-macos /etc/plymouth/plymouthd.conf && sudo update-initramfs -u -k $K"
