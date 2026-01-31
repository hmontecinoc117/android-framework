#!/usr/bin/env bash
set -euo pipefail

# Directorios
SDK_ROOT="$HOME/Android/Sdk"
CMD_TOOLS_ZIP="commandlinetools-linux-latest.zip"
CMD_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

mkdir -p "$SDK_ROOT/cmdline-tools"
cd "$SDK_ROOT"

if [[ ! -d "$SDK_ROOT/cmdline-tools/latest" ]]; then
  echo "Descargando Android Commandline Tools..."
  curl -L "$CMD_TOOLS_URL" -o "$CMD_TOOLS_ZIP"
  unzip -q "$CMD_TOOLS_ZIP" -d cmdline-tools
  mv cmdline-tools/cmdline-tools cmdline-tools/latest
  rm -f "$CMD_TOOLS_ZIP"
fi

export ANDROID_SDK_ROOT="$SDK_ROOT"
export PATH="$SDK_ROOT/cmdline-tools/latest/bin:$SDK_ROOT/platform-tools:$PATH"

yes | sdkmanager --licenses
sdkmanager "platform-tools" "build-tools;35.0.0" "platforms;android-35"

# Actualizar herramientas a la última versión disponible para evitar warnings de XML/versiones
sdkmanager --update || true

cat <<EOF

Variables para tu shell (~/.bashrc o ~/.zshrc):
export ANDROID_SDK_ROOT="$SDK_ROOT"
export ANDROID_HOME="$SDK_ROOT"
export PATH="$SDK_ROOT/cmdline-tools/latest/bin:$SDK_ROOT/platform-tools:\$PATH"

Rutas para Godot Editor → Editor Settings → Export → Android:
- Android SDK Path: $SDK_ROOT
- ADB: $SDK_ROOT/platform-tools/adb
- apksigner: $SDK_ROOT/build-tools/35.0.0/apksigner
EOF
