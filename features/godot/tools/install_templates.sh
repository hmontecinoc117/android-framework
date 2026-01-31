#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="4.5.stable"
PRIMARY_URL="https://downloads.tuxfamily.org/godotengine/4.5/Godot_v4.5-stable_export_templates.tpz"
FALLBACK_URL_1="https://github.com/godotengine/godot/releases/download/4.5-stable/Godot_v4.5-stable_export_templates.tpz"
FALLBACK_URL_2="https://archive.hugo.pro/godot/4.5/Godot_v4.5-stable_export_templates.tpz"
CURL_OPTS=(--fail --location --show-error --connect-timeout 10 --max-time 45)

# Detectar posibles rutas de instalación para Godot (snap y local)
DEST_DIRS=()
if [[ -d "$HOME/snap/godot4" ]]; then
  for d in "$HOME"/snap/godot4/*; do
    [[ -d "$d" ]] || continue
    DEST_DIRS+=("$d/.local/share/godot/export_templates/$VERSION_DIR")
  done
  # Ruta común del snap (persistente entre revisiones)
  DEST_DIRS+=("$HOME/snap/godot4/common/.local/share/godot/export_templates/$VERSION_DIR")
fi
# Ruta local estándar (no snap)
DEST_DIRS+=("$HOME/.local/share/godot/export_templates/$VERSION_DIR")

if [[ ${#DEST_DIRS[@]} -eq 0 ]]; then
  echo "No se detectaron rutas destino para templates de Godot." >&2
  exit 1
fi

for dir in "${DEST_DIRS[@]}"; do
  mkdir -p "$dir"
done

LOCAL_TPZ="${1:-}"
TMP=$(mktemp -d)
cd "$TMP"
if [[ -n "$LOCAL_TPZ" && -f "$LOCAL_TPZ" ]]; then
  echo "Usando archivo local: $LOCAL_TPZ"
  cp "$LOCAL_TPZ" ./templates.tpz
else
  echo "Intentando descarga primaria: $PRIMARY_URL"
  if ! curl "${CURL_OPTS[@]}" "$PRIMARY_URL" -o templates.tpz; then
    echo "Primario falló; intentando GitHub: $FALLBACK_URL_1"
    if ! curl "${CURL_OPTS[@]}" "$FALLBACK_URL_1" -o templates.tpz; then
      echo "GitHub falló; intentando mirror alternativo: $FALLBACK_URL_2"
      curl "${CURL_OPTS[@]}" "$FALLBACK_URL_2" -o templates.tpz
    fi
  fi
fi

# Elegir extractor disponible
EXTRACTOR=$(command -v bsdtar || true)
if [[ -z "$EXTRACTOR" ]]; then
  EXTRACTOR=$(command -v tar || true)
fi
if [[ -z "$EXTRACTOR" ]]; then
  echo "No se encontró 'bsdtar' ni 'tar' para extraer templates." >&2
  exit 1
fi

mkdir -p extract
if [[ "$EXTRACTOR" == *bsdtar ]]; then
  bsdtar -xf templates.tpz -C extract
else
  # Intentar con tar (soporta gzip/xz si está configurado)
  tar -xf templates.tpz -C extract
fi

echo "Instalando templates en ${#DEST_DIRS[@]} directorios"
for dir in "${DEST_DIRS[@]}"; do
  cp -r extract/* "$dir/"
  echo "→ Instalado en $dir"
  ls -1 "$dir" | head -n 5 || true
done

echo "Plantillas instaladas. Si Godot Editor estaba abierto, reinícialo."
