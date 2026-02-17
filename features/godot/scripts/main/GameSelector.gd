## Selector de juegos: muestra una cuadrícula de tarjetas con los juegos
## disponibles, progreso por estrellas y animaciones de entrada.

extends Control

# --- Constantes ---
const LOGP := "[GameSelector] "

const CARD_COLORS: Array[Color] = [
	Color(0.94, 0.55, 0.55),  # Rojo suave
	Color(0.55, 0.78, 0.94),  # Azul suave
	Color(0.94, 0.82, 0.55),  # Amarillo
	Color(0.55, 0.94, 0.65),  # Verde
	Color(0.78, 0.55, 0.94),  # Morado
	Color(0.94, 0.65, 0.55),  # Naranja
	Color(0.55, 0.94, 0.88),  # Turquesa
	Color(0.85, 0.55, 0.78),  # Rosa
	Color(0.65, 0.85, 0.55),  # Verde lima
	Color(0.55, 0.65, 0.94)   # Azul oscuro
]

# --- Variables Miembro ---
var games_info: Array[Dictionary] = [
	{"name": "TraceGame", "display_name": "Dibujo Libre", "icon": "🖌️", "scene": "res://scenes/games/TraceGame.tscn"},
	{"name": "ShapeTraceGame", "display_name": "Trazado", "icon": "🔤", "scene": "res://scenes/games/ShapeTraceGame.tscn"},
	{"name": "MemoryGame", "display_name": "Memorice", "icon": "🧠", "scene": "res://scenes/games/MemoryGame.tscn"},
	{"name": "PuzzleGame", "display_name": "Puzzle", "icon": "🧩", "scene": "res://scenes/games/PuzzleGame.tscn"},
	{"name": "CountingGame", "display_name": "Contar", "icon": "🔢", "scene": "res://scenes/games/CountingGame.tscn"},
	{"name": "MatchingGame", "display_name": "Parejas", "icon": "🔗", "scene": "res://scenes/games/MatchingGame.tscn"},
	{"name": "PatternGame", "display_name": "Secuencias", "icon": "🧶", "scene": "res://scenes/games/PatternGame.tscn"},
	{"name": "MazeGame", "display_name": "Laberinto", "icon": "🗺️", "scene": "res://scenes/games/MazeGame.tscn"},
	{"name": "ColorByNumberGame", "display_name": "Colorear", "icon": "🎨", "scene": "res://scenes/games/ColorByNumberGame.tscn"},
	{"name": "SoundRecognitionGame", "display_name": "Sonidos", "icon": "🔊", "scene": "res://scenes/games/SoundRecognitionGame.tscn"}
]

var _card_buttons: Array[Button] = []

# --- Variables Onready ---
@onready var games_grid: GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/GamesGrid
@onready var back_button: Button = $MarginContainer/VBoxContainer/Header/BackButton
@onready var title_label: Label = $MarginContainer/VBoxContainer/Header/TitleLabel if has_node("MarginContainer/VBoxContainer/Header/TitleLabel") else null

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	print(LOGP, "_ready()")
	set_process_input(true)
	_apply_background()
	_populate_games_grid()
	_setup_back_button()
	_apply_title_style()
	_animate_cards_entrance()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and not event.pressed:
		_check_button_click(event.position)

# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func on_game_selected(game_info: Dictionary) -> void:
	print(LOGP, "Iniciando: ", game_info["name"])
	AudioManager.play_button_press()
	var bootstrap: Node = get_node_or_null("/root/UiBootstrap")
	if bootstrap and bootstrap.has_method("fade_to_scene"):
		bootstrap.fade_to_scene(game_info["scene"])
	else:
		get_tree().call_deferred("change_scene_to_file", game_info["scene"])

# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _apply_background() -> void:
	## Fondo degradado claro para el selector.
	var bg: ColorRect = get_node_or_null("Background")
	if bg:
		bg.color = Color(0.92, 0.95, 1.0)


func _populate_games_grid() -> void:
	if not games_grid:
		return

	for child in games_grid.get_children():
		child.queue_free()

	_card_buttons.clear()
	games_grid.columns = 2
	games_grid.add_theme_constant_override("h_separation", 30)
	games_grid.add_theme_constant_override("v_separation", 30)

	for i: int in games_info.size():
		var game_info: Dictionary = games_info[i]
		var card: Button = _create_game_card(game_info, i)
		games_grid.add_child(card)
		_card_buttons.append(card)


