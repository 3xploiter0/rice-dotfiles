#!/usr/bin/env bash
# Plank isn't packaged in Kali: build it from upstream into ~/.local (no sudo for the install itself).
# Needs: sudo apt install valac meson ninja-build libgtk-3-dev libbamf3-dev libwnck-3-dev libgee-0.8-dev \
#   libdbusmenu-gtk3-dev libgnome-menu-3-dev libgdk-pixbuf-2.0-dev libx11-dev libxfixes-dev libxi-dev \
#   bamfdaemon autoconf automake libtool intltool gettext autopoint autoconf-archive libxml2-utils make gcc pkg-config
set -euo pipefail

t="$(mktemp -d)"
trap 'rm -rf "$t"' EXIT

echo "* Cloning Plank..."
git clone -q --depth 1 https://github.com/ricotz/plank.git "$t/plank" || {
  echo "! Could not clone Plank — check your network" >&2; exit 1
}
cd "$t/plank"

echo "* Configuring..."
NOCONFIGURE=1 ./autogen.sh
./configure --prefix="$HOME/.local" --disable-docs --disable-apport \
  --disable-headless-tests --disable-benchmarks

echo "* Building..."
make -j"$(nproc)"
make install

# make install normally handles this; be explicit for other build setups
[ -d "$HOME/.local/share/glib-2.0/schemas" ] && \
  glib-compile-schemas "$HOME/.local/share/glib-2.0/schemas" >/dev/null 2>&1 || true

echo "plank installed to ~/.local/bin/plank"
echo "Re-run ./install.sh to apply the WhiteSur dock settings, then log out and back in."
