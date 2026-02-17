extends Control

# Simple Puzzle Game - Reorganiza las piezas
var PIECES = [
	{"emoji": "🦁", "color": Color(1, 0.8, 0.3)},
	{"emoji": "🐘", "color": Color(0.7, 0.7, 0.8)},
	{"emoji": "🦒", "color": Color(1, 0.9, 0.5)},
	{"emoji": "🦓", "color": Color(0.9, 0.9, 0.9)}
]

var piece_buttons = []
var correct_positions = []
var current_positions = []
var selected_piece = -1

func _ready():
	setup_ui()
	shuffle_puzzle()

func setup_ui():
	# Background colorido
	var bg = ColorRect.new()
	bg.color = Color(0.3, 0.7, 0.9)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Título
	var title = Label.new()
	title.text = "🧩 ROMPECABEZAS 🧩"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 60)
	title.position = Vector2(540, 50)
	title.size = Vector2(800, 100)
	add_child(title)
	
	# Botón Home
	var home_btn = Button.new()
	home_btn.text = "🏠"
	home_btn.position = Vector2(50, 50)
	home_btn.size = Vector2(120, 120)
	home_btn.add_theme_font_size_override("font_size", 70)
	home_btn.pressed.connect(go_home)
	add_child(home_btn)
	
	# Grid de piezas 2x2
	var grid_start = Vector2(490, 300)
	var piece_size = 280
	var gap = 20
	
	for i in range(4):
		var row = i / 2
		var col = i % 2
		var pos = grid_start + Vector2(col * (piece_size + gap), row * (piece_size + gap))
		correct_positions.append(i)
		
		var btn = Button.new()
		btn.position = pos
		btn.size = Vector2(piece_size, piece_size)
		btn.add_theme_font_size_override("font_size", 140)
		piece_buttons.append(btn)
		btn.pressed.connect(_on_piece_pressed.bind(i))
		add_child(btn)

func shuffle_puzzle():
	# Mezclar posiciones
	current_positions = correct_positions.duplicate()
	for i in range(20):
		var a = randi() % 4
		var b = randi() % 4
		var temp = current_positions[a]
		current_positions[a] = current_positions[b]
		current_positions[b] = temp
	
	update_pieces()

func update_pieces():
	for i in range(4):
		var piece_idx = current_positions[i]
		var piece = PIECES[piece_idx]
		var btn = piece_buttons[i]
		
		var style = StyleBoxFlat.new()
		style.bg_color = piece.color
		style.corner_radius_top_left = 20
		style.corner_radius_top_right = 20
		style.corner_radius_bottom_left = 20
		style.corner_radius_bottom_right = 20
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		
		btn.text = piece.emoji
		
		# Highlight si está seleccionado
		if i == selected_piece:
			btn.modulate = Color(1.5, 1.5, 1.5)
		else:
			btn.modulate = Color(1, 1, 1)

func _on_piece_pressed(idx):
	if selected_piece == -1:
		# Seleccionar primera pieza
		selected_piece = idx
		update_pieces()
	else:
		if selected_piece == idx:
			# Deseleccionar
			selected_piece = -1
			update_pieces()
		else:
			# Intercambiar piezas
			var temp = current_positions[selected_piece]
			current_positions[selected_piece] = current_positions[idx]
			current_positions[idx] = temp
			selected_piece = -1
			update_pieces()
			check_win()

func check_win():
	for i in range(4):
		if current_positions[i] != correct_positions[i]:
			return
	
	# ¡Ganó!
	show_win_message()

func show_win_message():
	var win_label = Label.new()
	win_label.text = "¡EXCELENTE! 🎉"
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.position = Vector2(340, 950)
	win_label.size = Vector2(1200, 150)
	win_label.add_theme_font_size_override("font_size", 80)
	win_label.modulate = Color(1, 1, 0)
	add_child(win_label)
	
	await get_tree().create_timer(2.0).timeout
	shuffle_puzzle()
	win_label.queue_free()

func go_home():
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
