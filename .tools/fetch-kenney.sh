#!/usr/bin/env bash
# Descarga packs CC0 de Kenney.nl (sprites, escenarios, sonidos, UI) — licencia CC0
# Uso: bash fetch-kenney.sh <slug> [directorio_destino]
#   Ej: bash fetch-kenney.sh platformer-kit assets/kenney/platformer
#       bash fetch-kenney.sh ui-audio assets/kenney/ui-audio
#       bash fetch-kenney.sh game-icons assets/kenney/icons
#   Lista de packs: https://kenney.nl/assets (buscar slug en la URL de cada pack)
set -euo pipefail

SLUG="${1:?Uso: bash fetch-kenney.sh <slug> [destino]}"
DEST="${2:-assets/kenney/$SLUG}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "→ Buscando pack '$SLUG' en kenney.nl..."
PAGE_URL="https://kenney.nl/assets/$SLUG"
PAGE="$(curl -fsSL "$PAGE_URL" || { echo "✗ No existe el pack '$SLUG' en kenney.nl" >&2; exit 1; })"

# El enlace de descarga es un href terminado en .zip dentro de la página
ZIP_URL="$(printf '%s' "$PAGE" | grep -oE 'https?://[^"'"'"' ]+\.zip' | head -1 || true)"
if [ -z "$ZIP_URL" ]; then
  # Fallback: patrón relativo href="/media/pages/..."
  REL="$(printf '%s' "$PAGE" | grep -oE 'href="[^"]+\.zip"' | grep -oE '/media/pages/[^"]+\.zip' | head -1 || true)"
  [ -n "$REL" ] && ZIP_URL="https://kenney.nl$REL"
fi
if [ -z "$ZIP_URL" ]; then
  echo "✗ No se encontró enlace .zip en la página. El pack puede exigir otra ruta." >&2
  exit 1
fi

echo "→ Descargando $ZIP_URL"
mkdir -p "$DEST" "$TMP/unzip"
curl -fSL "$ZIP_URL" -o "$TMP/pack.zip"
unzip -q "$TMP/pack.zip" -d "$TMP/unzip"
if [ -d "$TMP/unzip/PNG" ]; then
  cp -r "$TMP/unzip/PNG"/* "$DEST/" 2>/dev/null || true
fi
find "$TMP/unzip" -type f \( -name '*.png' -o -name '*.wav' -o -name '*.ogg' -o -name '*.mp3' -o -name '*.json' -o -name '*.xml' \) -exec cp {} "$DEST/" \; 2>/dev/null || true

COUNT="$(find "$DEST" -type f | wc -l)"
echo "✓ Pack '$SLUG' (CC0) → $DEST ($COUNT archivos)"
echo "Licencia: CC0 — atribución opcional, uso libre."