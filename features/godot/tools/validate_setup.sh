#!/bin/bash
# validate_setup.sh - Verifica que el entorno esté correctamente configurado

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Verificando Configuración de Godot + Android${NC}"
echo "=================================================="

ERRORS=0
WARNINGS=0

# 1. Verificar Godot instalado
echo -e "\n${BLUE}1. Godot Engine${NC}"
GODOT_BIN="${GODOT_BIN:-godot4}"
if command -v $GODOT_BIN &> /dev/null; then
    VERSION=$($GODOT_BIN --version 2>&1 | head -1)
    echo -e "${GREEN}✅ Godot encontrado: $VERSION${NC}"
else
    echo -e "${RED}❌ Godot no encontrado en PATH${NC}"
    echo "   Instala Godot 4.x o configura GODOT_BIN"
    ((ERRORS++))
fi

# 2. Verificar Android SDK
echo -e "\n${BLUE}2. Android SDK${NC}"
if [ -d "$ANDROID_SDK_ROOT" ] || [ -d "$ANDROID_HOME" ]; then
    SDK_PATH="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
    echo -e "${GREEN}✅ Android SDK encontrado: $SDK_PATH${NC}"
else
    echo -e "${YELLOW}⚠️  Android SDK no configurado${NC}"
    echo "   Configura ANDROID_SDK_ROOT o ANDROID_HOME"
    ((WARNINGS++))
fi

# 3. Verificar ADB
echo -e "\n${BLUE}3. ADB (Android Debug Bridge)${NC}"
if command -v adb &> /dev/null; then
    ADB_VERSION=$(adb version | head -1)
    echo -e "${GREEN}✅ ADB encontrado: $ADB_VERSION${NC}"
    
    # Verificar dispositivos
    DEVICES=$(adb devices | grep -c "device$" || true)
    if [ $DEVICES -gt 0 ]; then
        echo -e "${GREEN}   📱 $DEVICES dispositivo(s) conectado(s)${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Sin dispositivos conectados${NC}"
    fi
else
    echo -e "${RED}❌ ADB no encontrado${NC}"
    ((ERRORS++))
fi

# 4. Verificar Java/JDK
echo -e "\n${BLUE}4. Java JDK${NC}"
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -1)
    echo -e "${GREEN}✅ Java encontrado: $JAVA_VERSION${NC}"
    
    if [ -n "$JAVA_HOME" ]; then
        echo -e "${GREEN}   JAVA_HOME: $JAVA_HOME${NC}"
    else
        echo -e "${YELLOW}   ⚠️  JAVA_HOME no configurado${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}❌ Java no encontrado${NC}"
    ((ERRORS++))
fi

# 5. Verificar proyecto Godot
echo -e "\n${BLUE}5. Proyecto Godot${NC}"
if [ -f "features/godot/project.godot" ]; then
    echo -e "${GREEN}✅ project.godot encontrado${NC}"
    
    # Verificar export_presets.cfg
    if [ -f "features/godot/export_presets.cfg" ]; then
        echo -e "${GREEN}✅ export_presets.cfg encontrado${NC}"
    else
        echo -e "${YELLOW}⚠️  export_presets.cfg no encontrado${NC}"
        echo "   Configura un preset de exportación para Android en Godot"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}❌ Proyecto Godot no encontrado${NC}"
    ((ERRORS++))
fi

# 6. Verificar godot-lib.aar
echo -e "\n${BLUE}6. Godot AAR Library${NC}"
if [ -f "app/libs/godot-lib.aar" ]; then
    SIZE=$(stat -f%z "app/libs/godot-lib.aar" 2>/dev/null || stat -c%s "app/libs/godot-lib.aar")
    SIZE_MB=$((SIZE / 1024 / 1024))
    echo -e "${GREEN}✅ godot-lib.aar encontrado (${SIZE_MB}MB)${NC}"
else
    echo -e "${RED}❌ godot-lib.aar no encontrado en app/libs/${NC}"
    echo "   Exporta tu proyecto Godot como AAR"
    ((ERRORS++))
fi

# 7. Verificar assets
echo -e "\n${BLUE}7. Assets (PCK)${NC}"
if [ -f "app/src/main/assets/app_game.pck" ]; then
    SIZE=$(stat -f%z "app/src/main/assets/app_game.pck" 2>/dev/null || stat -c%s "app/src/main/assets/app_game.pck")
    SIZE_KB=$((SIZE / 1024))
    echo -e "${GREEN}✅ app_game.pck encontrado (${SIZE_KB}KB)${NC}"
    
    if [ $SIZE -lt 100000 ]; then
        echo -e "${YELLOW}   ⚠️  PCK muy pequeño, podría estar corrupto${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}⚠️  app_game.pck no encontrado en assets${NC}"
    echo "   Ejecuta: ./gradlew :features:godot:exportGodotPack"
    ((WARNINGS++))
fi

# 8. Verificar Gradle
echo -e "\n${BLUE}8. Gradle${NC}"
if [ -f "gradlew" ]; then
    echo -e "${GREEN}✅ Gradle wrapper encontrado${NC}"
else
    echo -e "${RED}❌ gradlew no encontrado${NC}"
    ((ERRORS++))
fi

# Resumen
echo -e "\n${BLUE}=================================================${NC}"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ Todo configurado correctamente!${NC}"
    echo ""
    echo "Comandos útiles:"
    echo "  ./gradlew :features:godot:exportGodotPack  # Exportar Godot"
    echo "  ./gradlew assembleDebug                     # Compilar APK"
    echo "  ./deploy.sh                                 # Build + Install"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Configuración con advertencias ($WARNINGS)${NC}"
    echo "   Revisa los items marcados arriba"
    exit 0
else
    echo -e "${RED}❌ Configuración incompleta ($ERRORS errores, $WARNINGS advertencias)${NC}"
    echo "   Corrige los errores antes de continuar"
    exit 1
fi
