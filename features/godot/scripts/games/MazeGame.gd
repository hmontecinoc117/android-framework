# MazeGame.gd
# Juego de laberinto con personaje guiado por el dedo
extends Node2D

signal game_completed(stars: int, time: float)

@export var maze_size: Vector2i = Vector2i(7, 7)  # Tamaño del laberinto
@export var difficulty: int = 1  # 1-5

# Nodos
var player
var maze_tilemap
var goal
var items_container
var timer_label
var items_label

# Variables
var is_dragging: bool = false
var last_touch_position: Vector2
var collected_items: int = 0
var total_items: int = 3
var start_time: float = 0.0
var maze_data: Array[Array] = []
var cell_size: float = 80.0
var player_speed: float = 200.0

# Tipos de celda
enum CellType {
	EMPTY,
	WALL,
	START,
	GOAL,
	ITEM
}

func _ready():
	# Obtener nodos
	player = get_node_or_null("MazeArea/Player")
	maze_tilemap = get_node_or_null("MazeArea/MazeTilemap")
	goal = get_node_or_null("MazeArea/Goal")
	items_container = get_node_or_null("MazeArea/ItemsContainer")
	timer_label = get_node_or_null("UI/TopBar/TimerLabel")
	items_label = get_node_or_null("UI/TopBar/ItemsLabel")

	apply_ui_assets()
	
	setup_game()
	start_time = Time.get_ticks_msec() / 1000.0
		VoiceInstructions.play_instruction("maze_game")
	func apply_ui_assets():
		# Fondo
		var bg_path = "res://assets/backgrounds/panel_grid_paper.png"
		var background_node = get_node_or_null("Background")
		if background_node and ResourceLoader.exists(bg_path):
			var tex := load(bg_path)
			var tex_rect := TextureRect.new()
			tex_rect.texture = tex
			tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
			tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			add_child(tex_rect)
			background_node.queue_free()

		# Botón atrás
		var back_button = get_node_or_null("UI/TopBar/BackButton")
		if back_button:
			var normal_tex_path = "res://assets/images/ui/button_grey.png"
			var pressed_tex_path = "res://assets/images/ui/button_red_close.png"
			if ResourceLoader.exists(normal_tex_path):
				var sb_normal := StyleBoxTexture.new()
				sb_normal.texture = load(normal_tex_path)
				back_button.add_theme_stylebox_override("normal", sb_normal)
				var sb_hover := sb_normal.duplicate()
				back_button.add_theme_stylebox_override("hover", sb_hover)
				if ResourceLoader.exists(pressed_tex_path):
					var sb_pressed := StyleBoxTexture.new()
					sb_pressed.texture = load(pressed_tex_path)
					back_button.add_theme_stylebox_override("pressed", sb_pressed)
	set_process(true)

func _process(delta):
	# Actualizar timer
	if timer_label:
		var elapsed = (Time.get_ticks_msec() / 1000.0) - start_time
		timer_label.text = "⏱ %02d:%02d" % [int(elapsed / 60), int(elapsed) % 60]
	
	# Mover jugador si está arrastrando
	if is_dragging and player:
		var direction = (last_touch_position - player.global_position).normalized()
		var new_position = player.global_position + direction * player_speed * delta
		
		# Verificar colisión con paredes
		if not check_wall_collision(new_position):
			player.global_position = new_position

func setup_game():
	# Generar laberinto
	generate_maze()
	
	# Colocar jugador en inicio
	place_player_at_start()
	
	# Colocar objetivo
	place_goal()
	
	# Colocar items coleccionables
	place_collectible_items()
	
	update_items_label()

func generate_maze():
	maze_data.clear()
	
	# Inicializar con paredes
	for y in maze_size.y:
		var row: Array = []
		for x in maze_size.x:
			row.append(CellType.WALL)
		maze_data.append(row)
	
	# Generar caminos usando algoritmo simple (DFS)
	var start_pos = Vector2i(1, 1)
	maze_data[start_pos.y][start_pos.x] = CellType.START
	
	carve_maze(start_pos)
	
	# Asegurar que hay un camino al objetivo
	var goal_pos = Vector2i(maze_size.x - 2, maze_size.y - 2)
	maze_data[goal_pos.y][goal_pos.x] = CellType.GOAL
	
	# Renderizar laberinto visualmente
	render_maze()

