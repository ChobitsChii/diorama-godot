#!/usr/bin/env bash
set -e

# ==============================================================================
# Deploy Godot Web Export to GitHub Pages (gh-pages branch)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

WEB_DIR="builds/web"

if [ ! -d "$WEB_DIR" ] || [ ! -f "$WEB_DIR/index.html" ]; then
    echo "❌ Fehler: Kein Web-Export in '$WEB_DIR' gefunden (index.html fehlt)."
    echo "Bitte exportiere das Godot-Projekt zuerst nach $WEB_DIR/index.html."
    exit 1
fi

REMOTE_URL=$(git config --get remote.origin.url || echo "")
if [ -z "$REMOTE_URL" ]; then
    echo "❌ Fehler: Kein Git Remote 'origin' konfiguriert."
    exit 1
fi

echo "🚀 Bereite GitHub Pages Deployment aus '$WEB_DIR' vor..."

TMP_PAGES=$(mktemp -d)
trap 'rm -rf "$TMP_PAGES"' EXIT

if git ls-remote --exit-code --heads "$REMOTE_URL" gh-pages &>/dev/null; then
    git clone --depth 1 --branch gh-pages "$REMOTE_URL" "$TMP_PAGES" -q
    cd "$TMP_PAGES"
    # Entferne alte Dateien (außer .git)
    find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
else
    git clone --depth 1 "$REMOTE_URL" "$TMP_PAGES" -q
    cd "$TMP_PAGES"
    git checkout --orphan gh-pages -q
    git rm -rf . -q 2>/dev/null || true
fi

cp -r "$SCRIPT_DIR/$WEB_DIR/"* .
touch .nojekyll

git add -A

if git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "ℹ Keine Änderungen im Web-Export festgestellt. Bereits auf dem neuesten Stand."
    exit 0
fi

git commit -m "Deploy Godot Web build to GitHub Pages ($(date '+%Y-%m-%d %H:%M:%S'))" -q

echo "⬆ Pushe Web-Build zu 'origin/gh-pages'..."
git push origin gh-pages

echo "✓ GitHub Pages erfolgreich aktualisiert!"
echo "🔗 URL: https://chobitschii.github.io/diorama-godot/"
