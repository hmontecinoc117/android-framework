## Juego de rompecabezas con imágenes divididas.
## Piezas arrastrables que se colocan en un tablero con snap automático.

extends Node2D

# ──────────────────────────────────────────────
#  Señales
# ──────────────────────────────────────────────

signal game_completed(stars: int, time: float)

# ──────────────────────────────────────────────
#  Constantes
# ──────────────────────────────────────────────

const LOGP := "[PuzzleGame] "

# ──────────────────────────────────────────────
#  Variables Exportadas
# ──────────────────────────────────────────────

@export var image_texture: Texture2D
@export var grid_size: Vector2i = Vector2i(3, 3)  # 3x3 = 9 piezas
@export var snap_threshold: float = 100.0  # Aumentado de 50 para móviles

# ──────────────────────────────────────────────
#  Variables Miembro — Nodos
# ──────────────────────────────────────────────

var puzzle_board: Node = null
var pieces_area: Node = null
var preview_button: Button = null
var preview_panel: Control = null
var preview_thumbnail: TextureRect = null  # Preview siempre visible
var progress_label: Label = null
var back_button: Button = null

# ──────────────────────────────────────────────
#  Variables Miembro — Estado
# ──────────────────────────────────────────────

var pieces: Array = []
var solved_pieces: int = 0
var total_pieces: int = 0
var start_time: float = 0.0
var piece_size: Vector2 = Vector2.ZERO

# ──────────────────────────────────────────────
#  Variables Miembro — Datos
# ──────────────────────────────────────────────