func _create_game_card(game_info: Dictionary, index: int) -> Button:
	## Crea una tarjeta de juego visual con icono, nombre y estrellas.
	var button := Button.new()
	button.custom_minimum_size = Vector2(840, 280)
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS

	# Texto con icono grande + nombre
	button.text = "%s\n%s" % [game_info["icon"], game_info["display_name"]]
	button.add_theme_font_size_override("font_size", 72)

	# Color de fondo por tarjeta
	var card_color: Color = CARD_COLORS[index % CARD_COLORS.size()]
	var normal := StyleBoxFlat.new()
	normal.bg_color = card_color
	normal.corner_radius_top_left = 28
	normal.corner_radius_top_right = 28
	normal.corner_radius_bottom_left = 28
	normal.corner_radius_bottom_right = 28
	normal.shadow_size = 4
	normal.shadow_color = Color(0, 0, 0, 0.15)
	normal.shadow_offset = Vector2(0, 3)
	normal.content_margin_left = 20
	normal.content_margin_right = 20
	normal.content_margin_top = 16
	normal.content_margin_bottom = 16

	var hovered := normal.duplicate()
	hovered.bg_color = card_color.lightened(0.12)
	hovered.shadow_size = 6

	var pressed := normal.duplicate()
	pressed.bg_color = card_color.darkened(0.1)
	pressed.shadow_size = 2
	pressed.shadow_offset = Vector2(0, 1)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hovered)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 0.85))

	# Estrellas del progreso (como sufijo)
	var stars: int = GameManager.get_game_stars(game_info["name"])
	if stars > 0:
		button.text += "\n" + "⭐".repeat(stars)

	# Preparar para animación de entrada (invisible inicialmente)
	button.modulate = Color(1, 1, 1, 0)
	button.scale = Vector2(0.8, 0.8)
	button.pivot_offset = Vector2(420, 140)

	button.pressed.connect(func() -> void: on_game_selected(game_info))
	return button


func _animate_cards_entrance() -> void:
	## Animación escalonada de aparición de tarjetas.
	for i: int in _card_buttons.size():
		var card: Button = _card_buttons[i]
		var delay: float = 0.05 * i
		var tween: Tween = create_tween()
		tween.tween_interval(delay)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_parallel(true)
		tween.tween_property(card, "modulate", Color.WHITE, 0.4).set_delay(delay)
		tween.tween_property(card, "scale", Vector2.ONE, 0.5).set_delay(delay)


func _setup_back_button() -> void:
	if back_button:
		back_button.text = "← Inicio"
		back_button.custom_minimum_size = Vector2(300, 120)
		back_button.add_theme_font_size_override("font_size", 50)
		back_button.focus_mode = Control.FOCUS_NONE
		back_button.pressed.connect(_on_back_pressed)
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color(0.3, 0.3, 0.5, 0.7)
		normal.corner_radius_top_left = 20
		normal.corner_radius_top_right = 20
		normal.corner_radius_bottom_left = 20
		normal.corner_radius_bottom_right = 20
		var hovered := normal.duplicate()
		hovered.bg_color = Color(0.35, 0.35, 0.55, 0.8)
		var pressed := normal.duplicate()
		pressed.bg_color = Color(0.25, 0.25, 0.45, 0.9)
		back_button.add_theme_stylebox_override("normal", normal)
		back_button.add_theme_stylebox_override("hover", hovered)
		back_button.add_theme_stylebox_override("pressed", pressed)
		back_button.add_theme_color_override("font_color", Color.WHITE)

func _apply_title_style() -> void:
	if title_label:
		title_label.text = "🎮 Elige tu Juego"
		title_label.add_theme_font_size_override("font_size", 64)
		title_label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.4))
		title_label.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.5))
		title_label.add_theme_constant_override("outline_size", 3)

func _check_button_click(pos: Vector2) -> void:
	if back_button and back_button.get_global_rect().has_point(pos):
		print(LOGP, "BACK")
		_on_back_pressed()
		return

	for child in games_grid.get_children():
		if child is Button and child.get_global_rect().has_point(pos):
			print(LOGP, "GAME: ", child.text)
			child.pressed.emit()
			return

func _on_back_pressed() -> void:
	print(LOGP, "Volver")
	AudioManager.play_back()
	var bootstrap: Node = get_node_or_null("/root/UiBootstrap")
	if bootstrap and bootstrap.has_method("fade_to_scene"):
		bootstrap.fade_to_scene("res://scenes/main/MainMenu.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main/MainMenu.tscn")