func carve_maze(pos: Vector2i):
	var directions = [
		Vector2i(0, -2),  # Arriba
		Vector2i(2, 0),   # Derecha
		Vector2i(0, 2),   # Abajo
		Vector2i(-2, 0)   # Izquierda
	]
	directions.shuffle()
	
	for dir in directions:
		var new_pos = pos + dir
		var between_pos = pos + dir / 2
		
		# Verificar límites
		if new_pos.x > 0 and new_pos.x < maze_size.x - 1 and \
		   new_pos.y > 0 and new_pos.y < maze_size.y - 1:
			
			# Si la celda no ha sido visitada
			if maze_data[new_pos.y][new_pos.x] == CellType.WALL:
				maze_data[between_pos.y][between_pos.x] = CellType.EMPTY
				maze_data[new_pos.y][new_pos.x] = CellType.EMPTY
				carve_maze(new_pos)

func render_maze():
	if not maze_tilemap:
		# Crear representación visual simple sin TileMap
		create_simple_maze_visuals()
		return
	
	# Si hay TileMap, usarlo
	# TODO: Implementar con TileMap en la escena

func create_simple_maze_visuals():
	# Crear paredes como ColorRect
	for y in maze_size.y:
		for x in maze_size.x:
			if maze_data[y][x] == CellType.WALL:
				var wall = ColorRect.new()
				wall.color = Color(0.3, 0.3, 0.3, 1)
				wall.size = Vector2(cell_size, cell_size)
				wall.position = Vector2(x * cell_size, y * cell_size)
				add_child(wall)

func place_player_at_start():
	if not player:
		player = create_player()
		add_child(player)
	
	# Buscar posición de inicio
	for y in maze_size.y:
		for x in maze_size.x:
			if maze_data[y][x] == CellType.START:
				player.global_position = Vector2(x * cell_size + cell_size / 2, y * cell_size + cell_size / 2)
				return

func create_player() -> Area2D:
	var player_node = Area2D.new()
	player_node.name = "Player"
	
	# Sprite del jugador (círculo simple)
	var sprite = ColorRect.new()
	sprite.color = GameManager.COLOR_PRIMARY_BLUE
	sprite.size = Vector2(cell_size * 0.6, cell_size * 0.6)
	sprite.position = -sprite.size / 2
	player_node.add_child(sprite)
	
	# Colisión
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = cell_size * 0.3
	collision.shape = shape
	player_node.add_child(collision)
	
	# Conectar señales para items
	player_node.area_entered.connect(_on_player_area_entered)
	
	return player_node

func place_goal():
	if not goal:
		goal = Area2D.new()
		goal.name = "Goal"
		add_child(goal)
	
	# Buscar posición objetivo
	for y in maze_size.y:
		for x in maze_size.x:
			if maze_data[y][x] == CellType.GOAL:
				goal.global_position = Vector2(x * cell_size + cell_size / 2, y * cell_size + cell_size / 2)
				break
	
	# Visual del objetivo
	var sprite = ColorRect.new()
	sprite.color = GameManager.COLOR_SUCCESS
	sprite.size = Vector2(cell_size * 0.7, cell_size * 0.7)
	sprite.position = -sprite.size / 2
	goal.add_child(sprite)
	
	# Añadir estrella o ícono
	var label = Label.new()
	label.text = "⭐"
	label.add_theme_font_size_override("font_size", 48)
	label.position = -Vector2(24, 24)
	goal.add_child(label)
	
	# Animación de pulso
	AnimationHelper.pulse_loop(goal, 1.2, 1.5)
	
	# Colisión
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = cell_size * 0.35
	collision.shape = shape
	goal.add_child(collision)
	
	goal.area_entered.connect(_on_goal_reached)