var image_categories: Dictionary = {
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

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	puzzle_board = get_node_or_null("PuzzleArea/Board")
	pieces_area = get_node_or_null("PuzzleArea/PiecesArea")
	preview_button = get_node_or_null("UI/TopBar/PreviewButton")
	preview_panel = get_node_or_null("PreviewPanel")
	progress_label = get_node_or_null("UI/TopBar/ProgressLabel")
	back_button = get_node_or_null("UI/TopBar/BackButton")

	_apply_ui_assets()
	_create_preview_thumbnail()  # Preview siempre visible
	_setup_game()
	start_time = Time.get_ticks_msec() / 1000.0

	VoiceInstructions.play_instruction("puzzle_game")
	print(LOGP, "_ready completado")

# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func change_difficulty(new_grid_size: Vector2i) -> void:
	grid_size = new_grid_size
	reset_puzzle()

func change_image(new_texture: Texture2D) -> void:
	image_texture = new_texture
	reset_puzzle()

func reset_puzzle() -> void:
	solved_pieces = 0
	start_time = Time.get_ticks_msec() / 1000.0
	_setup_game()

# ──────────────────────────────────────────────
#  Funciones Privadas — Setup
# ──────────────────────────────────────────────

func _apply_ui_assets() -> void:
	# Fondo
	var bg_path: String = "res://assets/backgrounds/panel_grid_paper.png"
	var background_node: Node = get_node_or_null("Background")
	if not background_node:
		background_node = ColorRect.new()
		background_node.name = "Background"
		background_node.color = DesignSystem.get_color("background")
		background_node.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(background_node)
		move_child(background_node, 0)
	
	if background_node and ResourceLoader.exists(bg_path):
		var tex := load(bg_path)
		if background_node is ColorRect:
			var tex_rect := TextureRect.new()
			tex_rect.texture = tex
			tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
			tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			add_child(tex_rect)
			move_child(tex_rect, 0)
			background_node.queue_free()

	# Botón atrás con DesignSystem
	if not back_button:
		back_button = get_node_or_null("UI/TopBar/BackButton")
	
	if back_button:
		back_button.text = "🏠"
		back_button.custom_minimum_size = DesignSystem.BTN_MEDIUM
		back_button.add_theme_font_size_override("font_size", DesignSystem.FONT_LARGE)
		DesignSystem.apply_button_style(back_button, "error")
		if not back_button.is_connected("pressed", _on_back_pressed):
			back_button.pressed.connect(_on_back_pressed)
	
	# Estilo de progress label
	if progress_label:
		DesignSystem.setup_label(progress_label, DesignSystem.FONT_MEDIUM, Color.WHITE)


func _on_back_pressed() -> void:
	AudioManager.play_back()
	var bootstrap: Node = get_node_or_null("/root/UiBootstrap")
	if bootstrap and bootstrap.has_method("fade_to_scene"):
		bootstrap.fade_to_scene("res://scenes/main/GameSelector.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main/GameSelector.tscn")

func _create_preview_thumbnail() -> void:
	"""Crea un thumbnail siempre visible en la esquina superior derecha"""
	if preview_thumbnail:
		return  # Ya existe
	
	# Crear container para el preview
	var preview_container := PanelContainer.new()
	preview_container.name = "PreviewContainer"
	
	# Posicionar en esquina superior derecha
	preview_container.anchor_left = 1.0
	preview_container.anchor_top = 0.0
	preview_container.anchor_right = 1.0
	preview_container.anchor_bottom = 0.0
	preview_container.offset_left = -220.0
	preview_container.offset_top = 20.0
	preview_container.offset_right = -20.0
	preview_container.offset_bottom = 220.0
	preview_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Estilo del panel
	var panel_style := DesignSystem.create_panel_style(Color(1, 1, 1, 0.9))
	preview_container.add_theme_stylebox_override("panel", panel_style)
	
	# TextureRect para mostrar la imagen
	preview_thumbnail = TextureRect.new()
	preview_thumbnail.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview_thumbnail.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_thumbnail.custom_minimum_size = Vector2(180, 180)
	preview_container.add_child(preview_thumbnail)
	
	add_child(preview_container)
	
	# Actualizar textura si ya existe
	if image_texture:
		preview_thumbnail.texture = image_texture


func _setup_game() -> void:
	total_pieces = grid_size.x * grid_size.y

	# Si no hay textura, usar placeholder
	if not image_texture:
		image_texture = _create_placeholder_texture()
	
	# Actualizar preview thumbnail
	if preview_thumbnail:
		preview_thumbnail.texture = image_texture

	# Calcular tamaño de pieza
	var board_size: Vector2 = puzzle_board.size if puzzle_board else Vector2(600, 600)
	piece_size = board_size / Vector2(grid_size)

	# Generar piezas
	_generate_puzzle_pieces()

	# Actualizar progreso
	_update_progress_label()

func _create_placeholder_texture() -> Texture2D:
	# Crear textura simple para pruebas
	var img: Image = Image.create(512, 512, false, Image.FORMAT_RGB8)
	img.fill(Color.CORNFLOWER_BLUE)
	return ImageTexture.create_from_image(img)

# ──────────────────────────────────────────────
#  Funciones Privadas — Piezas
# ──────────────────────────────────────────────

func _generate_puzzle_pieces() -> void:
	# Limpiar piezas existentes
	for child in pieces_area.get_children():
		child.queue_free()
	pieces.clear()

	# Calcular tamaño de la textura
	var texture_size: Vector2 = image_texture.get_size()
	var piece_texture_size: Vector2 = texture_size / Vector2(grid_size)

	# Crear cada pieza
	for y in grid_size.y:
		for x in grid_size.x:
			var piece: Area2D = _create_puzzle_piece(x, y, piece_texture_size)
			pieces.append(piece)

func _create_puzzle_piece(grid_x: int, grid_y: int, piece_tex_size: Vector2) -> Area2D:
	# Crear nodo de pieza
	var piece: Area2D = Area2D.new()
	piece.name = "Piece_%d_%d" % [grid_x, grid_y]

	# Cargar script de DraggableObject
	piece.set_script(load("res://scripts/components/DraggableObject.gd"))

	# Configurar propiedades
	piece.return_to_original_position = false
	piece.snap_to_target = true
	piece.snap_threshold = snap_threshold

	# Crear sprite con región de la textura
	var sprite: Sprite2D = Sprite2D.new()
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
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = piece_size
	collision.shape = shape
	piece.add_child(collision)

	# Guardar posición correcta
	var correct_position: Vector2 = puzzle_board.global_position + Vector2(grid_x * piece_size.x, grid_y * piece_size.y) + piece_size / 2
	piece.set_meta("correct_position", correct_position)
	piece.set_meta("grid_pos", Vector2i(grid_x, grid_y))
	piece.set_meta("is_placed", false)

	# Crear área objetivo en el tablero
	_create_drop_target(correct_position, Vector2i(grid_x, grid_y))

	# Posición inicial aleatoria en área de piezas
	var random_pos: Vector2 = _get_random_position_in_pieces_area()
	piece.global_position = random_pos

	# Conectar señales
	piece.dropped_on_target.connect(_on_piece_dropped.bind(piece))

	# Añadir al árbol
	pieces_area.add_child(piece)

	return piece

func _create_drop_target(position: Vector2, grid_pos: Vector2i) -> void:
	var target: Area2D = Area2D.new()
	target.name = "Target_%d_%d" % [grid_pos.x, grid_pos.y]
	target.global_position = position
	target.add_to_group("drop_targets")
	target.set_meta("grid_pos", grid_pos)

	# Collision shape
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = piece_size
	collision.shape = shape
	target.add_child(collision)

	# Visual de la ranura (opcional)
	var visual: ColorRect = ColorRect.new()
	visual.color = Color(0.3, 0.3, 0.3, 0.3)
	visual.size = piece_size
	visual.position = -piece_size / 2
	target.add_child(visual)

	puzzle_board.add_child(target)

func _get_random_position_in_pieces_area() -> Vector2:
	if not pieces_area:
		return Vector2(100, 100)

	var area_rect: Rect2 = pieces_area.get_rect()
	var margin: float = 50.0

	return Vector2(
		randf_range(area_rect.position.x + margin, area_rect.end.x - margin),
		randf_range(area_rect.position.y + margin, area_rect.end.y - margin)
	)

# ──────────────────────────────────────────────
#  Funciones Privadas — Lógica de juego
# ──────────────────────────────────────────────

func _on_piece_dropped(target: Node2D, piece: Area2D) -> void:
	# Verificar si es el objetivo correcto
	var piece_grid_pos: Vector2i = piece.get_meta("grid_pos")
	var target_grid_pos: Vector2i = target.get_meta("grid_pos")

	if piece_grid_pos == target_grid_pos:
		# Posición correcta
		piece.set_meta("is_placed", true)
		solved_pieces += 1

		# Efectos de éxito
		AnimationHelper.success_effect(piece)
		AnimationHelper.create_sparkle_effect(self, piece.global_position, 20)
		AudioManager.play_success()

		# Actualizar progreso
		_update_progress_label()

		# Feedback periódico
		if solved_pieces % 3 == 0 and solved_pieces < total_pieces:
			VoiceInstructions.play_feedback(true, false)

		# Verificar si completó
		if solved_pieces >= total_pieces:
			await get_tree().create_timer(0.5).timeout
			_complete_puzzle()
	else:
		# Posición incorrecta
		AudioManager.play_error()

func _complete_puzzle() -> void:
	var elapsed_time: float = (Time.get_ticks_msec() / 1000.0) - start_time

	# Calcular estrellas según tiempo
	var stars: int = _calculate_stars(elapsed_time)

	# Celebración
	_celebrate_completion()

	# Registrar progreso
	GameManager.complete_game("PuzzleGame", stars, elapsed_time)

	print(LOGP, "Puzzle completado: estrellas=", stars, " tiempo=", elapsed_time)
	game_completed.emit(stars, elapsed_time)

func _calculate_stars(time: float) -> int:
	var expected_time_per_piece: float = 15.0  # 15 segundos por pieza
	var expected_time: float = total_pieces * expected_time_per_piece

	if time < expected_time * 0.5:
		return 3
	elif time < expected_time:
		return 2
	else:
		return 1

func _celebrate_completion() -> void:
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 100)
	AudioManager.play_game_complete()
	VoiceInstructions.play_feedback(true)

	if OS.has_feature("mobile"):
		Input.vibrate_handheld(400)

func _update_progress_label() -> void:
	if progress_label:
		progress_label.text = "Piezas: %d / %d" % [solved_pieces, total_pieces]

# ──────────────────────────────────────────────
#  Callbacks de UI
# ──────────────────────────────────────────────

func _on_preview_button_pressed() -> void:
	if preview_panel:
		preview_panel.visible = not preview_panel.visible

		# Mostrar imagen completa
		if preview_panel.visible:
			var preview_texture_rect: TextureRect = preview_panel.get_node_or_null("TextureRect")
			if preview_texture_rect:
				preview_texture_rect.texture = image_texture
