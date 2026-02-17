#!/bin/bash
# deploy.sh - Script para compilar e instalar la app rápidamente

set -e  # Salir si hay errores

echo "🧹 Limpiando cache de Godot..."
rm -rf features/godot/.godot

echo "📦 Exportando Godot project..."
cd features/godot
rm -f app_game.pck
godot4 --headless --export-pack "Android" app_game.pck 2>&1 | tail -1
echo "✅ app_game.pck exportado ($(du -h app_game.pck | cut -f1))"

echo "📋 Copiando a assets..."
cp app_game.pck ../../app/src/main/assets/
cd ../..

echo "🔨 Compilando APK..."
./gradlew assembleDebug 2>&1 | grep "BUILD"

echo "📱 Instalando en dispositivo..."
adb install -r app/build/outputs/apk/debug/app-debug.apk

echo "🚀 Iniciando app..."
adb shell am force-stop com.framework
adb shell am start -n com.framework/.MainActivity

echo "✅ ¡Listo! Monitoreando logs..."
sleep 2
adb logcat -d | grep "I godot" | tail -20
