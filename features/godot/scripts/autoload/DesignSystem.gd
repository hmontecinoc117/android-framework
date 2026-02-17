## Design System - Constantes compartidas para UI consistente
## Usar en todos los juegos para mantener coherencia visual

extends Node

# ──────────────────────────────────────────────
#  Colores Estandarizados
# ──────────────────────────────────────────────

const COLORS := {
	"primary": Color("#6D4AFF"),        # Púrpura vibrante
	"secondary": Color("#FFC83D"),      # Amarillo cálido
	"success": Color("#2ECC71"),        # Verde
	"error": Color("#E74C3C"),          # Rojo suave
	"warning": Color("#F39C12"),        # Naranja
	"background": Color("#F8F6FF"),     # Lavanda muy clara
	"background_dark": Color("#E8E4F8"),# Lavanda más oscura
	"text": Color("#3A2E5E"),           # Azul oscuro
	"text_light": Color("#8B7FB8"),     # Gris-púrpura
	"card_back": Color("#FFB6D9"),      # Rosa pastel
	"card_front": Color("#FFFFFF"),     # Blanco
	"guide": Color("#CCCCCC"),          # Gris claro
	"trace": Color("#3399FF"),          # Azul brillante
}

# ──────────────────────────────────────────────
#  Tamaños de Botones (mínimos táctiles)
# ──────────────────────────────────────────────

const BTN_SMALL := Vector2(100, 100)     # Botones secundarios
const BTN_MEDIUM := Vector2(150, 150)    # Botones principales
const BTN_LARGE := Vector2(200, 200)     # Botones de juego
const BTN_EXTRA_LARGE := Vector2(280, 280) # Botones destacados

# ──────────────────────────────────────────────
#  Tamaños de Fuente
# ──────────────────────────────────────────────

const FONT_TINY := 24
const FONT_SMALL := 32
const FONT_MEDIUM := 48
const FONT_LARGE := 64
const FONT_XLARGE := 80
const FONT_TITLE := 96
const FONT_HUGE := 128

# ──────────────────────────────────────────────
#  Espaciado y Padding
# ──────────────────────────────────────────────

const SPACING_TINY := 6
const SPACING_SMALL := 10
const SPACING_MEDIUM := 14
const SPACING_LARGE := 20
const SPACING_XLARGE := 28
const SPACING_HUGE := 40

const PADDING_SMALL := 12
const PADDING_MEDIUM := 20
const PADDING_LARGE := 32

# ──────────────────────────────────────────────
#  Radios de Bordes
# ──────────────────────────────────────────────

const RADIUS_SMALL := 12
const RADIUS_MEDIUM := 16
const RADIUS_LARGE := 24
const RADIUS_XLARGE := 32

# ──────────────────────────────────────────────
#  Elevación (Sombras)
# ──────────────────────────────────────────────

const SHADOW_NONE := 0
const SHADOW_SMALL := 2
const SHADOW_MEDIUM := 4
const SHADOW_LARGE := 8
const SHADOW_XLARGE := 12

# ──────────────────────────────────────────────
#  Animaciones (Duraciones)
# ──────────────────────────────────────────────

const ANIM_INSTANT := 0.0
const ANIM_FAST := 0.15
const ANIM_NORMAL := 0.25
const ANIM_SLOW := 0.4
const ANIM_VERY_SLOW := 0.6

# ──────────────────────────────────────────────
#  Utilidades
# ──────────────────────────────────────────────

static func get_color(color_name: String) -> Color:
	"""Obtiene un color del design system"""
	return COLORS.get(color_name, Color.WHITE)

static func create_button_style(bg_color: Color, hover_color: Color = Color.TRANSPARENT, pressed_color: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	"""Crea un StyleBoxFlat consistente para botones"""
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = RADIUS_LARGE
	style.corner_radius_top_right = RADIUS_LARGE
	style.corner_radius_bottom_left = RADIUS_LARGE
	style.corner_radius_bottom_right = RADIUS_LARGE
	style.content_margin_left = PADDING_MEDIUM
	style.content_margin_right = PADDING_MEDIUM
	style.content_margin_top = PADDING_SMALL
	style.content_margin_bottom = PADDING_SMALL
	style.shadow_color = Color(0, 0, 0, 0.2)
	style.shadow_size = SHADOW_MEDIUM
	return style

static func apply_button_style(button: Button, color_name: String = "primary") -> void:
	"""Aplica estilo consistente a un botón"""
	var base_color := get_color(color_name)
	var hover_color := base_color.lightened(0.1)
	var pressed_color := base_color.darkened(0.1)
	
	button.add_theme_stylebox_override("normal", create_button_style(base_color))
	button.add_theme_stylebox_override("hover", create_button_style(hover_color))
	button.add_theme_stylebox_override("pressed", create_button_style(pressed_color))
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 0.9))
	button.focus_mode = Control.FOCUS_NONE

static func create_panel_style(bg_color: Color) -> StyleBoxFlat:
	"""Crea un StyleBoxFlat para paneles"""
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = RADIUS_MEDIUM
	style.corner_radius_top_right = RADIUS_MEDIUM
	style.corner_radius_bottom_left = RADIUS_MEDIUM
	style.corner_radius_bottom_right = RADIUS_MEDIUM
	style.shadow_color = Color(0, 0, 0, 0.15)
	style.shadow_size = SHADOW_SMALL
	return style

static func setup_label(label: Label, font_size: int, color: Color = Color.WHITE, bold: bool = true) -> void:
	"""Configura un label con estilo consistente"""
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if bold and ResourceLoader.exists("res://assets/fonts/NotoSans-Bold.ttf"):
		label.add_theme_font_override("font", load("res://assets/fonts/NotoSans-Bold.ttf"))

static func create_progress_bar_style(fill_color: Color, bg_color: Color) -> void:
	"""Retorna estilos para barra de progreso"""
	pass  # Implementar si necesario

static func bounce_animation(node: Node, scale_to: float = 1.2, duration: float = ANIM_FAST) -> void:
	"""Animación de rebote para feedback visual"""
	var tween := node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "scale", Vector2.ONE * scale_to, duration)
	tween.tween_property(node, "scale", Vector2.ONE, duration)

static func pulse_animation(node: Node, min_alpha: float = 0.5, max_alpha: float = 1.0, duration: float = ANIM_SLOW) -> void:
	"""Animación de pulso para elementos destacados"""
	var tween := node.create_tween()
	tween.set_loops()
	tween.tween_property(node, "modulate:a", min_alpha, duration)
	tween.tween_property(node, "modulate:a", max_alpha, duration)

static func shake_animation(node: Node, intensity: float = 10.0, duration: float = ANIM_FAST) -> void:
	"""Animación de sacudida para errores"""
	var original_pos: Vector2 = node.position
	var tween := node.create_tween()
	for i in 4:
		var offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(node, "position", original_pos + offset, duration / 8.0)
	tween.tween_property(node, "position", original_pos, duration / 8.0)
