# PuzzleGame.gd
# Juego de rompecabezas con imágenes divididas
extends Node2D

signal game_completed(stars: int, time: float)

@export var image_texture: Texture2D
@export var grid_size: Vector2i = Vector2i(3, 3)  # 3x3 = 9 piezas
@export var snap_threshold: float = 50.0

# Nodos
var puzzle_board
var pieces_area
var preview_button
var preview_panel
var progress_label

# Variables
var pieces: Array = []
var solved_pieces: int = 0
var total_pieces: int = 0
var start_time: float = 0.0
var piece_size: Vector2

# Categorías de imágenes
var image_categories = {
	"animals": [
		"res://assets/images/animals/dog.png",
		"res://assets/images/animals/cat.png",
		"res://assets/images/animals/lion.png"
	],
	"vehicles": [
		"res://assets/images/vehicles/car.png",
		"res://assets/images/vehicles/plane.png"
	],
	"nature": [
		"res://assets/images/nature/tree.png",
		"res://assets/images/nature/flower.png"
	]
}

func _ready():
	# Obtener nodos
	puzzle_board = get_node_or_null("PuzzleArea/Board")
	pieces_area = get_node_or_null("PuzzleArea/PiecesArea")
	preview_button = get_node_or_null("UI/TopBar/PreviewButton")
	preview_panel = get_node_or_null("PreviewPanel")
	progress_label = get_node_or_null("UI/TopBar/ProgressLabel")

	apply_ui_assets()
	
	setup_game()
	start_time = Time.get_ticks_msec() / 1000.0
	
	# Reproducir instrucción
		VoiceInstructions.play_instruction("puzzle_game")

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

func setup_game():
	total_pieces = grid_size.x * grid_size.y
	
	# Si no hay textura, usar placeholder
	if not image_texture:
		image_texture = create_placeholder_texture()
	
	# Calcular tamaño de pieza
	var board_size = puzzle_board.size if puzzle_board else Vector2(600, 600)
	piece_size = board_size / Vector2(grid_size)
	
	# Generar piezas
	generate_puzzle_pieces()
	
	# Actualizar progreso
	update_progress_label()

func create_placeholder_texture() -> Texture2D:
	# Crear textura simple para pruebas
	var img = Image.create(512, 512, false, Image.FORMAT_RGB8)
	img.fill(Color.CORNFLOWER_BLUE)
	return ImageTexture.create_from_image(img)

func generate_puzzle_pieces():
	# Limpiar piezas existentes
	for child in pieces_area.get_children():
		child.queue_free()
	pieces.clear()
	
	# Calcular tamaño de la textura
	var texture_size = image_texture.get_size()
	var piece_texture_size = texture_size / Vector2(grid_size)
	
	# Crear cada pieza
	for y in grid_size.y:
		for x in grid_size.x:
			var piece = create_puzzle_piece(x, y, piece_texture_size)
			pieces.append(piece)

func create_puzzle_piece(grid_x: int, grid_y: int, piece_tex_size: Vector2) -> Area2D:
	# Crear nodo de pieza
	var piece = Area2D.new()
	piece.name = "Piece_%d_%d" % [grid_x, grid_y]
	
	# Cargar script de DraggableObject
	piece.set_script(load("res://scripts/components/DraggableObject.gd"))
	
	# Configurar propiedades
	piece.return_to_original_position = false
	piece.snap_to_target = true
	piece.snap_threshold = snap_threshold
	
	# Crear sprite con región de la textura
	var sprite = Sprite2D.new()
	sprite.texture = image_texture
	sprite.region_enabled = true
	sprite.region_rect = Rect2(
		grid_x * piece_tex_size.x,
		grid_y * piece_tex_size.y,
		piece_tex_size.x,
		piece_tex_size.y
	)
	sprite.centered = true
	piece.add_child(sprite)
	
	# Crear collision shape
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = piece_size
	collision.shape = shape
	piece.add_child(collision)
	
	# Guardar posición correcta
	var correct_position = puzzle_board.global_position + Vector2(grid_x * piece_size.x, grid_y * piece_size.y) + piece_size / 2
	piece.set_meta("correct_position", correct_position)
	piece.set_meta("grid_pos", Vector2i(grid_x, grid_y))
	piece.set_meta("is_placed", false)
	
	# Crear área objetivo en el tablero
	create_drop_target(correct_position, Vector2i(grid_x, grid_y))
	
	# Posición inicial aleatoria en área de piezas
	var random_pos = get_random_position_in_pieces_area()
	piece.global_position = random_pos
	
	# Conectar señales
	piece.dropped_on_target.connect(_on_piece_dropped.bind(piece))
	
	# Añadir al árbol
	pieces_area.add_child(piece)
	
	return piece

