## Tarjeta del juego de memoria para niños de 3 años.
## Dorso colorido con "?" grande, frente con emoji/imagen.
## Colores vibrantes hardcodeados — no depende de theme global.

extends Button

const LOGP := "[MemoryTile] "

# --- Colores para cada carta (se asigna un índice por par) ---
const CARD_COLORS = [
	Color(0.93, 0.30, 0.36),
	Color(0.30, 0.69, 0.93),
	Color(0.56, 0.83, 0.26),
	Color(1.00, 0.76, 0.03),
	Color(0.68, 0.40, 0.88),
	Color(1.00, 0.50, 0.16),
	Color(0.93, 0.46, 0.74),
	Color(0.20, 0.78, 0.70),
]

# --- Variables ---
var revealed := false
var matched := false
var color_index := 0
var _front_text := ""
var _front_icon: Texture2D = null
var _tween: Tween
var _initialized := false

func _ready() -> void:
	print(LOGP, "MemoryTile _ready()")

func force_init() -> void:
	if _initialized:
		return
	_initialized = true
	print(LOGP, "force_init() llamado")
	focus_mode = Control.FOCUS_NONE
	toggle_mode = false
	clip_text = false
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_filter = Control.MOUSE_FILTER_STOP  # Asegurar que capture eventos de mouse/touch
	if ResourceLoader.exists("res://assets/fonts/NotoSans-Bold.ttf"):
		add_theme_font_override("font", load("res://assets/fonts/NotoSans-Bold.ttf"))
	_apply_back_style()
	_show_back()
	print(LOGP, "  ✓ inicialización completa")

func set_front_content(txt: String, ico: Texture2D = null) -> void:
	_front_text = txt
	_front_icon = ico

func set_revealed(value: bool) -> void:
	revealed = value
	print(LOGP, "set_revealed(", value, ") llamado")
	
	# Cancelar animación anterior si existe
	if _tween and _tween.is_valid():
		_tween.kill()
	
	# Cambiar directamente sin animación compleja por ahora
	if value:
		print(LOGP, "  → mostrando FRENTE")
		_apply_front_style()
		_show_front()
	else:
		print(LOGP, "  → mostrando DORSO")
		_apply_back_style()
		_show_back()
	
	# Pequeña animación simple de escala
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	_tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func set_matched(value: bool) -> void:
	matched = value
	disabled = value
	if value:
		_apply_match_style()
		_show_front()

func _apply_back_style() -> void:
	var bg = _get_back_color()
	var border = bg.darkened(0.2)
	var sb = _make_stylebox(bg, border)
	add_theme_stylebox_override("normal", sb)
	add_theme_stylebox_override("hover", _make_stylebox(bg.lightened(0.1), border))
	add_theme_stylebox_override("pressed", _make_stylebox(bg.darkened(0.1), border))
	add_theme_stylebox_override("focus", sb.duplicate())

func _apply_front_style() -> void:
	var bg = Color(1.0, 0.98, 0.90)
	var border = Color(1.0, 0.80, 0.25)
	var sb = _make_stylebox(bg, border)
	add_theme_stylebox_override("normal", sb)
	add_theme_stylebox_override("hover", sb.duplicate())
	add_theme_stylebox_override("pressed", sb.duplicate())
	add_theme_stylebox_override("focus", sb.duplicate())

func _apply_match_style() -> void:
	var bg = Color(0.60, 0.95, 0.60)
	var border = Color(0.20, 0.80, 0.45)
	var sb = _make_stylebox(bg, border)
	add_theme_stylebox_override("normal", sb)
	add_theme_stylebox_override("hover", sb.duplicate())
	add_theme_stylebox_override("pressed", sb.duplicate())
	add_theme_stylebox_override("disabled", sb.duplicate())
	add_theme_stylebox_override("focus", sb.duplicate())

func _make_stylebox(bg: Color, border: Color) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.border_width_top = 4
	s.border_width_left = 4
	s.border_width_right = 4
	s.border_width_bottom = 8
	s.corner_radius_top_left = 24
	s.corner_radius_top_right = 24
	s.corner_radius_bottom_left = 24
	s.corner_radius_bottom_right = 24
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	s.shadow_color = Color(0, 0, 0, 0.22)
	s.shadow_size = 8
	return s

func _get_back_color() -> Color:
	if color_index >= 0 and color_index < CARD_COLORS.size():
		return CARD_COLORS[color_index]
	return Color(0.45, 0.30, 0.75)

func _show_back() -> void:
	text = "?"
	icon = null
	add_theme_font_size_override("font_size", 64)
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_color_override("font_pressed_color", Color(1, 1, 1, 0.8))
	add_theme_color_override("font_hover_color", Color.WHITE)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _show_front() -> void:
	print(LOGP, "_show_front() - _front_icon=", _front_icon, " _front_text=", _front_text)
	var dark = Color(0.20, 0.15, 0.35)
	add_theme_color_override("font_color", dark)
	add_theme_color_override("font_pressed_color", dark)
	add_theme_color_override("font_hover_color", dark)
	if _front_icon:
		icon = _front_icon
		text = ""
		expand_icon = true
		print(LOGP, "  → mostrando icono")
	elif _front_text != "":
		text = _front_text
		icon = null
		print(LOGP, "  → mostrando texto: ", _front_text)
	else:
		text = "?"
		icon = null
		print(LOGP, "  → fallback '?'")
	add_theme_font_size_override("font_size", 180)  # Aumentado de 120 a 180 para que sea MUCHO más grande
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER

