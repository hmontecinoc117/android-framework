#!/bin/bash

# Script para comenzar con el framework Android

echo "╔════════════════════════════════════════════╗"
echo "║  Android Framework - Setup Inicial         ║"
echo "║  Kotlin + Jetpack Compose                  ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Verificar si Android Studio está disponible
if command -v android-studio &> /dev/null; then
    echo "✅ Android Studio detectado"
else
    echo "⚠️  Android Studio no encontrado en PATH"
    echo "   Descárgalo desde: https://developer.android.com/studio"
fi

echo ""
echo "📋 Checklist de configuración:"
echo ""
echo "1. Abre este proyecto en Android Studio"
echo "   File > Open > Selecciona la carpeta"
echo ""
echo "2. Espera a que se sincronice Gradle"
echo "   Esto puede tarear 2-5 minutos"
echo ""
echo "3. Instala un emulador o conecta un dispositivo"
echo "   Tools > AVD Manager"
echo ""
echo "4. Ejecuta la app"
echo "   Run > Run 'app'"
echo ""
echo "📚 Documentación:"
echo "   - README.md - Guía principal"
echo "   - TUTORIALS.md - Tutoriales paso a paso"
echo "   - CONTRIBUTING.md - Cómo contribuir"
echo ""
echo "🚀 Próximos pasos recomendados:"
echo "   - Explorar los ejemplos básicos"
echo "   - Leer los tutoriales"
echo "   - Crear tu primera feature"
echo ""
echo "❓ Preguntas o problemas?"
echo "   - Revisa la sección Troubleshooting en README.md"
echo "   - Consulta la documentación oficial de Android"
echo ""
echo "═══════════════════════════════════════════════"
