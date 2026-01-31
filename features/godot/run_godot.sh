#!/bin/bash
# Script para ejecutar el proyecto Godot Educational Games

# Directorio del proyecto Godot
PROJECT_DIR="/home/xtotox/Documentos/android-framework/features/godot"

# Detección automática del ejecutable de Godot
if command -v godot4 &> /dev/null; then
    GODOT_BIN="godot4"
elif command -v godot &> /dev/null; then
    GODOT_BIN="godot"
elif [ -f "/usr/local/bin/godot" ]; then
    GODOT_BIN="/usr/local/bin/godot"
elif [ -f "$HOME/.local/bin/godot" ]; then
    GODOT_BIN="$HOME/.local/bin/godot"
elif [ -f "/snap/bin/godot" ]; then
    GODOT_BIN="/snap/bin/godot"
else
    echo "❌ Error: Godot no encontrado en el sistema"
    echo "Instálalo con: sudo snap install godot-4"
    echo "O descárgalo desde: https://godotengine.org/download"
    exit 1
fi

echo "🎮 Iniciando Godot Educational Games"
echo "📂 Proyecto: $PROJECT_DIR"
echo "🔧 Ejecutable: $GODOT_BIN"
echo ""

# Ejecutar Godot apuntando al proyecto, forzando OpenGL 3 por defecto
cd "$PROJECT_DIR" || exit 1

# Si no se especifica un driver de render, usar OpenGL 3 para evitar problemas de Vulkan
RENDERER_DEFAULT="opengl3"
ARGS=("--path" "$PROJECT_DIR")

has_render_flag=false
for arg in "$@"; do
    if [[ "$arg" == "--rendering-driver"* ]]; then
        has_render_flag=true
        break
    fi
done

if [[ "$has_render_flag" == false ]]; then
    ARGS+=("--rendering-driver" "$RENDERER_DEFAULT")
fi

# Pasar todos los argumentos del usuario al final
ARGS+=("$@")

"$GODOT_BIN" "${ARGS[@]}"
