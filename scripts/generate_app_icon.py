#!/usr/bin/env python3
"""
Generate macOS AppIcon.icns for NotepadMac.
Creates a macOS Big Sur squircle icon with Scintilla code styling and Lua accents.
"""

import os
import subprocess  # nosec B404

from PIL import Image, ImageDraw


def create_master_icon(size=1024):
    # Canvas with transparency
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Squircle padding (macOS icon grid: ~824px wide on 1024 canvas)
    pad = 100
    w = size - 2 * pad
    h = size - 2 * pad
    radius = 180

    # Squircle background gradient / dark slate
    # Base dark container (#21252b / #1e2227)
    draw.rounded_rectangle(
        [pad, pad, pad + w, pad + h],
        radius=radius,
        fill=(33, 37, 43, 255),
        outline=(60, 68, 80, 255),
        width=6,
    )

    # Top title/tab bar inside squircle
    bar_h = 100
    draw.rounded_rectangle(
        [pad, pad, pad + w, pad + bar_h + radius], radius=radius, fill=(24, 27, 31, 255)
    )
    # Mask bottom half of top rounded rect
    draw.rectangle(
        [pad, pad + bar_h, pad + w, pad + bar_h + radius], fill=(33, 37, 43, 255)
    )

    # Traffic light dots
    tl_y = pad + 45
    draw.ellipse([pad + 50, tl_y - 12, pad + 74, tl_y + 12], fill=(255, 95, 87, 255))
    draw.ellipse([pad + 90, tl_y - 12, pad + 114, tl_y + 12], fill=(254, 188, 46, 255))
    draw.ellipse([pad + 130, tl_y - 12, pad + 154, tl_y + 12], fill=(40, 200, 64, 255))

    # Editor margin (line numbers column)
    margin_x = pad + 140
    draw.line(
        [(margin_x, pad + bar_h), (margin_x, pad + h - 10)],
        fill=(50, 56, 66, 255),
        width=4,
    )

    # Line number bars in margin
    for i in range(7):
        ly = pad + bar_h + 60 + i * 80
        draw.rounded_rectangle(
            [pad + 60, ly, margin_x - 30, ly + 14], radius=7, fill=(90, 99, 115, 255)
        )

    # Code syntax lines (Scintilla styling)
    code_lines = [
        # Line 1: Keyword, Identifier, Operator, Value
        [
            (margin_x + 40, 160, (198, 120, 221, 255)),
            (margin_x + 220, 260, (224, 108, 117, 255)),
            (margin_x + 500, 140, (86, 182, 194, 255)),
        ],
        # Line 2: Indented string / call
        [
            (margin_x + 100, 220, (97, 175, 239, 255)),
            (margin_x + 340, 320, (152, 195, 121, 255)),
        ],
        # Line 3: Keyword, Number
        [
            (margin_x + 100, 180, (198, 120, 221, 255)),
            (margin_x + 300, 140, (209, 154, 102, 255)),
        ],
        # Line 4: Comment line
        [(margin_x + 100, 480, (92, 99, 112, 255))],
        # Line 5: Preprocessor / Lua badge
        [
            (margin_x + 40, 200, (229, 192, 123, 255)),
            (margin_x + 260, 340, (152, 195, 121, 255)),
        ],
        # Line 6: Closing block
        [(margin_x + 40, 140, (198, 120, 221, 255))],
    ]

    for idx, line in enumerate(code_lines):
        ly = pad + bar_h + 60 + idx * 80
        for x, w_block, col in line:
            draw.rounded_rectangle([x, ly, x + w_block, ly + 20], radius=10, fill=col)

    # Lua / Scintilla Badge in bottom right
    badge_cx = pad + w - 160
    badge_cy = pad + h - 160
    badge_r = 110

    # Badge circle
    draw.ellipse(
        [
            badge_cx - badge_r,
            badge_cy - badge_r,
            badge_cx + badge_r,
            badge_cy + badge_r,
        ],
        fill=(0, 0, 128, 255),
        outline=(82, 139, 255, 255),
        width=8,
    )
    # Inner moon orbit
    draw.ellipse(
        [badge_cx - 40, badge_cy - 40, badge_cx + 40, badge_cy + 40],
        fill=(255, 255, 255, 255),
    )
    # Orbit satellite
    draw.ellipse(
        [badge_cx + 45, badge_cy - 65, badge_cx + 75, badge_cy - 35],
        fill=(255, 255, 255, 255),
    )

    return img


def main():
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    iconset_dir = os.path.join(repo_root, "Resources", "AppIcon.iconset")
    os.makedirs(iconset_dir, exist_ok=True)

    master = create_master_icon(1024)

    sizes = [
        ("icon_16x16.png", 16),
        ("icon_16x16@2x.png", 32),
        ("icon_32x32.png", 32),
        ("icon_32x32@2x.png", 64),
        ("icon_128x128.png", 128),
        ("icon_128x128@2x.png", 256),
        ("icon_256x256.png", 256),
        ("icon_256x256@2x.png", 512),
        ("icon_512x512.png", 512),
        ("icon_512x512@2x.png", 1024),
    ]

    for filename, sz in sizes:
        resized = master.resize((sz, sz), Image.Resampling.LANCZOS)
        out_path = os.path.join(iconset_dir, filename)
        resized.save(out_path, "PNG")
        print(f"Generated {filename} ({sz}x{sz})")

    icns_path = os.path.join(repo_root, "Resources", "AppIcon.icns")
    subprocess.run(  # nosec B603, B607
        ["/usr/bin/iconutil", "-c", "icns", iconset_dir, "-o", icns_path],
        check=True,
    )
    print(f"Successfully generated AppIcon.icns at {icns_path}")


if __name__ == "__main__":
    main()
