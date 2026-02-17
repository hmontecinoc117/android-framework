## Juego de laberinto con personaje guiado por el dedo.
## El jugador navega por un laberinto generado proceduralmente,
## recolectando items y buscando la meta.
extends Node2D

# --- Señales ---
signal game_completed(stars: int, time: float)

# --- Enums ---
enum CellType {
	EMPTY,
	WALL,
	START,
	GOAL,
	ITEM
}

# --- Constantes ---
const LOGP := "[MazeGame] "

# --- Variables Exportadas ---
@export var maze_size: Vector2i = Vector2i(7, 7)  # Tamaño del laberinto
@export var difficulty: int = 1  # 1-5

# --- Nodos ---
var player: Node2D = null
var maze_tilemap: Node = null
var goal: Node2D = null
var items_container: Node = null
var timer_label: Label = null
var items_label: Label = null

# --- Estado del juego ---
var is_dragging: bool = false
var last_touch_position: Vector2 = Vector2.ZERO
var collected_items: int = 0
var total_items: int = 3
var start_time: float = 0.0
var maze_data: Array[Array] = []
var cell_size: float = 80.0
var player_speed: float = 200.0


# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	# Obtener nodos
	player = get_node_or_null("MazeArea/Player")
	maze_tilemap = get_node_or_null("MazeArea/MazeTilemap")
	goal = get_node_or_null("MazeArea/Goal")
	items_container = get_node_or_null("MazeArea/ItemsContainer")
	timer_label = get_node_or_null("UI/TopBar/TimerLabel")
	items_label = get_node_or_null("UI/TopBar/ItemsLabel")
	_apply_ui_assets()
	_setup_game()
	start_time = Time.get_ticks_msec() / 1000.0
	VoiceInstructions.play_instruction("maze_game")
	set_process(true)

func _process(delta: float) -> void:
	# Actualizar timer
	if timer_label:
		var elapsed: float = (Time.get_ticks_msec() / 1000.0) - start_time
		timer_label.text = "⏱ %02d:%02d" % [int(elapsed / 60), int(elapsed) % 60]
	# Mover jugador si está arrastrando
	if is_dragging and player:
		var direction: Vector2 = (last_touch_position - player.global_position).normalized()
		var new_position: Vector2 = player.global_position + direction * player_speed * delta
		# Verificar colisión con paredes
		if not _check_wall_collision(new_position):
			player.global_position = new_position

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			is_dragging = true
			last_touch_position = event.position
		else:
			is_dragging = false
	elif event is InputEventScreenDrag or event is InputEventMouseMotion:
		if is_dragging:
			last_touch_position = event.position


# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func change_difficulty(new_difficulty: int) -> void:
	difficulty = clampi(new_difficulty, 1, 5)
	maze_size = Vector2i(5 + difficulty * 2, 5 + difficulty * 2)
	reset_maze()

func reset_maze() -> void:
	collected_items = 0
	start_time = Time.get_ticks_msec() / 1000.0
	_setup_game()


# ──────────────────────────────────────────────
#  Funciones Privadas — Setup
# ──────────────────────────────────────────────

func _apply_ui_assets() -> void:
	# Fondo
	var bg_path: String = "res://assets/backgrounds/panel_grid_paper.png"
	var background_node: Node = get_node_or_null("Background")
	if background_node and ResourceLoader.exists(bg_path):
		var tex := load(bg_path)
		var tex_rect := TextureRect.new()
		tex_rect.texture = tex
		tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
		tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(tex_rect)
		background_node.queue_free()
	# Botón atrás
	var back_button: Control = get_node_or_null("UI/TopBar/BackButton")
	if back_button:
		DesignSystem.apply_button_style(back_button, "error")
		back_button.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	AudioManager.play_back()
	var bootstrap: Node = get_node_or_null("/root/UiBootstrap")
	if bootstrap and bootstrap.has_method("fade_to_scene"):
		bootstrap.fade_to_scene("res://scenes/main/GameSelector.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main/GameSelector.tscn")


func _setup_game() -> void:
	# Generar laberinto
	_generate_maze()
	# Colocar jugador en inicio
	_place_player_at_start()
	# Colocar objetivo
	_place_goal()
	# Colocar items coleccionables
	_place_collectible_items()
	_update_items_label()


