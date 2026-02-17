# Unity en Linux: Instalación y Configuración para Android

Esta guía te instala Unity Hub, el Editor LTS, módulos de Android, y prepara el entorno para compilar y ejecutar en dispositivos Android. Incluye alternativas para mitigar congelamientos al arrancar.

## 1) Dependencias del sistema

Instala librerías necesarias y herramientas gráficas/Android. Elige tu gestor de paquetes:

Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y \
  libgtk-3-0 libnss3 libasound2 libxkbcommon0 libxi6 libxcursor1 \
  libxrandr2 libxinerama1 libglu1-mesa mesa-utils vulkan-tools \
  adb unzip wget tar ca-certificates
```

Fedora:

```bash
sudo dnf install -y \
  gtk3 nss alsa-lib xkbcommon libXi libXcursor libXrandr libXinerama \
  mesa-demos vulkan-tools android-tools wget tar ca-certificates
```

Arch:

```bash
sudo pacman -S --needed \
  gtk3 nss alsa-lib xkbcommon libxi libxcursor libxrandr libxinerama \
  mesa-demos vulkan-tools android-tools wget tar ca-certificates
```

Verifica GPU y soporte gráfico:

```bash
glxinfo | head -n 20 || echo "Instala mesa-utils"
vulkaninfo | head -n 40 || echo "Instala vulkan-tools"
```

## 2) Instalar Unity Hub (AppImage)

Descarga y arranca Unity Hub:

```bash
cd ~/Downloads
wget https://public-cdn.cloud.unity3d.com/hub/prod/UnityHub.AppImage -O UnityHub.AppImage
chmod +x UnityHub.AppImage
QT_QPA_PLATFORM=xcb ./UnityHub.AppImage --no-sandbox
```

Notas:
- Si usas Wayland, `QT_QPA_PLATFORM=xcb` fuerza UI estable (X11).
- `--no-sandbox` puede ser necesario en algunos entornos; si no arranca, prueba sin él.

Inicia sesión con tu cuenta y activa la licencia (Personal/Pro/Enterprise).

## 3) Instalar Editor LTS y módulos de Android

En Unity Hub → Install → Recommended LTS (2023/2024 LTS según disponibilidad).
Selecciona módulos:
- Android Build Support
  - OpenJDK
  - Android SDK & NDK Tools

Usar los módulos oficiales evita incompatibilidades de versiones (NDK/JDK/SDK).

## 4) Configurar External Tools

En Unity Editor → Edit → Preferences → External Tools:

- JDK: `~/Unity/Hub/Editor/<version>/Editor/Data/PlaybackEngines/AndroidPlayer/OpenJDK`
- SDK: `~/Unity/Hub/Editor/<version>/Editor/Data/PlaybackEngines/AndroidPlayer/SDK`
- NDK: `~/Unity/Hub/Editor/<version>/Editor/Data/PlaybackEngines/AndroidPlayer/NDK`
- `adb`: dentro del SDK (`platform-tools/adb`)

Marca “Gradle” integrado (por defecto). Evita apuntar a SDK/NDK externos salvo que tengas un motivo.

Comprueba `adb`:

```bash
adb version
adb devices
```

## 5) Reglas udev para Android (USB)

Permiten que `adb` detecte dispositivos sin root. Crea `/etc/udev/rules.d/51-android.rules` (requiere sudo):

```bash
sudo tee /etc/udev/rules.d/51-android.rules >/dev/null <<'RULES'
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev" # Google
SUBSYSTEM=="usb", ATTR{idVendor}=="2a70", MODE="0666", GROUP="plugdev" # OEM ejemplo
# Agrega más vendors según tu dispositivo
RULES
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Luego reconecta el dispositivo con “Depuración USB” habilitada:

```bash
adb kill-server && adb start-server
adb devices
```

## 6) Proyecto de prueba y Build & Run

1. Unity Hub → New Project → 3D (o URP) → Create.
2. File → Build Settings → Android → Switch Platform.
3. Player Settings: establece `Minimum API Level` acorde al objetivo (ej. 23+).
4. Con el dispositivo conectado, pulsa “Build and Run”.

Si compilas APK/AAB para firma, crea un keystore (Player Settings → Publishing Settings).

## 7) Mitigar congelamientos al arrancar

Prueba estos enfoques:

- Fuerza backend gráfico del Editor:

```bash
# Busca la ruta del binario del Editor
UNITY_EDITOR=~/Unity/Hub/Editor/<version>/Editor/Unity

"$UNITY_EDITOR" -logFile ~/unity_editor.log -force-vulkan
# o
"$UNITY_EDITOR" -logFile ~/unity_editor.log -force-glcore
```

- Ejecuta Hub con flags de estabilidad:

```bash
QT_QPA_PLATFORM=xcb ./UnityHub.AppImage --disable-gpu --no-sandbox 2>&1 | tee ~/unity_hub.log
```

- Inicia sesión Xorg (no Wayland) si tu GPU/driver tiene problemas con Wayland.
- Verifica drivers propietarios vs libres (NVIDIA: `nvidia-smi`; AMD/Intel: Mesa actualizada).

Si persiste el congelamiento, captura logs para diagnosticarlos:

```bash
journalctl -b0 | tail -n 200 > ~/journal_tail.log
sudo dmesg -wH | tee ~/dmesg_live.log
"$UNITY_EDITOR" -logFile ~/unity_editor.log -force-vulkan
```

Comparte `~/unity_editor.log`, `~/dmesg_live.log` y cualquier error del kernel/driver.

## 8) Notas Android específicas

- Instala paquete “Android Logcat” desde Package Manager para ver logs en tiempo real.
- Si Unity no detecta el SDK/NDK integrado, reinstala el módulo “Android Build Support”.
- API objetivo recomendada: Android 14 (API 34) o la que requiera tu app.

---

Mantenimiento:
- Mantén Unity LTS y módulos actualizados.
- Evita mezclar SDK/NDK externos salvo necesidad.
- Documenta rutas en tu equipo (`Preferences → External Tools`).
