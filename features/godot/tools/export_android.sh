#!/usr/bin/env bash
set -euo pipefail

# Exporta Android desde CLI (Godot 4)
# Requisitos: templates de exportación instaladas y SDK Android configurado.

PROJECT_PATH="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_APK="${PROJECT_PATH}/build/GustaNuno-debug.apk"
PRESET_NAME="Android"

# Detectar binario de Godot
GODOT_BIN=${GODOT_BIN:-}
if [[ -z "${GODOT_BIN}" ]]; then
  for c in godot-4 godot4-mono godot4 godot; do
    if command -v "$c" >/dev/null 2>&1; then GODOT_BIN="$c"; break; fi
  done
fi

if [[ -z "${GODOT_BIN}" ]]; then
  echo "No se encontró el binario de Godot (godot-4/godot4-mono/godot4/godot). Instala Godot o define GODOT_BIN=/ruta/al/godot" >&2
  exit 1
fi
echo "Usando GODOT_BIN=${GODOT_BIN}"

mkdir -p "${PROJECT_PATH}/build"

# Configurar entorno JAVA/SDK si no está definido
if [[ -z "${JAVA_HOME:-}" ]]; then
  JAVA_BIN=$(command -v java || true)
  if [[ -n "$JAVA_BIN" ]]; then
    JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$JAVA_BIN")")")
    export JAVA_HOME
  fi
fi
if [[ -z "${ANDROID_SDK_ROOT:-}" ]]; then
  if [[ -d "$HOME/Android/Sdk" ]]; then
    export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
  fi
fi
echo "JAVA_HOME=${JAVA_HOME:-no-definido}"
echo "ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:-no-definido}"

# Exportar (debug). Para release usa --export-release
"${GODOT_BIN}" --headless \
  --path "${PROJECT_PATH}" \
  --export-debug "${PRESET_NAME}" "${OUTPUT_APK}"

echo "APK generado: ${OUTPUT_APK}"