func create_drop_target(position: Vector2, grid_pos: Vector2i):
	var target = Area2D.new()
	target.name = "Target_%d_%d" % [grid_pos.x, grid_pos.y]
	target.global_position = position
	target.add_to_group("drop_targets")
	target.set_meta("grid_pos", grid_pos)
	
	# Collision shape
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = piece_size
	collision.shape = shape
	target.add_child(collision)
	
	# Visual de la ranura (opcional)
	var visual = ColorRect.new()
	visual.color = Color(0.3, 0.3, 0.3, 0.3)
	visual.size = piece_size
	visual.position = -piece_size / 2
	target.add_child(visual)
	
	puzzle_board.add_child(target)

func get_random_position_in_pieces_area() -> Vector2:
	if not pieces_area:
		return Vector2(100, 100)
	
	var area_rect = pieces_area.get_rect()
	var margin = 50
	
	return Vector2(
		randf_range(area_rect.position.x + margin, area_rect.end.x - margin),
		randf_range(area_rect.position.y + margin, area_rect.end.y - margin)
	)

func _on_piece_dropped(target: Node2D, piece: Area2D):
	# Verificar si es el objetivo correcto
	var piece_grid_pos = piece.get_meta("grid_pos")
	var target_grid_pos = target.get_meta("grid_pos")
	
	if piece_grid_pos == target_grid_pos:
		# ¡Posición correcta!
		piece.set_meta("is_placed", true)
		solved_pieces += 1
		
		# Efectos de éxito
		AnimationHelper.success_effect(piece)
		AnimationHelper.create_sparkle_effect(self, piece.global_position, 20)
		AudioManager.play_success()
		
		# Actualizar progreso
		update_progress_label()
		
		# Feedback periódico
		if solved_pieces % 3 == 0 and solved_pieces < total_pieces:
				VoiceInstructions.play_feedback(true, false)
		
		# Verificar si completó
		if solved_pieces >= total_pieces:
			await get_tree().create_timer(0.5).timeout
			complete_puzzle()
	else:
		# Posición incorrecta
		AudioManager.play_error()

func complete_puzzle():
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - start_time
	
	# Calcular estrellas según tiempo
	var stars = calculate_stars(elapsed_time)
	
	# Celebración
	celebrate_completion()
	
	# Registrar progreso
	GameManager.complete_game("PuzzleGame", stars, elapsed_time)
	
	game_completed.emit(stars, elapsed_time)

func calculate_stars(time: float) -> int:
	var expected_time_per_piece = 15.0  # 15 segundos por pieza
	var expected_time = total_pieces * expected_time_per_piece
	
	if time < expected_time * 0.5:
		return 3
	elif time < expected_time:
		return 2
	else:
		return 1

func celebrate_completion():
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 100)
	AudioManager.play_game_complete()
	VoiceInstructions.play_feedback(true)
	
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(400)

func update_progress_label():
	if progress_label:
		progress_label.text = "Piezas: %d / %d" % [solved_pieces, total_pieces]

func _on_preview_button_pressed():
	if preview_panel:
		preview_panel.visible = not preview_panel.visible
		
		# Mostrar imagen completa
		if preview_panel.visible:
			var preview_texture_rect = preview_panel.get_node_or_null("TextureRect")
			if preview_texture_rect:
				preview_texture_rect.texture = image_texture

func change_difficulty(new_grid_size: Vector2i):
	grid_size = new_grid_size
	reset_puzzle()

func change_image(new_texture: Texture2D):
	image_texture = new_texture
	reset_puzzle()

func reset_puzzle():
	solved_pieces = 0
	start_time = Time.get_ticks_msec() / 1000.0
	setup_game()
