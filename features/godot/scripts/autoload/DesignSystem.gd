## Design System — Constantes compartidas para UI consistente.
## Paleta infantil optimizada para contraste AA, niños 3 años.

extends Node

# ──────────────────────────────────────────────
#  Colores Estandarizados
# ──────────────────────────────────────────────

const COLORS := {
	"primary":          Color("#FF6B35"),  # Naranja vibrante — botones principales
	"primary_hover":    Color("#FF8C5A"),
	"primary_pressed":  Color("#E55A24"),
	"secondary":        Color("#4ECDC4"),  # Turquesa — acentos
	"success":          Color("#44CF6C"),  # Verde celebración
	"warning":          Color("#FFD93D"),  # Amarillo alerta
	"error":            Color("#FF6B6B"),  # Rojo suave
	"background":       Color("#FFF8F0"),  # Crema cálida — fondo principal
	"background_dark":  Color("#FFE8D6"),  # Crema más oscura — superficies
	"surface":          Color("#FFFFFF"),  # Blanco puro — cartas
	"card_back":        Color("#A8DAFF"),  # Azul cielo — dorso de cartas
	"card_back_border": Color("#5BA8D9"),
	"text":             Color("#2D2D2D"),  # Casi negro — texto principal
	"text_light":       Color("#7A7A7A"),  # Gris — texto secundario
	"star_gold":        Color("#FFD700"),
}

# ──────────────────────────────────────────────
#  Tamaños de Botones (mínimos táctiles Android)
# ──────────────────────────────────────────────

const BTN_SMALL       := Vector2(100, 100)
const BTN_MEDIUM      := Vector2(150, 150)
const BTN_LARGE       := Vector2(200, 200)
const BTN_EXTRA_LARGE := Vector2(280, 280)

# ──────────────────────────────────────────────
#  Tamaños de Fuente (base sin escalar)
# ──────────────────────────────────────────────

const FONT_TINY   := 24
const FONT_SMALL  := 32
const FONT_MEDIUM := 48
const FONT_LARGE  := 64
const FONT_XLARGE := 80
const FONT_TITLE  := 96
const FONT_HUGE   := 128

# Tamaños semánticos para Fredoka One (base)
const FONT_HEADING    := 72   # Títulos de juego
const FONT_SUBHEADING := 52   # Subtítulos
const FONT_BODY       := 40   # Texto general
const FONT_BUTTON     := 44   # Texto en botones
const FONT_HUD        := 36   # HUD / TopBar

# ──────────────────────────────────────────────
#  Espaciado y Padding
# ──────────────────────────────────────────────

const SPACING_TINY   := 6
const SPACING_SMALL  := 10
const SPACING_MEDIUM := 14
const SPACING_LARGE  := 20
const SPACING_XLARGE := 28
const SPACING_HUGE   := 40

const PADDING_SMALL  := 12
const PADDING_MEDIUM := 20
const PADDING_LARGE  := 32

# ──────────────────────────────────────────────
#  Radios de Bordes
# ──────────────────────────────────────────────

const RADIUS_SMALL  := 12
const RADIUS_MEDIUM := 16
const RADIUS_LARGE  := 24
const RADIUS_XLARGE := 32
const RADIUS_BUTTON := 28   # Radio específico para botones principales

# ──────────────────────────────────────────────
#  Elevación (Sombras)
# ──────────────────────────────────────────────

const SHADOW_NONE   := 0
const SHADOW_SMALL  := 2
const SHADOW_MEDIUM := 4
const SHADOW_LARGE  := 8
const SHADOW_XLARGE := 12

# ──────────────────────────────────────────────
#  Animaciones (Duraciones) — máx 0.35s para niños
# ──────────────────────────────────────────────

const ANIM_INSTANT   := 0.0
const ANIM_FAST      := 0.12
const ANIM_NORMAL    := 0.20
const ANIM_MEDIUM    := 0.25
const ANIM_SLOW      := 0.35

# ──────────────────────────────────────────────
#  Colores de juego únicos (para grid de menú)
# ──────────────────────────────────────────────

const GAME_COLORS := [
	Color("#FF6B35"),  # Naranja
	Color("#4ECDC4"),  # Turquesa
	Color("#44CF6C"),  # Verde
	Color("#FFD93D"),  # Amarillo
	Color("#FF6B6B"),  # Rojo suave
	Color("#A8DAFF"),  # Azul cielo
	Color("#C77DFF"),  # Lavanda
	Color("#FFA07A"),  # Salmón
]

# ──────────────────────────────────────────────
#  Utilidades
# ──────────────────────────────────────────────

static func get_color(color_name: String) -> Color:
	return COLORS.get(color_name, Color.WHITE)


