#!/usr/bin/env bash
# Install the macOS-style Plymouth boot splash (black, white Apple logo, thin progress bar). Needs sudo.
# Backs up the current initramfs + plymouth config first. Test it with a reboot.
# Safe to re-run: existing backups are never overwritten.
set -e

HERE="$(cd "$(dirname "$0")/.." && pwd)"; K="$(uname -r)"
[ -d "$HERE/plymouth/macos" ] || { echo "missing plymouth/macos theme in $HERE" >&2; exit 1; }
[ -f "/boot/initrd.img-$K" ] || { echo "no initrd for $K — run update-initramfs first" >&2; exit 1; }

INITRD_BAK="/boot/initrd.img-$K.before-macos-splash"
CONF_BAK=/etc/plymouth/plymouthd.conf.before-macos
[ -f "$INITRD_BAK" ] || sudo cp -a "/boot/initrd.img-$K" "$INITRD_BAK"
[ -f "$CONF_BAK" ]  || sudo cp -a /etc/plymouth/plymouthd.conf "$CONF_BAK"

sudo rm -rf /usr/share/plymouth/themes/macos
sudo cp -r "$HERE/plymouth/macos" /usr/share/plymouth/themes/macos
sudo chmod -R a+rX /usr/share/plymouth/themes/macos
sudo plymouth-set-default-theme macos

# initramfs generation occasionally fails on the first pass; retry once
for try in 1 2; do
  sudo update-initramfs -u -k "$K" && break
  [ "$try" -eq 2 ] && { echo "initramfs update failed" >&2; exit 1; }
  sleep 2
done
echo "boot splash installed. Reboot to see it."
echo "Undo: sudo cp $CONF_BAK /etc/plymouth/plymouthd.conf && sudo update-initramfs -u -k $K"
