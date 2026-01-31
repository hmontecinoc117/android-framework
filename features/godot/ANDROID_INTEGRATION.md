# Integración Godot ↔ Android (GustaNuno Gaming)

Este documento explica cómo configurar Godot 4.5.1.stable.official para integración con Android Studio y cómo usar las escenas generadas en `features/godot/assets/`.

---

## 📋 Configuración de Godot 4.5.1.stable.official

### Paso 1: Descargar e Instalar Godot

1. **Descargar Godot 4.5.1**
   ```bash
   # Opción A: Descarga manual desde la web oficial
   # Visita: https://godotengine.org/download/archive/4.5.1-stable/
   # Descarga: Godot_v4.5.1-stable_linux.x86_64.zip (para Linux)
   
   # Opción B: Usando wget
   cd ~/Downloads
   wget https://github.com/godotengine/godot/releases/download/4.5.1-stable/Godot_v4.5.1-stable_linux.x86_64.zip
   unzip Godot_v4.5.1-stable_linux.x86_64.zip
   ```

2. **Instalar en el sistema**
   ```bash
   # Crear directorio para Godot
   sudo mkdir -p /opt/godot
   sudo mv Godot_v4.5.1-stable_linux.x86_64 /opt/godot/godot
   sudo chmod +x /opt/godot/godot
   
   # Crear enlace simbólico (opcional)
   sudo ln -s /opt/godot/godot /usr/local/bin/godot
   
   # Verificar instalación
   godot --version
   ```

### Paso 2: Descargar Plantillas de Exportación para Android

1. **Descargar Android Export Templates**
   ```bash
   cd ~/Downloads
   wget https://github.com/godotengine/godot/releases/download/4.5.1-stable/Godot_v4.5.1-stable_export_templates.tpz
   ```

2. **Instalar plantillas**
   ```bash
   # Crear directorio de plantillas
   mkdir -p ~/.local/share/godot/export_templates/4.5.1.stable
   
   # Extraer plantillas
   unzip Godot_v4.5.1-stable_export_templates.tpz -d ~/.local/share/godot/export_templates/
   mv ~/.local/share/godot/export_templates/templates/* ~/.local/share/godot/export_templates/4.5.1.stable/
   ```

### Paso 3: Configurar Android SDK y NDK

1. **Abrir Godot Editor**
   ```bash
   godot
   ```

2. **Configurar rutas de Android**
   - Ve a `Editor → Editor Settings`
   - Navega a `Export → Android`
   - Configura las siguientes rutas:

   ```
   Android SDK Path: /home/xtotox/Android/Sdk
   Debug Keystore: /home/xtotox/.android/debug.keystore
   ```

3. **Instalar Android Build Tools desde Godot**
   - En la misma ventana de configuración
   - Click en "Install Android Build Template"
   - Esto descargará automáticamente:
     - Android SDK Command-line Tools
     - Android SDK Build-Tools
     - Android SDK Platform-Tools
     - Android NDK (versión compatible)

### Paso 4: Abrir el Proyecto Godot

1. **Abrir proyecto existente**
   ```bash
   cd /home/xtotox/Documentos/android-framework/features/godot
   godot project.godot
   ```

2. **O desde el Project Manager de Godot**
   - Abre Godot
   - Click en "Import"
   - Navega a `/home/xtotox/Documentos/android-framework/features/godot`
   - Selecciona `project.godot`
   - Click "Import & Edit"

### Paso 5: Instalar Android Build Template en el Proyecto

1. **Desde el editor del proyecto Godot**
   - Ve a `Project → Install Android Build Template`
   - Esto creará la carpeta `android/` en tu proyecto
   - Estructura generada:
     ```
     features/godot/
     └── android/
         ├── build/
         ├── plugins/
         └── AndroidManifest.xml
     ```

### Paso 6: Configurar Export Preset para Android

1. **Abrir configuración de exportación**
   - `Project → Export...`
   - Click en "Add..." y selecciona "Android"

2. **Configurar opciones básicas**
   ```
   Export Path: ../build/godot-game.apk (o .aab)
   
   Options:
   ├── Custom Build:
   │   └── Use Custom Build: ✓ (activado)
   ├── Architectures:
   │   ├── armeabi-v7a: ✓
   │   ├── arm64-v8a: ✓
   │   ├── x86: ✓
   │   └── x86_64: ✓
   ├── Permissions:
   │   └── (Según necesites: INTERNET, WRITE_EXTERNAL_STORAGE, etc.)
   └── Package:
       ├── Unique Name: com.framework.features.godot
       ├── Name: GodotIntegration
       └── Signed: ✓
   ```

