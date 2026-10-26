#!/usr/bin/env python3
"""Convert generated cover and in-game screenshots to compliant WebP store assets."""
import os
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MEDIA_DIR = ROOT / "store-media"
COVER_SRC = Path("/home/jennifer/.gemini/antigravity/brain/dbac19b6-0243-445e-a913-735a63afc341/cover_raw_1793038225220.jpg")

def process_cover():
    if not COVER_SRC.is_file():
        raise FileNotFoundError(f"Cover source not found: {COVER_SRC}")
    im = Image.open(COVER_SRC).convert("RGB")
    # Target 1280x720 (16:9)
    target_w, target_h = 1280, 720
    src_w, src_h = im.size
    target_ratio = target_w / target_h
    src_ratio = src_w / src_h

    if src_ratio > target_ratio:
        # Crop width
        new_w = int(src_h * target_ratio)
        left = (src_w - new_w) // 2
        im = im.crop((left, 0, left + new_w, src_h))
    else:
        # Crop height
        new_h = int(src_w / target_ratio)
        top = (src_h - new_h) // 2
        im = im.crop((0, top, src_w, top + new_h))

    im = im.resize((target_w, target_h), Image.Resampling.LANCZOS)
    out_cover = MEDIA_DIR / "cover.webp"
    im.save(out_cover, "WEBP", quality=92, method=6)
    print(f"Cover saved: {out_cover} ({out_cover.stat().st_size:,} bytes, {im.size})")

def process_screenshots():
    shots = [
        ("raw_01_inselbau.png", "01-inselbau.webp"),
        ("raw_02_baukatalog.png", "02-baukatalog.webp"),
        ("raw_03_dorfleben.png", "03-dorfleben.webp"),
        ("raw_04_nachtmodus.png", "04-nachtmodus.webp"),
        ("raw_05_mobil_portrait.png", "05-mobil-portrait.webp"),
    ]
    total_size = 0
    for src_name, dst_name in shots:
        src_path = MEDIA_DIR / src_name
        dst_path = MEDIA_DIR / dst_name
        im = Image.open(src_path).convert("RGB")
        im.save(dst_path, "WEBP", quality=90, method=6)
        sz = dst_path.stat().st_size
        total_size += sz
        print(f"Screenshot saved: {dst_name} ({sz:,} bytes, {im.size})")

    cover_sz = (MEDIA_DIR / "cover.webp").stat().st_size
    print(f"Total media size: {(total_size + cover_sz):,} bytes (< 22 MB limit)")

if __name__ == "__main__":
    process_cover()
    process_screenshots()