# ──────────────────────────────────────────────
#  Funciones Privadas — Generación de Laberinto
# ──────────────────────────────────────────────

func _generate_maze() -> void:
	maze_data.clear()
	# Inicializar con paredes
	for y in maze_size.y:
		var row: Array = []
		for x in maze_size.x:
			row.append(CellType.WALL)
		maze_data.append(row)
	# Generar caminos usando algoritmo simple (DFS)
	var start_pos: Vector2i = Vector2i(1, 1)
	maze_data[start_pos.y][start_pos.x] = CellType.START
	_carve_maze(start_pos)
	# Asegurar que hay un camino al objetivo
	var goal_pos: Vector2i = Vector2i(maze_size.x - 2, maze_size.y - 2)
	maze_data[goal_pos.y][goal_pos.x] = CellType.GOAL
	# Renderizar laberinto visualmente
	_render_maze()

func _carve_maze(pos: Vector2i) -> void:
	var directions: Array[Vector2i] = [
		Vector2i(0, -2),  # Arriba
		Vector2i(2, 0),   # Derecha
		Vector2i(0, 2),   # Abajo
		Vector2i(-2, 0)   # Izquierda
	]
	directions.shuffle()
	for dir in directions:
		var new_pos: Vector2i = pos + dir
		var between_pos: Vector2i = pos + dir / 2
		# Verificar límites
		if new_pos.x > 0 and new_pos.x < maze_size.x - 1 and \
		   new_pos.y > 0 and new_pos.y < maze_size.y - 1:
			# Si la celda no ha sido visitada
			if maze_data[new_pos.y][new_pos.x] == CellType.WALL:
				maze_data[between_pos.y][between_pos.x] = CellType.EMPTY
				maze_data[new_pos.y][new_pos.x] = CellType.EMPTY
				_carve_maze(new_pos)

func _render_maze() -> void:
	if not maze_tilemap:
		# Crear representación visual simple sin TileMap
		_create_simple_maze_visuals()
		return
	# Si hay TileMap, usarlo
	# TODO: Implementar con TileMap en la escena

func _create_simple_maze_visuals() -> void:
	# Crear paredes como ColorRect
	for y in maze_size.y:
		for x in maze_size.x:
			if maze_data[y][x] == CellType.WALL:
				var wall := ColorRect.new()
				wall.color = Color(0.3, 0.3, 0.3, 1)
				wall.size = Vector2(cell_size, cell_size)
				wall.position = Vector2(x * cell_size, y * cell_size)
				add_child(wall)


# ──────────────────────────────────────────────
#  Funciones Privadas — Entidades
# ──────────────────────────────────────────────

func _place_player_at_start() -> void:
	if not player:
		player = _create_player()
		add_child(player)
	# Buscar posición de inicio
	for y in maze_size.y:
		for x in maze_size.x:
			if maze_data[y][x] == CellType.START:
				player.global_position = Vector2(x * cell_size + cell_size / 2, y * cell_size + cell_size / 2)
				return

func _create_player() -> Area2D:
	var player_node := Area2D.new()
	player_node.name = "Player"
	# Sprite del jugador (círculo simple)
	var sprite := ColorRect.new()
	sprite.color = DesignSystem.get_color("primary")
	sprite.size = Vector2(cell_size * 0.6, cell_size * 0.6)
	sprite.position = -sprite.size / 2
	player_node.add_child(sprite)
	# Colisión
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = cell_size * 0.3
	collision.shape = shape
	player_node.add_child(collision)
	# Conectar señales para items
	player_node.area_entered.connect(_on_player_area_entered)
	return player_node

func _place_goal() -> void:
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
	var sprite := ColorRect.new()
	sprite.color = DesignSystem.get_color("success")
	sprite.size = Vector2(cell_size * 0.7, cell_size * 0.7)
	sprite.position = -sprite.size / 2
	goal.add_child(sprite)
	# Añadir estrella o ícono
	var label := Label.new()
	label.text = "⭐"
	DesignSystem.setup_label(label, DesignSystem.FONT_LARGE, Color.WHITE)
	label.position = -Vector2(24, 24)
	goal.add_child(label)
	# Animación de pulso
	AnimationHelper.pulse_loop(goal, 1.2, 1.5)
	# Colisión
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = cell_size * 0.35
	collision.shape = shape
	goal.add_child(collision)
	goal.area_entered.connect(_on_goal_reached)