3. **Guardar la configuración**
   - Click en "Close"
   - El archivo `export_presets.cfg` se actualizará automáticamente

### Paso 7: Generar AAR para Android Studio

1. **Exportar como AAR personalizado**
   - En `Project → Export...`
   - Selecciona el preset "Android"
   - Click en "Export Project"
   - En el diálogo:
     - Selecciona "Export as AAR Library": ✓
     - Ruta: `/home/xtotox/Documentos/android-framework/features/godot/build/godot-lib.aar`
   - Click "Save"

2. **Copiar AAR al proyecto Android**
   ```bash
   cd /home/xtotox/Documentos/android-framework
   mkdir -p app/libs
   cp features/godot/build/godot-lib.aar app/libs/
   ```

### Paso 8: Integrar AAR en Android Studio

1. **Modificar `app/build.gradle.kts`**
   
   Añade el repositorio flatDir y la dependencia:
   ```kotlin
   repositories {
       flatDir {
           dirs("libs")
       }
   }
   
   dependencies {
       implementation(files("libs/godot-lib.aar"))
       // O alternativamente:
       // implementation(name = "godot-lib", ext = "aar")
   }
   ```

2. **Sincronizar proyecto**
   ```bash
   cd /home/xtotox/Documentos/android-framework
   ./gradlew build
   ```

### Paso 9: Configurar GodotActivity en Android

1. **Añadir GodotActivity al Manifest**
   
   En `app/src/main/AndroidManifest.xml`:
   ```xml
   <activity
       android:name="org.godotengine.godot.GodotActivity"
       android:theme="@style/GodotAppMainTheme"
       android:exported="false">
   </activity>
   ```

2. **Lanzar escena desde Kotlin**
   ```kotlin
   import android.content.Intent
   import org.godotengine.godot.GodotActivity
   
   fun launchGodotScene(context: Context, scenePath: String) {
       val intent = Intent(context, GodotActivity::class.java)
       intent.putExtra("--main-scene", scenePath)
       context.startActivity(intent)
   }
   
   // Uso:
   launchGodotScene(this, "res://assets/scenes/menu.tscn")
   ```

### Paso 10: Verificar la Integración

1. **Compilar y ejecutar**
   ```bash
   ./gradlew installDebug
   ```

2. **Verificar en logcat**
   ```bash
   adb logcat | grep -i godot
   ```

3. **Probar escenas**
   - Navega a la actividad que lanza Godot
   - Verifica que las escenas cargan correctamente

---

## 🔧 Solución de Problemas Comunes

### Error: "Export templates not found"
```bash
# Verificar instalación de plantillas
ls -la ~/.local/share/godot/export_templates/4.5.1.stable/
# Debe contener: android_debug.apk, android_release.apk, etc.
```

### Error: "Android SDK not configured"
1. Abre Android Studio
2. Ve a `File → Project Structure → SDK Location`
3. Copia la ruta del Android SDK
4. Pégala en Godot: `Editor → Editor Settings → Export → Android`

### Error: "Unable to find GodotActivity"
- Verifica que el AAR esté en `app/libs/`
- Sincroniza Gradle: `./gradlew build --refresh-dependencies`
- Limpia y reconstruye: `./gradlew clean build`

---

## 1) Flujo recomendado

- Diseña y prueba escenas en Godot Editor localmente.
- Exporta tu proyecto Godot para Android como AAR usando Custom Build.
- Copia el AAR a `app/libs/` en tu proyecto Android.
- Desde Android, lanza la `GodotActivity` pasándole la escena inicial (`main_scene` / `menu.tscn`).

## 2) Exportar Godot como biblioteca (AAR) — Método actualizado para 4.5.1

### Opción A: Usando Custom Build (Recomendado)

1. **Instalar Android Build Template**
   - `Project → Install Android Build Template`
   - Esto crea la carpeta `android/` en el proyecto

2. **Configurar Export Preset**
   - `Project → Export...`
   - Add → "Android"
   - Activar `Custom Build → Use Custom Build`
   - Configurar Package Name: `com.framework.features.godot`

3. **Exportar AAR**
   - En Export dialog, marca "Export as AAR Library"
   - Exporta a `build/godot-lib.aar`

