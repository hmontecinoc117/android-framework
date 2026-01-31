# Prompts para benchmarking y generación de UI en Godot

## 1) Benchmark de diseño
Quiero construir la UI de un juego de memoria para Android, orientado a niños de 3 años. Analiza 3–5 juegos/apps similares y extrae:
# Prompts de Benchmarking y Generación de UI (Godot 4)

## 1) Benchmark de diseño
Quiero construir la UI de un juego para niños de 3 años en Android (género: memorice/hypercasual educativo). Analiza 3–5 juegos/apps similares y extrae:
- Paleta de colores (primarios, secundarios, fondo, texto, estados).
- Tipografías (estilo, peso, tamaños).
- Componentes clave (botones, paneles, tarjetas, HUD, modales).
- Patrones de navegación (menú principal, ajustes, pausa, onboarding).
- Microinteracciones (hover, pressed, focus, transiciones, feedback).

Usa como referencia visual: estilo infantil, vibrante, iconografía simple, tamaños táctiles > 64px, contraste mínimo AA. Incluye fuentes seguras para Android y tiempos de animación entre 120–350ms.

## 2) Tokens del sistema de diseño
Genera tokens en JSON con esta estructura y valores compatibles con accesibilidad infantil:
```json
{
	"colors": {
		"primary": "#1A78F4",
		"secondary": "#F4A623",
		"background": "#FAFCFF",
		"surface": "#FFFFFF",
		"text": "#1F1F1F",
		"text_on_primary": "#FFFFFF",
		"success": "#33B566",
		"warning": "#F6C344",
		"error": "#E24153"
	},
	"radii": {"sm": 8, "md": 16, "lg": 24},
	"spacing": {"xs": 8, "sm": 12, "md": 16, "lg": 24, "xl": 32},
	"sizes": {"touch_min": 64, "button_height": 72, "panel_padding": 20},
	"motion": {"duration_short": 0.12, "duration_medium": 0.20, "duration_long": 0.35}
}
```

## 3) Theme y componentes en Godot 4
Con los tokens anteriores, genera:
- Código `GDScript` para construir un `Theme` global (Button, Panel, Label, Slider, Checkbox).
- Escenas `TSCN` de componentes base (botón primario, panel, tarjeta con imagen, header, HUD básico).
- Acompaña cada componente con estados: normal, hover, pressed, disabled.

## 4) Plantillas de pantallas
Propón escenas para:
- Menú principal (grid de juegos, botón ajustes, perfil).
- HUD de juego (score, tiempo, botón pausa).
- Pantalla de pausa (continuar, reiniciar, ajustes).
- Ajustes (volumen, idioma, tamaño de fuente global).

Usa `VBoxContainer/HBoxContainer/GridContainer/MarginContainer` y `size_flags` para responsividad.

## 5) Criterios de aceptación
- Contraste mínimo AA en texto/elementos críticos.
- Táctiles >= 64px de alto/ancho.
- Navegación por teclado/control con foco visible.
- Animaciones sutiles: 120–350ms, no intrusivas.
- Internacionalización preparada (es/en) y tipografía legible para niños.

## 6) Prompt para refinamiento iterativo
- "Refina la paleta para mayor contraste AA en botones primarios."
- "Reduce el espaciado en móviles pequeños, manteniendo táctiles seguros."
- "Añade feedback auditivo opcional en acciones clave."
- "Genera una versión monocromática para modo alto contraste."

## 7) Cómo aplicar en el proyecto
- Autoloads: `UiGlobals` y `UiBootstrap` activos en `project.godot`.
- Scene `StyleGuide.tscn` para visualizar componentes y validar tokens.
- Ajusta tokens en `ui/autoload/ui_globals.gd` y reconstruye el Theme en `_ready()`.

## 8) Exportación Android (opcional)
Instala build-tools si exportas APK:
```
sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
```

Proporciona como salida:
- Recomendaciones de accesibilidad (contraste AA mínimo, tamaños táctiles ≥ 64 px).

- Escenas TSCN de componentes: `StandardButton.tscn`, `PanelCard.tscn`, `HudBar.tscn`.
- Escalado de fuente global y `custom_minimum_size` ≥ 64 px.
- Navegación por teclado/touch con estados `focus` visibles.

## 4) Criterios de aceptación
- Contraste AA/AAA según WCAG para texto principal.
- Interacciones consistentes (hover/pressed/focus) con feedback claro.
- Rendimiento estable en OpenGL 3 (Godot 4) y móviles Android.
- Scene `StyleGuide.tscn` compila y refleja cambios de tokens en tiempo real.

## 5) Prompt ejemplo
Analiza estas referencias (memoria infantil) y sintetiza patrones visuales:
- https://www.freepik.es/fotos-vectores-gratis/juego-memorice

Concluye con tokens JSON y una propuesta de layouts para: Menú Principal, Selector de Juego, Pantalla de Juego, Pantalla de Pausa y Ajustes.
