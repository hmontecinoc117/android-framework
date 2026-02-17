#!/bin/bash
# deploy.sh - Script mejorado para compilar y desplegar la app con Godot

set -e  # Exit on error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
PCK_NAME="app_game.pck"
APK_NAME="Juegos_GustaNuno.apk"
PACKAGE_NAME="com.framework"
GODOT_BIN="${GODOT_BIN:-godot4}"

echo -e "${BLUE}🎮 Godot + Android Build & Deploy${NC}"
echo "========================================"

# Función para verificar comandos
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ Error: $1 no encontrado${NC}"
        echo "   Instala $1 o agrégalo al PATH"
        exit 1
    fi
}

# Verificar herramientas necesarias
echo -e "${BLUE}🔍 Verificando herramientas...${NC}"
check_command "adb"
check_command "$GODOT_BIN"

# Verificar dispositivo conectado
if ! adb devices | grep -q "device$"; then
    echo -e "${YELLOW}⚠️  Advertencia: No hay dispositivos Android conectados${NC}"
    read -p "Continuar de todos modos? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Paso 1: Exportar Godot project
echo ""
echo -e "${BLUE}📦 Paso 1/4: Exportando proyecto Godot...${NC}"
cd features/godot

# Limpiar PCK anterior
if [ -f "$PCK_NAME" ]; then
    echo "🗑️  Eliminando PCK anterior..."
    rm -f "$PCK_NAME"
fi

# Exportar
echo "⚙️  Ejecutando: $GODOT_BIN --headless --export-pack \"Android\" $PCK_NAME"
if $GODOT_BIN --headless --export-pack "Android" "$PCK_NAME" 2>&1 | grep -v "Godot Engine"; then
    echo -e "${GREEN}✅ Exportación completada${NC}"
else
    echo -e "${RED}❌ Error al exportar proyecto Godot${NC}"
    exit 1
fi

# Verificar archivo generado
if [ ! -f "$PCK_NAME" ]; then
    echo -e "${RED}❌ Error: No se generó el archivo $PCK_NAME${NC}"
    exit 1
fi

# Verificar tamaño
SIZE=$(stat -f%z "$PCK_NAME" 2>/dev/null || stat -c%s "$PCK_NAME")
SIZE_KB=$((SIZE / 1024))
echo -e "${GREEN}📊 Tamaño del PCK: ${SIZE_KB}KB${NC}"

if [ $SIZE -lt 100000 ]; then
    echo -e "${YELLOW}⚠️  Advertencia: PCK parece muy pequeño (<100KB)${NC}"
    read -p "Continuar de todos modos? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Copiar a assets
echo "📋 Copiando a app/src/main/assets/..."
mkdir -p ../../app/src/main/assets
cp -f "$PCK_NAME" ../../app/src/main/assets/
echo -e "${GREEN}✅ PCK copiado a assets${NC}"

cd ../..

# Paso 2: Limpiar y compilar Android app
echo ""
echo -e "${BLUE}🔨 Paso 2/4: Compilando aplicación Android...${NC}"
echo "⚙️  Ejecutando: ./gradlew clean assembleDebug"

if ./gradlew clean assembleDebug 2>&1 | grep -E "BUILD SUCCESSFUL|BUILD FAILED"; then
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo -e "${GREEN}✅ Compilación exitosa${NC}"
    else
        echo -e "${RED}❌ Error en la compilación${NC}"
        exit 1
    fi
fi

# Verificar APK generado
APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}❌ Error: No se generó el APK${NC}"
    exit 1
fi

APK_SIZE=$(stat -f%z "$APK_PATH" 2>/dev/null || stat -c%s "$APK_PATH")
APK_SIZE_MB=$((APK_SIZE / 1024 / 1024))
echo -e "${GREEN}📊 Tamaño del APK: ${APK_SIZE_MB}MB${NC}"

# Paso 3: Instalar en dispositivo
echo ""
echo -e "${BLUE}📱 Paso 3/4: Instalando en dispositivo...${NC}"

if adb devices | grep -q "device$"; then
    echo "⚙️  Ejecutando: adb install -r $APK_PATH"
    if adb install -r "$APK_PATH"; then
        echo -e "${GREEN}✅ Instalación completada${NC}"
    else
        echo -e "${RED}❌ Error al instalar APK${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Sin dispositivo conectado, omitiendo instalación${NC}"
fi

# Paso 4: Lanzar aplicación
echo ""
echo -e "${BLUE}🚀 Paso 4/4: Lanzando aplicación...${NC}"

if adb devices | grep -q "device$"; then
    # Forzar detener app anterior
    adb shell am force-stop "$PACKAGE_NAME" 2>/dev/null || true
    
    echo "⚙️  Iniciando actividad principal..."
    if adb shell am start -n "$PACKAGE_NAME/.MainActivity"; then
        echo -e "${GREEN}✅ Aplicación iniciada${NC}"
    else
        echo -e "${YELLOW}⚠️  No se pudo iniciar automáticamente${NC}"
    fi
    
    # Mostrar logs
    echo ""
    echo -e "${BLUE}📋 Logs en tiempo real (Ctrl+C para salir):${NC}"
    echo "----------------------------------------"
    adb logcat -c  # Limpiar logs anteriores
    adb logcat | grep -E "godot|GodotGameActivity|AndroidRuntime"
else
    echo -e "${YELLOW}⚠️  Sin dispositivo conectado, omitiendo lanzamiento${NC}"
fi

echo ""
echo -e "${GREEN}✅✅✅ Deploy completado exitosamente ✅✅✅${NC}"