4. **Integrar en Android Studio**
   ```bash
   cp build/godot-lib.aar ../../app/libs/
   ```

   Añade en `app/build.gradle.kts`:
   ```kotlin
   repositories {
       flatDir {
           dirs("libs")
       }
   }
   
   dependencies {
       implementation(files("libs/godot-lib.aar"))
   }
   ```

### Opción B: Usando Plugin/Módulo Gradle (Avanzado)

1. Crea un módulo Android en tu proyecto que incluya el AAR de Godot
2. Configura el módulo como dependencia en tu app
3. Usa `GodotFragment` en lugar de `GodotActivity` para más control


## 3) Manifest y Activity

La plantilla de Godot normalmente provee una `GodotActivity` (ej. `org.godotengine.godot.GodotActivity`). Si la incluyes, asegúrate de que el `AndroidManifest.xml` del AAR o tu `app` incluya la activity. Para lanzar una escena específica desde Android puedes usar un Intent con extras:

```kotlin
val manager = GodotViewManager(context)
manager.startGodotActivity("res://assets/scenes/menu.tscn")
```

Nota: la clave extra (`main_scene`) puede variar según la integración; revisa la plantilla Godot que uses.

## 4) Uso de las escenas incluidas

- `features/godot/assets/scenes/menu.tscn` — menú principal con botones para los juegos.
- `features/godot/assets/scenes/trace_words.tscn` — juego de trazado de palabras (usa `assets/data/animals.json`).
- `features/godot/assets/scenes/trace_shapes.tscn` — trazado de figuras.
- `features/godot/assets/scenes/puzzle.tscn` — rompecabezas; asigna `source_image` en el inspector.
- `features/godot/assets/scenes/memory.tscn` — memorice; asigna `card_textures` en el inspector.

### Añadir/editar animales

Edita `features/godot/assets/data/animals.json` para agregar o quitar animales. El formato es:

```json
{
  "animals": ["perro","gato","pajaro", ... ]
}
```

Al ejecutar, `trace_words.gd` cargará ese archivo automáticamente.

### Añadir nuevos diseños (trazado de formas)

Edita el array `shapes` en `trace_shapes.gd` o añade nuevos archivos de referencia y actualiza `_pick_shape()` para incluir diseños personalizados. Para diseños complejos (auto, tren, avión) puedes:

- Añadir una imagen de guía en `assets/images/` y mostrarla detrás del `DrawArea`.
- O guardar vectores/paths en archivos `.json` y presentarlos como guía.

## 5) Cómo asignar recursos en Godot Editor

- Abre `menu.tscn` o la escena correspondiente en Godot Editor.
- Para el `puzzle.tscn`, selecciona el nodo `Puzzle` y asigna la `source_image` (inspector).
- Para el `memory.tscn`, selecciona `Memory` y en `card_textures` agrega las texturas.

## 6) Extensibilidad y buenas prácticas

- Mantén los datos (lista de animales, paths de diseños) en `assets/data/` para facilitar edición desde el proyecto Android o CI.
- Si vas a añadir muchas escenas, organiza `assets/scenes/<categoria>/`.
- Para producción en Android, optimiza imágenes y activa compresión en export.

## 7) Debug rápido en Android

- Instala el APK exportado por Godot en tu dispositivo para verificar la integración.
- Si la `GodotActivity` no inicia desde Android, revisa el logcat para ver errores de resolución de clase o manifest.

---

Si quieres, puedo ahora:
- Actualizar `app/MainActivity.kt` para añadir un botón que lance el menú Godot (hecho a continuación si lo deseas),
- O generar assets PNG reales (íconos y guías) en `features/godot/assets/images/`.

## 8) Proyecto mínimo y generación de assets

Ruta del workspace actual: `/home/xtotox/Documentos/android-framework`.

1. Generar assets base (requiere Python3 + Pillow):

```bash
cd /home/xtotox/Documentos/android-framework
python3 features/godot/tools/generate_assets.py
```

2. Abrir proyecto mínimo en Godot:
- Abre Godot Editor y selecciona la carpeta: `/home/xtotox/Documentos/android-framework/features/godot`
- El archivo de proyecto es `features/godot/project.godot` y la escena principal `res://assets/scenes/menu.tscn`.

3. Ajustar escenas en el editor:
- Asigna `source_image` en `puzzle.tscn`.
- Asigna `card_textures` en `memory.tscn`.
- Verifica que las rutas `res://assets/...` carguen correctamente.

## 9) Preparar Android SDK en Ubuntu (script incluido)

Puedes instalar y configurar las herramientas necesarias con el script:

```bash
cd /home/xtotox/Documentos/android-framework
bash features/godot/tools/setup_android_sdk.sh
```

Después, añade a tu `~/.bashrc` las variables que el script imprime (o copia/pega tal cual). En Godot Editor, abre `Editor Settings → Export → Android` y apunta a:
- Android SDK Path: `~/Android/Sdk`
- ADB: `~/Android/Sdk/platform-tools/adb`
- apksigner: `~/Android/Sdk/build-tools/35.0.0/apksigner`

En `Project Settings → Rendering → Textures` establece compresión por defecto en `ETC2/ASTC` si Godot lo solicita para Android.

## 10) Exportar como módulo Android e integrarlo

En Godot:
- `Project → Install Android Build Template` y luego `Project → Export → Android`.
- Habilita “Use Custom Build” y exporta a: `/home/xtotox/Documentos/android-framework/features/godot/android`.

En Gradle (Android):

- `settings.gradle.kts` añade (cuando el folder exista):

```kotlin
include(":features:godot:android")
project(":features:godot:android").projectDir = file("features/godot/android")
```

- `app/build.gradle.kts` añade:

```kotlin
dependencies {
    implementation(project(":features:godot:android"))
}
```

Luego, desde `MainActivity` puedes lanzar la actividad principal de Godot usando el helper de `GodotIntegration.kt` o llamando directamente a la clase de Activity que exporte Godot.

## 11) Solución de errores comunes (Android Export)

### Error: C#/.NET experimental en Android
Si ves "Exportar a Android al usar C#/.NET es experimental", significa que estás usando el editor de Godot .NET o que el proyecto está marcado para .NET.

- Recomendado: usa el editor estándar (no-Mono) de Godot 4.x y GDScript para Android.
- Si necesitas .NET: instala Godot .NET 4.x, el SDK de .NET y sigue la guía oficial para exportar a Android con .NET.

### Error: Almacén de claves de depuración no configurado
Debes configurar todas las credenciales (ruta, alias, password) o desactivar la opción de depuración.

- Opción rápida: desactiva el keystore de depuración en el preset (checkbox "Debug Keystore").
- Opción completa: crear/debug keystore por defecto y configurarlo:

```bash
# Crear keystore de depuración por defecto
keytool -genkey -v \
    -keystore "$HOME/.android/debug.keystore" \
    -storepass android \
    -alias androiddebugkey \
    -keypass android \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=Android Debug,O=Android,C=US"
```

# En Godot → Export → Android (o Editor Settings → Export → Android)
# Keystore: $HOME/.android/debug.keystore
# Alias: androiddebugkey
# Store password: android
# Key password: android

### Error: Ruta no válida para el SDK de Java (JDK)
Godot requiere que el JDK apunte a un directorio que contenga `bin`.

```bash
# Detectar JAVA_HOME automáticamente
JAVA_BIN=$(command -v java)
JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$JAVA_BIN")")")
echo "JAVA_HOME=$JAVA_HOME" && ls "$JAVA_HOME/bin"
```
Usa ese `JAVA_HOME` en Godot → Editor Settings → Export → Android → JDK Path.
En Ubuntu suele ser `/usr/lib/jvm/java-17-openjdk-amd64`.

### apksigner/SDK Android no encontrado
Asegura que el SDK tenga build-tools y que el PATH incluya las herramientas.

```bash
# Instalar herramientas con sdkmanager
bash features/godot/tools/setup_android_sdk.sh

# O manualmente
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
yes | sdkmanager --licenses
sdkmanager "platform-tools" "build-tools;35.0.0" "platforms;android-35"

# Verificar apksigner
ls "$ANDROID_SDK_ROOT/build-tools/35.0.0/apksigner" && "$ANDROID_SDK_ROOT/build-tools/35.0.0/apksigner" -version
```

### adb: no devices/emulators found
Conecta un dispositivo físico con Depuración USB o inicia un emulador.

```bash
# Dispositivo físico
adb devices  # Acepta el prompt de autorización en el teléfono

# Instalar el APK y lanzar actividad
adb install -r app/build/outputs/apk/debug/Juegos_GustaNuno.apk
adb shell am start -n com.framework/.MainActivity
```

Para emulador, instala imágenes de sistema y crea un AVD con Android Studio o `avdmanager`.
