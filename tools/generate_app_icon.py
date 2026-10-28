#!/usr/bin/env python3
"""Generate clean, crisp vector SVG and high-res PNG app icons for Diorama Sandbox."""
from pathlib import Path
import subprocess
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
ICONS_DIR = ROOT / "assets" / "icons"
ICONS_DIR.mkdir(parents=True, exist_ok=True)
ARTIFACT_DIR = Path("/home/jennifer/.gemini/antigravity/brain/83e4edc0-7cf1-4eee-bb13-30e6cf3aba4e")

# Rich Vector SVG (512x512) with central safe-zone (radius <= 145 from center 256,256)
SVG_MAIN = """<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="skyGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#38bdf8"/>
      <stop offset="55%" stop-color="#bae6fd"/>
      <stop offset="100%" stop-color="#7dd3fc"/>
    </linearGradient>
    <linearGradient id="grassLeft" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#4ade80"/>
      <stop offset="100%" stop-color="#22c55e"/>
    </linearGradient>
    <linearGradient id="roofLeft" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#f87171"/>
      <stop offset="100%" stop-color="#dc2626"/>
    </linearGradient>
    <linearGradient id="roofRight" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#ef4444"/>
      <stop offset="100%" stop-color="#b91c1c"/>
    </linearGradient>
  </defs>

  <!-- Full-bleed sky background (no rounded corners so OS masks cleanly!) -->
  <rect width="512" height="512" fill="url(#skyGrad)"/>

  <!-- Soft background clouds inside safe zone -->
  <g fill="#ffffff" opacity="0.82">
    <circle cx="172" cy="154" r="20"/>
    <circle cx="196" cy="146" r="26"/>
    <circle cx="220" cy="154" r="18"/>
    <rect x="172" y="152" width="48" height="20" rx="10"/>
  </g>

  <!-- Warm sun in upper right of safe zone -->
  <circle cx="330" cy="152" r="28" fill="#fde047" opacity="0.95"/>
  <circle cx="330" cy="152" r="21" fill="#fef08a"/>

  <!-- Soft drop shadow under floating island -->
  <ellipse cx="256" cy="388" rx="112" ry="26" fill="#0284c7" opacity="0.28"/>

  <!-- === FLOATING ISOMETRIC ISLAND PEDESTAL (Centered inside safe zone) === -->
  <!-- Layer 3: Tapered Slate Bedrock (#475569 / #334155) -->
  <polygon points="158,324 256,374 256,396 176,354" fill="#475569"/>
  <polygon points="354,324 256,374 256,396 336,354" fill="#334155"/>

  <!-- Layer 2: Deep Earth (#6d4c41 / #4e342e) -->
  <polygon points="140,294 256,352 256,376 158,326" fill="#6d4c41"/>
  <polygon points="372,294 256,352 256,376 354,326" fill="#4e342e"/>

  <!-- Layer 1: Top Soil Rim (#5c4033 / #3e2723) -->
  <polygon points="132,276 256,338 256,354 140,296" fill="#5c4033"/>
  <polygon points="380,276 256,338 256,354 372,296" fill="#3e2723"/>

  <!-- Lush Isometric Grass Top Surface -->
  <polygon points="256,214 380,276 256,338 132,276" fill="url(#grassLeft)"/>
  <polygon points="256,214 370,271 256,328 142,271" fill="#48bb78"/>

  <!-- Sparkling River / Pond Tile on Front-Right of Island -->
  <polygon points="262,280 334,244 362,258 290,295" fill="#0284c7"/>
  <polygon points="266,279 332,246 356,258 290,292" fill="#38bdf8"/>
  <!-- White water wave highlights -->
  <line x1="288" y1="274" x2="310" y2="263" stroke="#e0f2fe" stroke-width="4" stroke-linecap="round"/>
  <line x1="312" y1="276" x2="334" y2="265" stroke="#e0f2fe" stroke-width="3.5" stroke-linecap="round"/>

  <!-- Stepping Stones Path on Front-Left -->
  <ellipse cx="220" cy="292" rx="11" ry="6" fill="#e2e8f0"/>
  <ellipse cx="240" cy="306" rx="12" ry="6.5" fill="#cbd5e1"/>
  <ellipse cx="256" cy="318" rx="10" ry="5.5" fill="#e2e8f0"/>

  <!-- === PINE TREE (Back-Left of Island) === -->
  <rect x="180" y="242" width="12" height="22" rx="3" fill="#5c4033"/>
  <polygon points="186,196 156,244 216,244" fill="#15803d"/>
  <polygon points="186,196 186,244 216,244" fill="#166534"/>
  <polygon points="186,176 160,220 212,220" fill="#16a34a"/>
  <polygon points="186,176 186,220 212,220" fill="#15803d"/>
  <polygon points="186,158 166,196 206,196" fill="#22c55e"/>
  <polygon points="186,158 186,196 206,196" fill="#16a34a"/>

  <!-- === COZY COTTAGE HOUSE (Centerpiece of Island) === -->
  <!-- Left Cream Wall -->
  <polygon points="206,226 258,252 258,298 206,272" fill="#fffbeb" stroke="#78350f" stroke-width="3" stroke-linejoin="round"/>
  <!-- Right Shaded Cream Wall -->
  <polygon points="306,226 258,252 258,298 306,272" fill="#fde68a" stroke="#78350f" stroke-width="3" stroke-linejoin="round"/>

  <!-- Wooden Door on Left Wall -->
  <polygon points="224,254 242,263 242,291 224,282" fill="#78350f"/>
  <circle cx="238" cy="276" r="2.5" fill="#fbbf24"/>

  <!-- Warm Glowing Window on Right Wall -->
  <polygon points="270,252 292,240 292,262 270,274" fill="#fef08a" stroke="#78350f" stroke-width="3" stroke-linejoin="round"/>
  <line x1="281" y1="246" x2="281" y2="268" stroke="#78350f" stroke-width="2.5"/>
  <line x1="270" y1="263" x2="292" y2="251" stroke="#78350f" stroke-width="2.5"/>

  <!-- Chimney & Smoke Puffs -->
  <polygon points="274,176 290,184 290,216 274,208" fill="#64748b"/>
  <circle cx="284" cy="160" r="8.5" fill="#ffffff" opacity="0.88"/>
  <circle cx="294" cy="144" r="11.5" fill="#ffffff" opacity="0.68"/>

  <!-- Pitched Red Roof -->
  <polygon points="256,174 194,226 258,258 258,174" fill="url(#roofLeft)"/>
  <polygon points="256,174 318,226 258,258 256,174" fill="url(#roofRight)"/>
  <!-- Roof Ridge Highlight -->
  <line x1="256" y1="174" x2="194" y2="226" stroke="#fca5a5" stroke-width="4" stroke-linecap="round"/>
  <line x1="256" y1="174" x2="258" y2="258" stroke="#991b1b" stroke-width="3.5" stroke-linecap="round"/>

  <!-- === ROUND LEAFY TREE (Right Side) === -->
  <rect x="322" y="222" width="10" height="22" rx="3" fill="#5c4033"/>
  <circle cx="327" cy="206" r="21" fill="#22c55e"/>
  <circle cx="314" cy="212" r="15" fill="#4ade80"/>
  <circle cx="338" cy="212" r="15" fill="#16a34a"/>
  <circle cx="327" cy="192" r="15" fill="#4ade80"/>
  <!-- Red berries / apples on tree -->
  <circle cx="318" cy="204" r="3.5" fill="#ef4444"/>
  <circle cx="334" cy="200" r="3.5" fill="#ef4444"/>
  <circle cx="326" cy="216" r="3.5" fill="#ef4444"/>

  <!-- Cute Yellow Duck on the Pond -->
  <ellipse cx="312" cy="266" rx="9" ry="6" fill="#facc15"/>
  <circle cx="318" cy="260" r="5.5" fill="#fde047"/>
  <polygon points="323,259 329,261 323,263" fill="#f97316"/>
</svg>
"""