func _place_collectible_items() -> void:
	# Colocar items en posiciones vacías aleatorias
	var empty_positions: Array[Vector2i] = []
	for y in maze_size.y:
		for x in maze_size.x:
			if maze_data[y][x] == CellType.EMPTY:
				empty_positions.append(Vector2i(x, y))
	empty_positions.shuffle()
	for i in mini(total_items, empty_positions.size()):
		var pos: Vector2i = empty_positions[i]
		_create_collectible_item(Vector2(pos.x * cell_size + cell_size / 2, pos.y * cell_size + cell_size / 2))

func _create_collectible_item(item_position: Vector2) -> void:
	var item := Area2D.new()
	item.global_position = item_position
	item.add_to_group("collectibles")
	# Visual del item
	var sprite := ColorRect.new()
	sprite.color = DesignSystem.get_color("primary")
	sprite.size = Vector2(cell_size * 0.4, cell_size * 0.4)
	sprite.position = -sprite.size / 2
	item.add_child(sprite)
	# Icono
	var label := Label.new()
	label.text = "💎"
	DesignSystem.setup_label(label, DesignSystem.FONT_MEDIUM, Color.WHITE)
	label.position = -Vector2(16, 16)
	item.add_child(label)
	# Colisión
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = cell_size * 0.2
	collision.shape = shape
	item.add_child(collision)
	# Animación de rotación
	AnimationHelper.rotate_loop(item, 2.0)
	items_container.add_child(item)


# ──────────────────────────────────────────────
#  Funciones Privadas — Colisiones y Recolección
# ──────────────────────────────────────────────

func _check_wall_collision(pos: Vector2) -> bool:
	# Convertir posición a celda del laberinto
	var grid_x: int = int(pos.x / cell_size)
	var grid_y: int = int(pos.y / cell_size)
	# Verificar límites
	if grid_x < 0 or grid_x >= maze_size.x or grid_y < 0 or grid_y >= maze_size.y:
		return true
	# Verificar si es pared
	return maze_data[grid_y][grid_x] == CellType.WALL

func _on_player_area_entered(area: Area2D) -> void:
	if area.is_in_group("collectibles"):
		_collect_item(area)

func _collect_item(item: Area2D) -> void:
	collected_items += 1
	# Efectos
	AnimationHelper.create_sparkle_effect(self, item.global_position, 15)
	AudioManager.play_success()
	# Eliminar item
	item.queue_free()
	_update_items_label()
	# Feedback
	if collected_items == total_items:
		VoiceInstructions.play_feedback(true, false)

func _on_goal_reached(area: Area2D) -> void:
	if area == player:
		_complete_maze()


# ──────────────────────────────────────────────
#  Funciones Privadas — Finalización
# ──────────────────────────────────────────────

func _complete_maze() -> void:
	var elapsed_time: float = (Time.get_ticks_msec() / 1000.0) - start_time
	var stars: int = _calculate_stars(elapsed_time, collected_items)
	_celebrate_completion()
	GameManager.complete_game("MazeGame", stars, elapsed_time)
	game_completed.emit(stars, elapsed_time)

func _calculate_stars(time: float, items: int) -> int:
	var expected_time: float = 30.0 + (maze_size.x * maze_size.y * 0.5)
	if items == total_items and time < expected_time * 0.7:
		return 3
	elif items >= total_items * 0.66 and time < expected_time:
		return 2
	else:
		return 1

func _celebrate_completion() -> void:
	AnimationHelper.create_confetti_at_position(self, player.global_position, 60)
	AudioManager.play_game_complete()
	VoiceInstructions.play_feedback(true)
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(400)

func _update_items_label() -> void:
	if items_label:
		items_label.text = "💎 %d / %d" % [collected_items, total_items]

func _play_wall_collision_feedback() -> void:
	AudioManager.play_error()
	if player:
		AnimationHelper.shake_node(player, 5.0, 0.2)
