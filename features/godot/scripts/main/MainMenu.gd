## Menú principal: pantalla de bienvenida animada con título,
## fondo animado BackgroundBuilder y grid de juegos.

extends Control

# --- Señales ---

# --- Enums ---

# --- Constantes ---
const LOGP := "[MainMenu] "

# Color único por juego (mismo orden que GAME_NAMES)
const GAME_COLORS: Array[Color] = [
	Color("#FF6B35"),  # Memorice
	Color("#4ECDC4"),  # Formas
	Color("#44CF6C"),  # Conteo
	Color("#FFD93D"),  # Patrones
	Color("#C77DFF"),  # Laberinto
	Color("#FF6B6B"),  # Puzzle
	Color("#FFA07A"),  # Sonidos
	Color("#87CEEB"),  # Trazado
]

const GAME_NAMES: Array[String] = [
	"🧠\nMemorice",
	"🔷\nFormas",
	"🔢\nConteo",
	"🎨\nPatrones",
	"🌀\nLaberinto",
	"🧩\nPuzzle",
	"🎵\nSonidos",
	"✏️\nTrazado",
]

const GAME_SCENES: Array[String] = [
	"res://scenes/games/MemoryGame.tscn",
	"res://scenes/games/MatchingGame.tscn",
	"res://scenes/games/CountingGame.tscn",
	"res://scenes/games/PatternGame.tscn",
	"res://scenes/games/MazeGame.tscn",
	"res://scenes/games/PuzzleGame.tscn",
	"res://scenes/games/SoundRecognitionGame.tscn",
	"res://scenes/games/TraceGame.tscn",
]

# --- @export ---

# --- Variables ---
var _title_label:    Label
var _subtitle_label: Label
var _game_buttons:   Array[Button] = []
var _auto_advance_triggered: bool  = false
var _auto_timer: SceneTreeTimer

# --- @onready ---


# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	print(LOGP, "_ready()")

	# Fondo animado de 3 capas (BackgroundBuilder autoload)
	BackgroundBuilder.build(self)

	_build_title()
	_build_subtitle()
	_build_game_grid()
	_animate_entrance()

	AudioManager.play_music("menu_theme", 2.0)

	# Auto-avance al selector tras 8s (más tiempo — menú principal)
	_auto_timer = get_tree().create_timer(8.0)
	_auto_timer.timeout.connect(_on_auto_advance)


func _input(event: InputEvent) -> void:
	# Toque en cualquier botón de juego se maneja por signal pressed
	pass


# ──────────────────────────────────────────────
#  Funciones Privadas — Construcción UI
# ──────────────────────────────────────────────

func _build_title() -> void:
	_title_label = Label.new()
	_title_label.text = "🎮 Juegos GustaNuno"

	# Tamaño adaptativo Fredoka One 88px
	var font_size := ScreenSizeAdapter.get_adaptive_font_size(88)
	_title_label.add_theme_font_size_override("font_size", font_size)

	# Fuente Fredoka One
	var font_path := "res://assets/fonts/FredokaOne-Regular.ttf"
	if ResourceLoader.exists(font_path):
		_title_label.add_theme_font_override("font", load(font_path))

	# Color naranja + sombra de texto
	_title_label.add_theme_color_override("font_color",         Color("#FF6B35"))
	_title_label.add_theme_color_override("font_shadow_color",  Color(0, 0, 0, 0.20))
	_title_label.add_theme_constant_override("shadow_offset_x", 3)
	_title_label.add_theme_constant_override("shadow_offset_y", 3)
	_title_label.add_theme_color_override("font_outline_color", Color(0.9, 0.3, 0.0, 0.4))
	_title_label.add_theme_constant_override("outline_size",    4)

	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_title_label.offset_top    = 60
	_title_label.offset_bottom = 160
	_title_label.offset_left   = -700
	_title_label.offset_right  = 700

	# Empieza invisible para animación de entrada
	_title_label.modulate = Color(1, 1, 1, 0)
	_title_label.scale    = Vector2(0.6, 0.6)
	_title_label.pivot_offset = Vector2(700, 50)
	add_child(_title_label)


func _build_subtitle() -> void:
	_subtitle_label = Label.new()
	_subtitle_label.text = "¡Aprende jugando!"

	var font_size := ScreenSizeAdapter.get_adaptive_font_size(48)
	_subtitle_label.add_theme_font_size_override("font_size", font_size)

	var font_path := "res://assets/fonts/FredokaOne-Regular.ttf"
	if ResourceLoader.exists(font_path):
		_subtitle_label.add_theme_font_override("font", load(font_path))

	_subtitle_label.add_theme_color_override("font_color",         Color("#2D2D2D"))
	_subtitle_label.add_theme_color_override("font_shadow_color",  Color(0, 0, 0, 0.15))
	_subtitle_label.add_theme_constant_override("shadow_offset_x", 2)
	_subtitle_label.add_theme_constant_override("shadow_offset_y", 2)

	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_subtitle_label.offset_top    = 165
	_subtitle_label.offset_bottom = 230
	_subtitle_label.offset_left   = -500
	_subtitle_label.offset_right  = 500

	_subtitle_label.modulate = Color(1, 1, 1, 0)
	add_child(_subtitle_label)


