# GameSelector.gd
extends Control

@onready var games_grid = $MarginContainer/VBoxContainer/ScrollContainer/GamesGrid
@onready var back_button = $MarginContainer/VBoxContainer/Header/BackButton
@onready var title_label = $MarginContainer/VBoxContainer/Header/TitleLabel if has_node("MarginContainer/VBoxContainer/Header/TitleLabel") else null

var games_info: Array[Dictionary] = [
	{"name": "TraceGame", "display_name": "🖌️ Dibujo Libre", "scene": "res://scenes/games/TraceGame.tscn"},
	{"name": "ShapeTraceGame", "display_name": "🔤 Trazado Palabra", "scene": "res://scenes/games/ShapeTraceGame.tscn"},
	{"name": "MemoryGame", "display_name": "🧠 Memorice", "scene": "res://scenes/games/MemoryGame.tscn"},
	{"name": "PuzzleGame", "display_name": "🧩 Puzzle", "scene": "res://scenes/games/PuzzleGame.tscn"},
	{"name": "CountingGame", "display_name": "🔢 Contar", "scene": "res://scenes/games/CountingGame.tscn"},
	{"name": "MatchingGame", "display_name": "🔗 Unir Parejas", "scene": "res://scenes/games/MatchingGame.tscn"},
	{"name": "PatternGame", "display_name": "🧶 Secuencias", "scene": "res://scenes/games/PatternGame.tscn"},
	{"name": "MazeGame", "display_name": "🗺️ Laberinto", "scene": "res://scenes/games/MazeGame.tscn"},
	{"name": "ColorByNumberGame", "display_name": "🎨 Colorear", "scene": "res://scenes/games/ColorByNumberGame.tscn"},
	{"name": "SoundRecognitionGame", "display_name": "🔊 Sonidos", "scene": "res://scenes/games/SoundRecognitionGame.tscn"}
]

func _ready():
	print("GameSelector _ready()")
	set_process_input(true)
	populate_games_grid()
	setup_back_button()
	apply_title_style()

func _input(event):
	if event is InputEventScreenTouch and not event.pressed:
		check_button_click(event.position)

func populate_games_grid():
	if not games_grid:
		return
	
	for child in games_grid.get_children():
		child.queue_free()
	
	for game_info in games_info:
		var button = Button.new()
		button.custom_minimum_size = Vector2(880, 320)
		button.text = game_info["display_name"]
		button.add_theme_font_size_override("font_size", 130)
		button.focus_mode = Control.FOCUS_NONE
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		# Estilos con textura desde assets
		var tex_path = "res://assets/images/ui/panel_grey_bolts_blue.png"
		var tex_pressed_path = "res://assets/images/ui/panel_grey_bolts_green.png"
		if ResourceLoader.exists(tex_path):
			var sb_tex := StyleBoxTexture.new()
			sb_tex.texture = load(tex_path)
			sb_tex.expand_margin_left = 24
			sb_tex.expand_margin_right = 24
			sb_tex.expand_margin_top = 24
			sb_tex.expand_margin_bottom = 24
			button.add_theme_stylebox_override("normal", sb_tex)
			var sb_hover := sb_tex.duplicate()
			button.add_theme_stylebox_override("hover", sb_hover)
			if ResourceLoader.exists(tex_pressed_path):
				var sb_pressed := StyleBoxTexture.new()
				sb_pressed.texture = load(tex_pressed_path)
				button.add_theme_stylebox_override("pressed", sb_pressed)
		button.pressed.connect(func(): on_game_selected(game_info))
		games_grid.add_child(button)

func setup_back_button():
	if back_button:
		back_button.custom_minimum_size = Vector2(300, 150)
		back_button.add_theme_font_size_override("font_size", 90)
		back_button.focus_mode = Control.FOCUS_NONE
		back_button.pressed.connect(_on_back_pressed)
		var normal = StyleBoxFlat.new()
		normal.bg_color = Color(0,0,0,0.35)
		normal.corner_radius_top_left = 18
		normal.corner_radius_top_right = 18
		normal.corner_radius_bottom_left = 18
		normal.corner_radius_bottom_right = 18
		var hovered = normal.duplicate()
		hovered.bg_color = Color(0,0,0,0.45)
		var pressed = normal.duplicate()
		pressed.bg_color = Color(0,0,0,0.55)
		back_button.add_theme_stylebox_override("normal", normal)
		back_button.add_theme_stylebox_override("hover", hovered)
		back_button.add_theme_stylebox_override("pressed", pressed)

func apply_title_style():
	if title_label:
		title_label.add_theme_font_size_override("font_size", 60)
		title_label.add_theme_color_override("font_color", Color(1,1,1,0.9))

func check_button_click(pos: Vector2):
	if back_button and back_button.get_global_rect().has_point(pos):
		print("🎯 BACK")
		_on_back_pressed()
		return
	
	for child in games_grid.get_children():
		if child is Button and child.get_global_rect().has_point(pos):
			print("🎯 GAME:", child.text)
			child.pressed.emit()
			return

func on_game_selected(game_info: Dictionary):
	print("🎮 Iniciando:", game_info["name"])
	# Usar cambio diferido para evitar errores !is_inside_tree()
	get_tree().call_deferred("change_scene_to_file", game_info["scene"])

func _on_back_pressed():
	print("⬅️ Volver")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main/MainMenu.tscn")
