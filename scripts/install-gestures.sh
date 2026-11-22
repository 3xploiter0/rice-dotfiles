#!/usr/bin/env bash
# Install user-level libinput-gestures on Kali/Debian.
# Kali does not ship the `libinput-gestures` package, so we use the upstream
# Python script plus the distro `libinput-tools` binaries.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$HOME/.local/share/libinput-gestures"
BIN="$HOME/.local/bin"

say() { printf '\033[1;36m*\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*"; }

say "Installing libinput-tools (provides the 'libinput' command)"
if command -v apt-get >/dev/null; then
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y libinput-tools xdotool || warn "apt install failed; continuing"
fi

say "Fetching upstream libinput-gestures"
mkdir -p "$HOME/.local/share" "$BIN"
if [ ! -d "$SRC/.git" ]; then
  git clone -q --depth 1 https://github.com/bulletmark/libinput-gestures.git "$SRC"
else
  git -C "$SRC" pull -q || true
fi

say "Installing user-level launcher"
cat > "$BIN/libinput-gestures" <<EOF
#!/bin/sh
export PATH="\$HOME/.local/bin:\$PATH"
exec python3 "\$HOME/.local/share/libinput-gestures/libinput-gestures" "\$@"
EOF
chmod +x "$BIN/libinput-gestures"

say "Installing gesture config + autostart"
mkdir -p "$HOME/.config/libinput-gestures" "$HOME/.config/autostart"
cp -f "$REPO/.config/libinput-gestures/libinput-gestures.conf" \
      "$HOME/.config/libinput-gestures/libinput-gestures.conf"
cp -f "$REPO/.config/autostart/libinput-gestures.desktop" \
      "$HOME/.config/autostart/libinput-gestures.desktop"
sed -i "s#/home/x3xploiter0#$HOME#g" "$HOME/.config/autostart/libinput-gestures.desktop"

say "Ensuring input group membership"
getent group input >/dev/null && sudo usermod -aG input "$USER" 2>/dev/null || true

if id -nG | grep -qw input; then
  pgrep -f 'python3 .*libinput-gestures' >/dev/null 2>&1 || \
    (setsid "$BIN/libinput-gestures" -c "$HOME/.config/libinput-gestures.conf" >/dev/null 2>&1 < /dev/null &)
  say "Gesture daemon started."
else
  warn "Added to 'input' group. Log out and back in once, then the autostart entry will start it."
fi