func _build_game_grid() -> void:
	# Contenedor centrado
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.offset_top = 240
	add_child(center)

	# Grid 2 columnas
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 24)
	center.add_child(grid)

	# Botones de juego
	for i: int in GAME_NAMES.size():
		var btn := _make_game_button(i)
		grid.add_child(btn)
		_game_buttons.append(btn)
		# Inicia invisible para animación escalonada
		btn.modulate = Color(1, 1, 1, 0)
		btn.scale    = Vector2(0.5, 0.5)
		btn.pivot_offset = Vector2(80, 80)


func _make_game_button(index: int) -> Button:
	var btn := Button.new()
	btn.text = GAME_NAMES[index]
	btn.custom_minimum_size = Vector2(160, 160)
	btn.focus_mode = Control.FOCUS_NONE
	btn.clip_text  = false

	var font_size := ScreenSizeAdapter.get_adaptive_font_size(36)
	btn.add_theme_font_size_override("font_size", font_size)

	var font_path := "res://assets/fonts/FredokaOne-Regular.ttf"
	if ResourceLoader.exists(font_path):
		btn.add_theme_font_override("font", load(font_path))

	var bg: Color = GAME_COLORS[index % GAME_COLORS.size()]
	btn.add_theme_stylebox_override("normal",  _make_game_btn_style(bg, 8, 5))
	btn.add_theme_stylebox_override("hover",   _make_game_btn_style(bg.lightened(0.08), 10, 5))
	btn.add_theme_stylebox_override("pressed", _make_game_btn_style(bg.darkened(0.08),  2, 1))
	btn.add_theme_color_override("font_color",         Color.WHITE)
	btn.add_theme_color_override("font_hover_color",   Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 0.9))

	# Conectar con el índice capturado por valor
	btn.pressed.connect(_on_game_button_pressed.bind(index))
	return btn


func _make_game_btn_style(bg: Color, shadow: int, border_bottom: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color     = bg
	s.corner_radius_top_left     = 32
	s.corner_radius_top_right    = 32
	s.corner_radius_bottom_left  = 32
	s.corner_radius_bottom_right = 32
	s.border_width_bottom = border_bottom
	s.border_color        = bg.darkened(0.25)
	s.shadow_color        = Color(0, 0, 0, 0.25)
	s.shadow_size         = shadow
	s.shadow_offset       = Vector2(0, float(shadow) / 2.0)
	s.content_margin_left   = 12
	s.content_margin_right  = 12
	s.content_margin_top    = 12
	s.content_margin_bottom = 12
	return s


# ──────────────────────────────────────────────
#  Animaciones de Entrada
# ──────────────────────────────────────────────

func _animate_entrance() -> void:
	# 1. Título con bounce
	var t1 := create_tween()
	t1.set_ease(Tween.EASE_OUT)
	t1.set_trans(Tween.TRANS_BACK)
	t1.set_parallel(true)
	t1.tween_property(_title_label, "modulate", Color.WHITE,  0.35)
	t1.tween_property(_title_label, "scale",    Vector2.ONE,  0.35)

	# 2. Subtítulo fade in
	var t2 := create_tween()
	t2.tween_interval(0.20)
	t2.tween_property(_subtitle_label, "modulate", Color.WHITE, 0.25)

	# 3. Botones de juego escalonados
	for i: int in _game_buttons.size():
		var btn := _game_buttons[i]
		var td := create_tween()
		td.tween_interval(0.30 + i * 0.06)
		td.set_ease(Tween.EASE_OUT)
		td.set_trans(Tween.TRANS_BACK)
		td.set_parallel(true)
		td.tween_property(btn, "modulate", Color.WHITE, 0.20)
		td.tween_property(btn, "scale",    Vector2.ONE, 0.25)


# ──────────────────────────────────────────────
#  Handlers
# ──────────────────────────────────────────────

func _on_game_button_pressed(index: int) -> void:
	if _auto_advance_triggered:
		return
	_auto_advance_triggered = true

	print(LOGP, "juego seleccionado: ", index, " → ", GAME_SCENES[index])
	AudioManager.play_button_press()

	# Animación de salida rápida
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(_title_label,    "modulate:a", 0.0, 0.20)
	tween.tween_property(_subtitle_label, "modulate:a", 0.0, 0.15)
	for btn: Button in _game_buttons:
		tween.tween_property(btn, "modulate:a", 0.0, 0.15)

	var scene := GAME_SCENES[index]
	tween.chain().tween_callback(func() -> void:
		var bootstrap: Node = get_node_or_null("/root/UiBootstrap")
		if bootstrap and bootstrap.has_method("fade_to_scene"):
			bootstrap.fade_to_scene(scene)
		else:
			get_tree().call_deferred("change_scene_to_file", scene)
	)


func _on_auto_advance() -> void:
	if _auto_advance_triggered:
		return
	_auto_advance_triggered = true
	print(LOGP, "auto-avance a GameSelector (8s)")
	var bootstrap: Node = get_node_or_null("/root/UiBootstrap")
	if bootstrap and bootstrap.has_method("fade_to_scene"):
		bootstrap.fade_to_scene("res://scenes/main/GameSelector.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main/GameSelector.tscn")
