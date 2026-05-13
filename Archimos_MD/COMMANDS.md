#!/bin/bash

# Referencia rápida - Comandos útiles para el framework

echo "🚀 Android Framework - Comandos Rápidos"
echo "======================================="
echo ""

# Función para mostrar ayuda
show_help() {
    cat << EOF
COMANDOS DISPONIBLES:

📁 Estructura:
  ls -la                          # Ver archivos raíz
  find . -name "*.kt" | wc -l    # Contar archivos Kotlin
  
🔨 Build:
  ./gradlew build                 # Compilar completo
  ./gradlew clean build           # Limpiar y compilar
  ./gradlew assembleDebug         # Generar APK debug
  ./gradlew assembleRelease       # Generar APK release

▶️  Testing:
  ./gradlew test                  # Ejecutar tests unitarios
  ./gradlew connectedAndroidTest  # Tests en dispositivo
  ./gradlew test --info           # Tests con info detallada

📱 Emulador:
  emulator -list-avds             # Listar emuladores
  emulator -avd NombreAVD         # Iniciar emulador
  adb devices                     # Ver dispositivos conectados
  adb logcat                      # Ver logs en tiempo real

📊 Análisis:
  ./gradlew dependencyReport      # Reportes de dependencias
  ./gradlew lint                  # Análisis de código
  ./gradlew check                 # Verificar calidad

🔍 Debugging:
  adb shell                       # Acceso shell dispositivo
  adb push archivo /data/         # Enviar archivo
  adb pull /data/archivo .        # Descargar archivo

📦 Publicación:
  ./gradlew bundleRelease         # Generar Bundle (PlayStore)
  jarsigner -verify app.apk       # Verificar firma APK

🧹 Limpieza:
  ./gradlew clean                 # Limpiar build
  ./gradlew cleanBuildCache       # Limpiar caché
  rm -rf .gradle                  # Eliminar .gradle

📚 Info:
  ./gradlew projects              # Listar proyectos
  ./gradlew tasks                 # Listar tasks disponibles
  ./gradlew properties            # Ver propiedades

🎯 Módulos específicos:
  ./gradlew :app:build            # Compilar solo app
  ./gradlew :core:ui:build        # Compilar solo core/ui
  ./gradlew :features:basic:test  # Tests solo features/basic

💡 Tips útiles:
  Ctrl+Shift+A en AS              # Action finder
  Shift+F10                       # Run (Windows/Linux)
  Cmd+R                           # Run (Mac)
  Ctrl+Alt+L                      # Format code
  
EOF
}

# Mostrar ayuda por defecto
show_help

echo ""
echo "📖 Para más información:"
echo "  - README.md"
echo "  - TUTORIALS.md"
echo "  - CONTRIBUTING.md"
