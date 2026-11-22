#!/usr/bin/env python3
"""Generate a macOS-style XFWM4 theme (traffic lights + Catppuccin glass)."""
from __future__ import annotations

import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw

TITLE_HEIGHT = 31
BORDER = 2
CORNER = 16
BUTTON = 28

ACTIVE_BG = (17, 17, 27, 255)      # #11111b
INACTIVE_BG = (24, 24, 37, 255)    # #181825

LIGHTS = {
    "close": (233, 82, 74),       # WhiteSur macOS red
    "hide": (241, 174, 27),       # WhiteSur macOS yellow
    "maximize": (89, 200, 55),    # WhiteSur macOS green
    "maximize-toggled": (89, 200, 55),
}


def rgba(hex_color: str) -> tuple[int, int, int, int]:
    h = hex_color.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (255,)


def shade(rgb: tuple[int, int, int], factor: float) -> tuple[int, int, int]:
    return tuple(min(255, max(0, int(c * factor))) for c in rgb)


def disc(size: int, color: tuple[int, int, int], dim: bool = False, factor: float = 1.0):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    base = shade(color, 0.42) if dim else color
    fill = shade(base, factor)
    r = (size - 2) / 2
    box = (1, 1, size - 2, size - 2)
    draw.ellipse(box, fill=fill + (255,))
    if not dim:
        # subtle top-left specular highlight
        hi = shade(base, 1.35)
        draw.arc(box, 190, 300, fill=hi + (255,), width=2)
    return img


def solid(width: int, height: int, color: tuple[int, int, int, int]) -> Image.Image:
    return Image.new("RGBA", (width, height), color)


def corner(which: str, color: tuple[int, int, int, int]) -> Image.Image:
    img = Image.new("RGBA", (CORNER, TITLE_HEIGHT), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    r = CORNER
    if which in ("top-left", "bottom-left"):
        draw.pieslice((-r, -r, r, r), 0, 90, fill=color) if which == "top-left" else draw.pieslice((-r, TITLE_HEIGHT - r, r, TITLE_HEIGHT + r), 270, 360, fill=color)
        draw.rectangle((CORNER // 2, 0, CORNER - 1, TITLE_HEIGHT - 1), fill=color)
    else:
        draw.pieslice((CORNER - r, -r, CORNER + r, r), 90, 180, fill=color) if which == "top-right" else draw.pieslice((CORNER - r, TITLE_HEIGHT - r, CORNER + r, TITLE_HEIGHT + r), 180, 270, fill=color)
        draw.rectangle((0, 0, CORNER // 2, TITLE_HEIGHT - 1), fill=color)
    return img


def write(directory: Path, name: str, img: Image.Image) -> None:
    img.save(directory / f"{name}.png")


def build(directory: Path) -> None:
    directory.mkdir(parents=True, exist_ok=True)

    for name, color in LIGHTS.items():
        write(directory, f"{name}-active", disc(BUTTON, color))
        write(directory, f"{name}-inactive", disc(BUTTON, color, dim=True))
        write(directory, f"{name}-prelight-active", disc(BUTTON, color, factor=1.18))
        write(directory, f"{name}-prelight-inactive", disc(BUTTON, color, dim=True))
        write(directory, f"{name}-pressed-active", disc(BUTTON, color, factor=0.78))
        write(directory, f"{name}-pressed-inactive", disc(BUTTON, color, dim=True, factor=0.32))

    understated = (108, 114, 134)
    for name in ("menu", "shade", "shade-toggled", "stick", "stick-toggled"):
        write(directory, f"{name}-active", disc(BUTTON, understated, factor=1.4))
        write(directory, f"{name}-inactive", disc(BUTTON, understated, dim=True))
        write(directory, f"{name}-prelight-active", disc(BUTTON, (166, 173, 200)))
        write(directory, f"{name}-prelight-inactive", disc(BUTTON, understated, dim=True))
        write(directory, f"{name}-pressed-active", disc(BUTTON, (88, 91, 112)))
        write(directory, f"{name}-pressed-inactive", disc(BUTTON, understated, dim=True))

    for side in ("top-left", "top-right", "bottom-left", "bottom-right"):
        write(directory, f"{side}-active", corner(side, ACTIVE_BG))
        write(directory, f"{side}-inactive", corner(side, INACTIVE_BG))

    # XFWM derives the titlebar height from title-*.png; keep it at 31px.
    for i in range(1, 6):
        write(directory, f"title-{i}-active", solid(5, TITLE_HEIGHT, ACTIVE_BG))
        write(directory, f"title-{i}-inactive", solid(5, TITLE_HEIGHT, INACTIVE_BG))

    for name, w, h in (
        ("top", BORDER, BORDER),
        ("bottom", BORDER, BORDER),
        ("left", BORDER, BORDER),
        ("right", BORDER, BORDER),
    ):
        write(directory, f"{name}-active", solid(w, h, ACTIVE_BG))
        write(directory, f"{name}-inactive", solid(w, h, INACTIVE_BG))

    themerc = """active_text_color=#cdd6f4
inactive_text_color=#6c7086
full_width_title=true
title_shadow_active=false
title_shadow_inactive=false
title_vertical_offset_active=1
title_vertical_offset_inactive=1
title_horizontal_offset=0
button_offset=6
button_spacing=4
show_app_icon=false
shadow_delta_height=0
shadow_delta_width=0
shadow_delta_x=0
shadow_delta_y=0
shadow_opacity=0
"""
    (directory / "themerc").write_text(themerc)
    print(f"generated {directory}")


if __name__ == "__main__":
    targets = sys.argv[1:]
    if not targets:
        targets = [str(Path.home() / ".themes/WhiteSur-MacOS/xfwm4")]
    for target in targets:
        build(Path(target))