SVG_FOREGROUND = SVG_MAIN.replace('<rect width="512" height="512" fill="url(#skyGrad)"/>', '')

SVG_BACKGROUND = """<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="skyGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#38bdf8"/>
      <stop offset="55%" stop-color="#bae6fd"/>
      <stop offset="100%" stop-color="#7dd3fc"/>
    </linearGradient>
  </defs>
  <rect width="512" height="512" fill="url(#skyGrad)"/>
</svg>
"""

def render_svg(svg_path: Path, png_path: Path, size: int):
    subprocess.run([
        "rsvg-convert", "-w", str(size), "-h", str(size),
        str(svg_path), "-o", str(png_path)
    ], check=True)

def main():
    icon_svg = ROOT / "icon.svg"
    icon_svg.write_text(SVG_MAIN, encoding="utf-8")

    fg_svg = ICONS_DIR / "android_adaptive_fg.svg"
    bg_svg = ICONS_DIR / "android_adaptive_bg.svg"
    fg_svg.write_text(SVG_FOREGROUND, encoding="utf-8")
    bg_svg.write_text(SVG_BACKGROUND, encoding="utf-8")

    # Render PNGs for Android Launcher Icons & Preview
    main_512 = ICONS_DIR / "app_icon_512.png"
    main_192 = ICONS_DIR / "android_main_192.png"
    fg_432 = ICONS_DIR / "android_adaptive_fg_432.png"
    bg_432 = ICONS_DIR / "android_adaptive_bg_432.png"

    render_svg(icon_svg, main_512, 512)
    render_svg(icon_svg, main_192, 192)
    render_svg(fg_svg, fg_432, 432)
    render_svg(bg_svg, bg_432, 432)

    # Create a comparison preview showing Full Square, Squircle mask, and Circle mask (Android Safe Zone)
    src = Image.open(main_512).convert("RGBA")
    preview = Image.new("RGBA", (1120, 420), (241, 245, 249, 255))

    # 1. Full 320x320 icon
    ic_320 = src.resize((320, 320), Image.Resampling.LANCZOS)
    preview.paste(ic_320, (40, 50), ic_320)

    # 2. Squircle / Rounded Mask (typical Samsung / Xiaomi / iOS)
    mask_sq = Image.new("L", (320, 320), 0)
    draw_sq = ImageDraw.Draw(mask_sq)
    draw_sq.rounded_rectangle((28, 28, 292, 292), radius=68, fill=255)
    ic_sq = Image.new("RGBA", (320, 320), (0, 0, 0, 0))
    ic_sq.paste(ic_320, (0, 0), mask_sq)
    preview.paste(ic_sq, (400, 50), ic_sq)

    # 3. Strict Android Adaptive Circle Mask (66/108 = 61.1% diameter = 196px out of 320px!)
    mask_circ = Image.new("L", (320, 320), 0)
    draw_circ = ImageDraw.Draw(mask_circ)
    # 66/108 of 320 is ~196 -> margin is (320 - 196)/2 = 62
    draw_circ.ellipse((52, 52, 268, 268), fill=255)
    ic_circ = Image.new("RGBA", (320, 320), (0, 0, 0, 0))
    ic_circ.paste(ic_320, (0, 0), mask_circ)
    preview.paste(ic_circ, (760, 50), ic_circ)

    preview_path = ARTIFACT_DIR / "app_icon_preview.png"
    preview.save(preview_path)
    print(f"Saved preview to {preview_path}")

if __name__ == "__main__":
    main()
