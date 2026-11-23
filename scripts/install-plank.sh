#!/usr/bin/env bash
# Plank isn't packaged in Kali: build it from upstream into ~/.local (no sudo for the install itself).
# Needs: sudo apt install valac meson ninja-build libgtk-3-dev libbamf3-dev libwnck-3-dev libgee-0.8-dev \
#   libdbusmenu-gtk3-dev libgnome-menu-3-dev libgdk-pixbuf-2.0-dev libx11-dev libxfixes-dev libxi-dev \
#   bamfdaemon autoconf automake libtool intltool gettext autopoint autoconf-archive libxml2-utils make gcc pkg-config
set -e
t="$(mktemp -d)"; git clone -q --depth 1 https://github.com/ricotz/plank.git "$t/plank"; cd "$t/plank"
NOCONFIGURE=1 ./autogen.sh && ./configure --prefix="$HOME/.local" --disable-docs --disable-apport --disable-headless-tests --disable-benchmarks
make -j"$(nproc)" && make install
echo "plank installed to ~/.local/bin/plank"