func place_collectible_items():
	# Colocar items en posiciones vacías aleatorias
	var empty_positions: Array[Vector2i] = []
	
	for y in maze_size.y:
		for x in maze_size.x:
			if maze_data[y][x] == CellType.EMPTY:
				empty_positions.append(Vector2i(x, y))
	
	empty_positions.shuffle()
	
	for i in mini(total_items, empty_positions.size()):
		var pos = empty_positions[i]
		create_collectible_item(Vector2(pos.x * cell_size + cell_size / 2, pos.y * cell_size + cell_size / 2))

func create_collectible_item(position: Vector2):
	var item = Area2D.new()
	item.global_position = position
	item.add_to_group("collectibles")
	
	# Visual del item
	var sprite = ColorRect.new()
	sprite.color = GameManager.COLOR_PRIMARY_YELLOW
	sprite.size = Vector2(cell_size * 0.4, cell_size * 0.4)
	sprite.position = -sprite.size / 2
	item.add_child(sprite)
	
	# Icono
	var label = Label.new()
	label.text = "💎"
	label.add_theme_font_size_override("font_size", 32)
	label.position = -Vector2(16, 16)
	item.add_child(label)
	
	# Colisión
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = cell_size * 0.2
	collision.shape = shape
	item.add_child(collision)
	
	# Animación de rotación
	AnimationHelper.rotate_loop(item, 2.0)
	
	items_container.add_child(item)

func _input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			is_dragging = true
			last_touch_position = event.position
		else:
			is_dragging = false
	
	elif event is InputEventScreenDrag or event is InputEventMouseMotion:
		if is_dragging:
			last_touch_position = event.position

func check_wall_collision(pos: Vector2) -> bool:
	# Convertir posición a celda del laberinto
	var grid_x = int(pos.x / cell_size)
	var grid_y = int(pos.y / cell_size)
	
	# Verificar límites
	if grid_x < 0 or grid_x >= maze_size.x or grid_y < 0 or grid_y >= maze_size.y:
		return true
	
	# Verificar si es pared
	return maze_data[grid_y][grid_x] == CellType.WALL

func _on_player_area_entered(area: Area2D):
	if area.is_in_group("collectibles"):
		collect_item(area)

func collect_item(item: Area2D):
	collected_items += 1
	
	# Efectos
	AnimationHelper.create_sparkle_effect(self, item.global_position, 15)
	AudioManager.play_success()
	
	# Eliminar item
	item.queue_free()
	
	update_items_label()
	
	# Feedback
	if collected_items == total_items:
			VoiceInstructions.play_feedback(true, false)

func _on_goal_reached(area: Area2D):
	if area == player:
		complete_maze()

func complete_maze():
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - start_time
	var stars = calculate_stars(elapsed_time, collected_items)
	
	celebrate_completion()
	GameManager.complete_game("MazeGame", stars, elapsed_time)
	game_completed.emit(stars, elapsed_time)

func calculate_stars(time: float, items: int) -> int:
	var expected_time = 30.0 + (maze_size.x * maze_size.y * 0.5)
	
	if items == total_items and time < expected_time * 0.7:
		return 3
	elif items >= total_items * 0.66 and time < expected_time:
		return 2
	else:
		return 1

func celebrate_completion():
	AnimationHelper.create_confetti_at_position(self, player.global_position, 60)
	AudioManager.play_game_complete()
	VoiceInstructions.play_feedback(true)
	
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(400)

func update_items_label():
	if items_label:
		items_label.text = "💎 %d / %d" % [collected_items, total_items]

func play_wall_collision_feedback():
	AudioManager.play_error()
	if player:
		AnimationHelper.shake_node(player, 5.0, 0.2)

func change_difficulty(new_difficulty: int):
	difficulty = clampi(new_difficulty, 1, 5)
	maze_size = Vector2i(5 + difficulty * 2, 5 + difficulty * 2)
	reset_maze()

func reset_maze():
	collected_items = 0
	start_time = Time.get_ticks_msec() / 1000.0
	setup_game()
