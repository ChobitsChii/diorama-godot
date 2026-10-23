#!/usr/bin/env python3
"""Build and verify a signed Android Release APK for Diorama Sandbox."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
CREDS_FILE = Path.home() / ".local/share/diorama/signing/credentials.json"
EXPECTED_CERT_SHA256 = "a36a3326986f9c6da099df5f9ea9ad914f48aae26a5a9dd47684c5e25b1e428f"
EXPECTED_PACKAGE = "de.chobitschii.diorama"

def find_tool(tool: str) -> str:
    found = shutil.which(tool)
    if found:
        return found
    sdk_candidates = [
        "/opt/android-sdk",
        os.environ.get("ANDROID_HOME", ""),
        os.environ.get("ANDROID_SDK_ROOT", ""),
        str(Path.home() / "Android/Sdk"),
    ]
    for sdk in sdk_candidates:
        if not sdk:
            continue
        matches = sorted(Path(sdk).glob(f"build-tools/*/{tool}"), reverse=True)
        if matches:
            return str(matches[0])
    raise RuntimeError(f"Tool {tool} not found in PATH or Android SDK")

def main():
    if not CREDS_FILE.is_file():
        raise SystemExit(f"Credentials file {CREDS_FILE} not found.")

    creds = json.loads(CREDS_FILE.read_text(encoding="utf-8"))
    keystore_path = Path(creds["path"])
    if not keystore_path.is_file():
        raise SystemExit(f"Keystore file {keystore_path} not found.")

    output_apk = ROOT / "builds/android/diorama-0.1.0-beta.12.apk"
    output_apk.parent.mkdir(parents=True, exist_ok=True)

    env = os.environ.copy()
    env["GODOT_ANDROID_KEYSTORE_RELEASE_PATH"] = str(keystore_path)
    env["GODOT_ANDROID_KEYSTORE_RELEASE_USER"] = creds["alias"]
    env["GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD"] = creds["password"]
    env["PATH"] = f"/opt/android-sdk/build-tools/37.0.0:/opt/android-sdk/platform-tools:{env.get('PATH', '')}"

    print(f"Exporting release APK to {output_apk} ...")
    cmd = [
        "godot", "--headless", "--path", str(ROOT),
        "--export-release", "Android", str(output_apk)
    ]
    res = subprocess.run(cmd, env=env)
    if res.returncode != 0:
        raise SystemExit(f"Godot export failed with code {res.returncode}")

    if not output_apk.is_file() or output_apk.stat().st_size == 0:
        raise SystemExit(f"Exported APK {output_apk} does not exist or is empty.")

    print(f"Exported successfully ({output_apk.stat().st_size:,} bytes).")

    # Verify signature
    apksigner = find_tool("apksigner")
    sig_res = subprocess.run([apksigner, "verify", "--print-certs", str(output_apk)], capture_output=True, text=True, check=True)
    fingerprints = {
        value.replace(":", "").lower()
        for value in re.findall(r"certificate SHA-256 digest:\s*([0-9a-fA-F:]+)", sig_res.stdout)
    }
    if not fingerprints:
        raise SystemExit("No signing certificate found on APK!")
    if len(fingerprints) != 1:
        raise SystemExit(f"Multiple fingerprints found on APK: {fingerprints}")
    
    cert_sha256 = fingerprints.pop()
    print(f"APK Signing Certificate SHA-256: {cert_sha256}")
    if cert_sha256 != EXPECTED_CERT_SHA256:
        raise SystemExit(f"Certificate mismatch! Expected {EXPECTED_CERT_SHA256}, got {cert_sha256}")

    # Verify package name and version
    aapt = find_tool("aapt")
    badging_res = subprocess.run([aapt, "dump", "badging", str(output_apk)], capture_output=True, text=True, check=True)
    match = re.search(r"package:\s+name='([^']+)'\s+versionCode='(\d+)'\s+versionName='([^']+)'", badging_res.stdout)
    if not match:
        raise SystemExit("Could not read package badging from APK!")
    pkg_name, version_code, version_name = match.group(1), int(match.group(2)), match.group(3)
    print(f"Package: {pkg_name}, versionCode: {version_code}, versionName: {version_name}")

    if pkg_name != EXPECTED_PACKAGE:
        raise SystemExit(f"Package name mismatch! Expected {EXPECTED_PACKAGE}, got {pkg_name}")
    if version_code < 1:
        raise SystemExit(f"Invalid versionCode: {version_code}")

    print("ALL VERIFICATIONS PASSED!")

if __name__ == "__main__":
    main()
