#!/usr/bin/env bash
# Make NetworkManager's legacy tray WiFi icons black on the white menu bar.
# Run from a terminal; it will prompt for your sudo password once.

set -euo pipefail

STAGE="$HOME/.local/share/icons/hicolor"
mkdir -p "$STAGE/22x22/apps" "$STAGE/scalable/apps"

echo "Generating dark nm-signal icons in $STAGE ..."

python3 - <<'PY'
from PIL import Image
import glob
import os

out = os.path.expanduser("~/.local/share/icons/hicolor/22x22/apps")
for src in glob.glob("/usr/share/icons/hicolor/22x22/apps/nm-signal*.png"):
    im = Image.open(src).convert("RGBA")
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a:
                px[x, y] = (17, 17, 27, a)  # dark, keep antialiasing/alpha
    im.save(os.path.join(out, os.path.basename(src)))
PY

for f in /usr/share/icons/hicolor/scalable/apps/nm-signal*.svg; do
    [ -f "$f" ] || continue
    sed -E 's/#(3583c8|4f9dd3|84a3dc|4169ab)/#11111b/g' "$f" \
        > "$STAGE/scalable/apps/$(basename "$f")"
done

echo "Installing (sudo required)..."
sudo cp -a /usr/share/icons/hicolor/22x22/apps/nm-signal-*.png \
    /usr/share/icons/hicolor/22x22/apps/nm-signal-*.png.bak 2>/dev/null || true
sudo cp -a /usr/share/icons/hicolor/scalable/apps/nm-signal-*.svg \
    /usr/share/icons/hicolor/scalable/apps/nm-signal-*.svg.bak 2>/dev/null || true
sudo cp "$STAGE"/22x22/apps/nm-signal-*.png /usr/share/icons/hicolor/22x22/apps/
sudo cp "$STAGE"/scalable/apps/nm-signal-*.svg /usr/share/icons/hicolor/scalable/apps/

echo "Restarting nm-applet..."
pkill -x nm-applet 2>/dev/null || true
sleep 1
nohup nm-applet >/dev/null 2>&1 &

echo "Done. WiFi icon should now be black."
