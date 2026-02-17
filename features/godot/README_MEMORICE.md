# Guía de Diseño y Configuración — Memorice (MemoryGame)

Esta guía detalla cómo aplicar el diseño infantil del juego de memorice en Godot 4.5, alineado con la especificación y los tokens disponibles.

## Componentes Clave

- **UiGlobals (autoload):** Fuente de tokens de diseño (colores, espaciado, radios, elevación, tamaños mínimos). Ver [ui/autoload/ui_globals.gd](features/godot/ui/autoload/ui_globals.gd).
- **ThemeBuilder:** Construye `Theme` global usando `UiGlobals`. Incluye variación `Tile` para tarjetas. Ver [ui/theme_builder.gd](features/godot/ui/theme_builder.gd).
- **MemoryGame:** Lógica y layout del juego. Ver [scripts/games/MemoryGame.gd](features/godot/scripts/games/MemoryGame.gd) y escena [scenes/games/MemoryGame.tscn](features/godot/scenes/games/MemoryGame.tscn).

## Tokens de Diseño

- **Colores:** `primary`, `primary_hover`, `primary_pressed`, `text`, `text_muted`, `success`, `danger`.
- **Tarjetas:** `tile_hidden`, `tile_hidden_border`, `tile_revealed`, `tile_match`.
- **Espaciado:** `xs|sm|md|lg|xl` (6, 10, 14, 20, 28).
- **Radios:** `sm|md|lg` (12, 16, 24).
- **Elevación:** `none|sm|md|lg` (0, 2, 4, 8).
- **Accesibilidad:** `touch_target_min = 180`, `font_scale`, `contrast_mode`.

Los tokens se definen en `UiGlobals` y están alineados con [design_tokens.json](features/godot/design_tokens.json).

## Aplicación del Tema

- `UiBootstrap` aplica el tema global en arranque y reconstruye al cambiar accesibilidad.
- La variación `Tile` se usa con `Button.theme_type_variation = "Tile"` para tarjetas (si usas `MemoryTile`).
- `ThemeManager` puede aplicar paletas temáticas por escena si se requiere.

## Diseño de Cartas (MemoryGame)

- **Tamaño:** Calculado según viewport y `grid_size`, con clamp a 180–320 px.
- **Dorso:** Azul primario (`GameManager.COLOR_PRIMARY_BLUE`) con ícono `?` grande.
- **Frente:** Blanco con borde dorado (radio 24, grosor 6–8).
- **Animación de flip:** Escala en X con flash sutil.
- **Match:** Fade-out suave + confeti; feedback de voz y audio.

## Barra Superior (TopBar)

- **Botón Atrás:** Grande (≈220×140), con texturas si existen.
- **Intentos:** Etiqueta `AttemptsLabel` (oculta para ≤3 años).
- **Timer Visual:** `TimerBar` (`ProgressBar`) que avanza hasta 180s, sin porcentaje.

## Dificultad y Adaptación

- Para perfiles de ≤3 años: `grid_size = 2x2`, ocultar números de timer y contadores.
- Separación del grid: 24 px horizontal/vertical.
- Área táctil ampliada con zonas de interacción.

## Cómo Ejecutar

```bash
# Abrir el proyecto
godot4 --path features/godot --editor

# Ejecutar MemoryGame
godot4 --path features/godot --profile scenes/games/MemoryGame.tscn
```

## Exportar a Android

```bash
godot4 --path features/godot --export-release "Android" builds/KidsGames.apk
adb install -r builds/KidsGames.apk
```

## Notas

- Si deseas usar `MemoryTile` (Button + theme "Tile"), asegúrate de que `UiGlobals` define `tile_*` y que `ThemeBuilder` se aplica antes de crear las tarjetas.
- Para fondos con gradiente/animación y elementos decorativos, añade nodos `ShaderMaterial` o partículas según el spec, manteniendo rendimiento en móviles.