static func create_button_style(bg_color: Color) -> StyleBoxFlat:
	"""Crea StyleBoxFlat con efecto 3D: borde inferior grueso y sombra."""
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	# Esquinas redondeadas uniformes
	style.corner_radius_top_left    = RADIUS_BUTTON
	style.corner_radius_top_right   = RADIUS_BUTTON
	style.corner_radius_bottom_left = RADIUS_BUTTON
	style.corner_radius_bottom_right = RADIUS_BUTTON

	# Márgenes internos
	style.content_margin_left   = PADDING_MEDIUM
	style.content_margin_right  = PADDING_MEDIUM
	style.content_margin_top    = PADDING_SMALL
	style.content_margin_bottom = PADDING_SMALL

	# Borde inferior grueso → efecto 3D hacia abajo
	style.border_width_bottom = 5
	style.border_width_top    = 0
	style.border_width_left   = 0
	style.border_width_right  = 0
	style.border_color = bg_color.darkened(0.25)

	# Sombra
	style.shadow_color    = Color(0, 0, 0, 0.22)
	style.shadow_size     = 6
	style.shadow_offset   = Vector2(0, 3)

	return style


static func create_button_style_hover(bg_color: Color) -> StyleBoxFlat:
	"""Estado hover: fondo más claro, sombra más grande."""
	var style := create_button_style(bg_color.lightened(0.08))
	style.shadow_size = 8
	return style


static func create_button_style_pressed(bg_color: Color) -> StyleBoxFlat:
	"""Estado pressed: sombra eliminada, borde inferior delgado — efecto hundido."""
	var style := create_button_style(bg_color.darkened(0.08))
	style.shadow_size     = 0
	style.shadow_offset   = Vector2.ZERO
	style.border_width_bottom = 1
	return style


static func apply_button_style(button: Button, color_name: String = "primary") -> void:
	"""Aplica estilo 3D completo (normal/hover/pressed) a un botón."""
	var base_color := get_color(color_name)

	button.add_theme_stylebox_override("normal",   create_button_style(base_color))
	button.add_theme_stylebox_override("hover",    create_button_style_hover(base_color))
	button.add_theme_stylebox_override("pressed",  create_button_style_pressed(base_color))

	button.custom_minimum_size = Vector2(0, 88)
	button.add_theme_color_override("font_color",         Color.WHITE)
	button.add_theme_color_override("font_hover_color",   Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 0.9))
	button.focus_mode = Control.FOCUS_NONE


static func create_panel_style(bg_color: Color) -> StyleBoxFlat:
	"""Crea StyleBoxFlat para paneles."""
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left    = RADIUS_MEDIUM
	style.corner_radius_top_right   = RADIUS_MEDIUM
	style.corner_radius_bottom_left = RADIUS_MEDIUM
	style.corner_radius_bottom_right = RADIUS_MEDIUM
	style.shadow_color = Color(0, 0, 0, 0.15)
	style.shadow_size  = SHADOW_SMALL
	return style


static func setup_label(label: Label, font_size: int, color: Color = Color.WHITE) -> void:
	"""Configura un label con tamaño adaptativo y fuente Fredoka One."""
	var adaptive_size := ScreenSizeAdapter.get_adaptive_font_size(font_size)
	label.add_theme_font_size_override("font_size", adaptive_size)
	label.add_theme_color_override("font_color", color)
	var font_path := "res://assets/fonts/FredokaOne-Regular.ttf"
	if ResourceLoader.exists(font_path):
		label.add_theme_font_override("font", load(font_path))


static func bounce_animation(node: Node, scale_to: float = 1.2, duration: float = ANIM_FAST) -> void:
	"""Animación de rebote para feedback visual."""
	var tween := node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "scale", Vector2.ONE * scale_to, duration)
	tween.tween_property(node, "scale", Vector2.ONE, duration)


static func pulse_animation(node: Node, min_alpha: float = 0.5, max_alpha: float = 1.0, duration: float = ANIM_SLOW) -> void:
	"""Animación de pulso para elementos destacados."""
	var tween := node.create_tween()
	tween.set_loops()
	tween.tween_property(node, "modulate:a", min_alpha, duration)
	tween.tween_property(node, "modulate:a", max_alpha, duration)


static func shake_animation(node: Node, intensity: float = 10.0, duration: float = ANIM_FAST) -> void:
	"""Animación de sacudida para errores."""
	var original_pos: Vector2 = node.position
	var tween := node.create_tween()
	for i: int in 4:
		var offset := Vector2(randf_range(-intensity, intensity), 0.0)
		tween.tween_property(node, "position", original_pos + offset, duration / 8.0)
	tween.tween_property(node, "position", original_pos, duration / 8.0)
