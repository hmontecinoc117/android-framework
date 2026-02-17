extends Control

# Simple Maze Game - Guía al emoji hasta la meta
var player_pos = Vector2(0, 0)
var goal_pos = Vector2(3, 3)
var cell_size = 200
var grid_start = Vector2(440, 280)

# Laberinto 4x4 (0=camino, 1=pared)
var maze = [
	[0, 0, 1, 0],
	[1, 0, 1, 0],
	[0, 0, 0, 1],
	[0, 1, 0, 0]
]

var player_sprite = null
var goal_sprite = null
var cell_sprites = []

func _ready():
	setup_ui()
	create_maze()
	update_player_position()

func setup_ui():
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.85, 0.95, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Título
	var title = Label.new()
	title.text = "🗺️ LABERINTO 🗺️"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 60)
	title.position = Vector2(540, 40)
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
	
	# Botón Reiniciar
	var reset_btn = Button.new()
	reset_btn.text = "🔄"
	reset_btn.position = Vector2(1710, 50)
	reset_btn.size = Vector2(140, 120)
	reset_btn.add_theme_font_size_override("font_size", 70)
	reset_btn.pressed.connect(reset_game)
	add_child(reset_btn)
	
	# Controles direccionales
	var controls_start = Vector2(740, 1000)
	var btn_size = Vector2(180, 180)
	
	var up_btn = Button.new()
	up_btn.text = "⬆️"
	up_btn.position = controls_start + Vector2(200, 0)
	up_btn.size = btn_size
	up_btn.add_theme_font_size_override("font_size", 80)
	up_btn.pressed.connect(_on_move.bind(Vector2(0, -1)))
	add_child(up_btn)
	
	var down_btn = Button.new()
	down_btn.text = "⬇️"
	down_btn.position = controls_start + Vector2(200, 200)
	down_btn.size = btn_size
	down_btn.add_theme_font_size_override("font_size", 80)
	down_btn.pressed.connect(_on_move.bind(Vector2(0, 1)))
	add_child(down_btn)
	
	var left_btn = Button.new()
	left_btn.text = "⬅️"
	left_btn.position = controls_start + Vector2(0, 100)
	left_btn.size = btn_size
	left_btn.add_theme_font_size_override("font_size", 80)
	left_btn.pressed.connect(_on_move.bind(Vector2(-1, 0)))
	add_child(left_btn)
	
	var right_btn = Button.new()
	right_btn.text = "➡️"
	right_btn.position = controls_start + Vector2(400, 100)
	right_btn.size = btn_size
	right_btn.add_theme_font_size_override("font_size", 80)
	right_btn.pressed.connect(_on_move.bind(Vector2(1, 0)))
	add_child(right_btn)

func create_maze():
	# Crear celdas del laberinto
	for row in range(4):
		for col in range(4):
			var pos = grid_start + Vector2(col * cell_size, row * cell_size)
			var cell = ColorRect.new()
			cell.position = pos
			cell.size = Vector2(cell_size - 10, cell_size - 10)
			
			if maze[row][col] == 1:
				cell.color = Color(0.3, 0.3, 0.3)  # Pared
			else:
				cell.color = Color(0.95, 0.95, 0.95)  # Camino
			
			add_child(cell)
			cell_sprites.append(cell)
	
	# Meta
	goal_sprite = Label.new()
	goal_sprite.text = "🎯"
	goal_sprite.add_theme_font_size_override("font_size", 140)
	goal_sprite.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	goal_sprite.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	goal_sprite.size = Vector2(cell_size - 10, cell_size - 10)
	add_child(goal_sprite)
	goal_sprite.position = grid_start + Vector2(goal_pos.x * cell_size, goal_pos.y * cell_size)
	
	# Jugador
	player_sprite = Label.new()
	player_sprite.text = "😊"
	player_sprite.add_theme_font_size_override("font_size", 140)
	player_sprite.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_sprite.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	player_sprite.size = Vector2(cell_size - 10, cell_size - 10)
	add_child(player_sprite)

func update_player_position():
	player_sprite.position = grid_start + Vector2(player_pos.x * cell_size, player_pos.y * cell_size)
	
	# Verificar si llegó a la meta
	if player_pos == goal_pos:
		win_game()

func _on_move(direction: Vector2):
	var new_pos = player_pos + direction
	
	# Verificar límites
	if new_pos.x < 0 or new_pos.x >= 4 or new_pos.y < 0 or new_pos.y >= 4:
		return
	
	# Verificar pared
	if maze[int(new_pos.y)][int(new_pos.x)] == 1:
		return
	
	# Mover
	player_pos = new_pos
	update_player_position()

func win_game():
	var msg = Label.new()
	msg.text = "¡GANASTE! 🏆"
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.position = Vector2(540, 150)
	msg.size = Vector2(800, 120)
	msg.add_theme_font_size_override("font_size", 70)
	msg.modulate = Color(0, 1, 0)
	add_child(msg)
	
	await get_tree().create_timer(2.0).timeout
	reset_game()
	msg.queue_free()

func reset_game():
	player_pos = Vector2(0, 0)
	update_player_position()

func go_home():
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
