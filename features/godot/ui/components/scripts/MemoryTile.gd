## Tarjeta del juego de memoria para niños de 3 años.
## Dorso: azul cielo con "?" en Fredoka One.
## Frente: blanco con borde dorado y emoji/imagen.
## Animación flip: scale.x 1→0→1 con bounce final.

extends Button

const LOGP := "[MemoryTile] "

# Colores propios de cada par (se asigna color_index desde MemoryGame)
const CARD_COLORS: Array[Color] = [
	Color("#FF6B35"),  # Naranja
	Color("#4ECDC4"),  # Turquesa
	Color("#44CF6C"),  # Verde
	Color("#FFD93D"),  # Amarillo
	Color("#C77DFF"),  # Lavanda
	Color("#FF6B6B"),  # Rojo suave
	Color("#FFA07A"),  # Salmón
	Color("#87CEEB"),  # Azul cielo
]

# Colores del dorso (fijo para todos)
const BACK_BG     := Color("#A8DAFF")
const BACK_BORDER := Color("#5BA8D9")

# Colores del frente
const FRONT_BG     := Color("#FFFFFF")
const FRONT_BORDER := Color("#FFD700")  # Dorado

# --- Variables ---
var revealed   := false
var matched    := false
var color_index := 0
var _front_text := ""
var _front_icon: Texture2D = null
var _tween: Tween
var _initialized := false


# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	print(LOGP, "MemoryTile _ready()")


# ──────────────────────────────────────────────
#  API Pública
# ──────────────────────────────────────────────

func force_init() -> void:
	if _initialized:
		return
	_initialized = true
	print(LOGP, "force_init()")

	focus_mode                 = Control.FOCUS_NONE
	toggle_mode                = false
	clip_text                  = false
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_filter               = Control.MOUSE_FILTER_STOP

	# Cargar Fredoka One con fallback
	var font_path := "res://assets/fonts/FredokaOne-Regular.ttf"
	if ResourceLoader.exists(font_path):
		add_theme_font_override("font", load(font_path))
	elif ResourceLoader.exists("res://assets/fonts/NotoSans-Bold.ttf"):
		add_theme_font_override("font", load("res://assets/fonts/NotoSans-Bold.ttf"))

	_apply_back_style()
	_show_back()
	print(LOGP, "  ✓ inicialización completa")


func set_front_content(txt: String, ico: Texture2D = null) -> void:
	_front_text = txt
	_front_icon = ico


func set_revealed(value: bool) -> void:
	revealed = value
	print(LOGP, "set_revealed(", value, ")")

	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.set_parallel(false)

	# Fase 1: escala → 0 (girar hacia adentro)
	_tween.set_trans(Tween.TRANS_QUAD)
	_tween.set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "scale:x", 0.0, 0.12)

	# Cambiar contenido en el punto medio
	_tween.tween_callback(func() -> void:
		if value:
			_apply_front_style()
			_show_front()
		else:
			_apply_back_style()
			_show_back()
	)

	# Fase 2: escala → 1 (girar hacia afuera)
	_tween.set_trans(Tween.TRANS_QUAD)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale:x", 1.0, 0.12)

	# Bounce final solo al revelar
	if value:
		_tween.set_trans(Tween.TRANS_BACK)
		_tween.set_ease(Tween.EASE_OUT)
		_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.10)
		_tween.tween_property(self, "scale", Vector2.ONE,       0.10)


func set_matched(value: bool) -> void:
	matched  = value
	disabled = value
	if value:
		_apply_match_style()
		_show_front()


# ──────────────────────────────────────────────
#  Estilos
# ──────────────────────────────────────────────

func _apply_back_style() -> void:
	var sb := _make_stylebox(BACK_BG, BACK_BORDER, 8, 4)
	add_theme_stylebox_override("normal",   sb)
	add_theme_stylebox_override("hover",    _make_stylebox(BACK_BG.lightened(0.08), BACK_BORDER, 10, 4))
	add_theme_stylebox_override("pressed",  _make_stylebox(BACK_BG.darkened(0.08),  BACK_BORDER, 4,  2))
	add_theme_stylebox_override("focus",    sb.duplicate())
	add_theme_stylebox_override("disabled", sb.duplicate())


func _apply_front_style() -> void:
	var sb := _make_stylebox(FRONT_BG, FRONT_BORDER, 6, 3)
	add_theme_stylebox_override("normal",   sb)
	add_theme_stylebox_override("hover",    sb.duplicate())
	add_theme_stylebox_override("pressed",  sb.duplicate())
	add_theme_stylebox_override("focus",    sb.duplicate())
	add_theme_stylebox_override("disabled", sb.duplicate())


func _apply_match_style() -> void:
	var bg     := Color("#44CF6C")
	var border := Color("#22A850")
	var sb := _make_stylebox(bg, border, 4, 2)
	add_theme_stylebox_override("normal",   sb)
	add_theme_stylebox_override("hover",    sb.duplicate())
	add_theme_stylebox_override("pressed",  sb.duplicate())
	add_theme_stylebox_override("disabled", sb.duplicate())
	add_theme_stylebox_override("focus",    sb.duplicate())


func _make_stylebox(bg: Color, border: Color, shadow: int, border_bottom: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color    = bg
	# Borde inferior más grueso → efecto 3D
	s.border_color        = border
	s.border_width_top    = 3
	s.border_width_left   = 3
	s.border_width_right  = 3
	s.border_width_bottom = border_bottom

	s.corner_radius_top_left     = 24
	s.corner_radius_top_right    = 24
	s.corner_radius_bottom_left  = 24
	s.corner_radius_bottom_right = 24

	s.content_margin_left   = 10
	s.content_margin_right  = 10
	s.content_margin_top    = 10
	s.content_margin_bottom = 10

	s.shadow_color  = Color(0, 0, 0, 0.22)
	s.shadow_size   = shadow
	s.shadow_offset = Vector2(0, float(shadow) / 2.0)
	return s


# ──────────────────────────────────────────────
#  Mostrar contenido
# ──────────────────────────────────────────────

func _show_back() -> void:
	text = "?"
	icon = null
	add_theme_font_size_override("font_size", 72)
	add_theme_color_override("font_color",         Color.WHITE)
	add_theme_color_override("font_pressed_color", Color(1, 1, 1, 0.85))
	add_theme_color_override("font_hover_color",   Color.WHITE)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment   = VERTICAL_ALIGNMENT_CENTER


func _show_front() -> void:
	print(LOGP, "_show_front() icon=", _front_icon, " text=", _front_text)
	add_theme_color_override("font_color",         Color("#2D2D2D"))
	add_theme_color_override("font_pressed_color", Color("#2D2D2D"))
	add_theme_color_override("font_hover_color",   Color("#2D2D2D"))

	if _front_icon:
		icon        = _front_icon
		text        = ""
		expand_icon = true
		icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	elif _front_text != "":
		text = _front_text
		icon = null
	else:
		text = "?"
		icon = null

	add_theme_font_size_override("font_size", 180)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment   = VERTICAL_ALIGNMENT_CENTER


func _get_back_color() -> Color:
	if color_index >= 0 and color_index < CARD_COLORS.size():
		return CARD_COLORS[color_index]
	return Color("#A8DAFF")
