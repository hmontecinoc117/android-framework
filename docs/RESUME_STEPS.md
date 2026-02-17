# Retomar configuración: Android + Godot + GitHub (31-01-2026)

## Estado actual
- Repo Git: inicializado en rama `main` (primer commit hecho).
- Remoto GitHub: pendiente de crear y hacer `push`.
- Godot UI: autoloads añadidos y `Theme` global listo.
- Launcher: `run_godot.sh` fuerza OpenGL 3 por defecto.
- Prompts: guía en `docs/prompts.md` para benchmarking y generación de UI.

## Próximo objetivo (obligatorio)
Crear remoto en GitHub y subir `main`.

### Opción rápida: script automatizado
Ejecuta el script que prepara todo con `gh` o con `GH_TOKEN` (fallback):
```bash
chmod +x scripts/publish_to_github.sh
# Público
scripts/publish_to_github.sh --visibility public
# Privado
scripts/publish_to_github.sh --visibility private
```
Opciones:
- `--repo-name android-framework` para forzar nombre.
- `--org <tu-org>` para crear en una organización.
- `--dry-run` para ver las acciones sin ejecutarlas.

### Opción A: con GitHub CLI (recomendado)
1. Autenticar:
   ```bash
   gh auth login --hostname github.com --web
   ```
2. Crear y subir el repo (público):
   ```bash
   gh repo create android-framework --source=. --public --remote=origin --push
   ```
   - Para repo privado, cambia `--public` por `--private`.

### Opción B: sin GH CLI (API + token)
1. Crea un PAT con scope `repo`: https://github.com/settings/tokens
2. Exporta variables (ajusta usuario y token):
   ```bash
   export GH_USER="<tu-usuario>"
   export GH_TOKEN="<tu-token>"
   ```
3. Crea el repositorio y añade remoto:
   ```bash
   curl -H "Authorization: token $GH_TOKEN" \
        -H "Accept: application/vnd.github+json" \
        https://api.github.com/user/repos \
        -d '{"name":"android-framework","private":false,"description":"Android + Godot framework"}'

   git remote add origin https://github.com/$GH_USER/android-framework.git
   git push -u origin main
   ```

### Verificación rápida
```bash
git remote -v
git log --oneline -n 3
```

## Godot: arranque estable
- Abrir el editor con OpenGL 3:
  ```bash
  bash features/godot/run_godot.sh -e --rendering-driver opengl3
  ```

## Exportación Android (opcional)
Instala y configura Android SDK si vas a exportar APK.
```bash
sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
```

## Notas sobre Godot (warnings vistos)
- `xkbcommon` (keysym "dead_hamza"): aviso del snap, no bloquea.
- GLES3 MSAA 2D: warning, no afecta edición.
- Si aparece conflicto de nombres en autoloads:
  - Alternativa: renombrar autoloads a `UiGlobalsSingleton` y `UiBootstrapSingleton` en `features/godot/project.godot` y referenciarlos así.
  - O bien, quitar `class_name` de los scripts autoload.

## Archivos relevantes
- `features/godot/run_godot.sh`: launcher con OpenGL por defecto.
- `features/godot/project.godot`: autoloads del UI.
- `features/godot/ui/autoload/ui_globals.gd`: tokens de UI.
- `features/godot/ui/autoload/ui_bootstrap.gd`: aplica `Theme` global.
- `features/godot/ui/theme_builder.gd`: construcción de `Theme`.
- `features/godot/ui/StyleGuide.tscn`: muestra componentes base.
- `docs/prompts.md`: guía de prompts de diseño.
