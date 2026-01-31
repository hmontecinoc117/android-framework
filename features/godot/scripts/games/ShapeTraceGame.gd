# ShapeTraceGame.gd
# Juego de trazado de formas geométricas
extends Node2D

signal game_completed(stars: int, time: float)

@export var shape_type: String = "circle"  # circle, square, triangle, star, heart, etc.
@export var trace_tolerance: float = 35.0
@export var success_threshold: float = 0.80
@export var mode: String = "word" # "word" para palabras, "shape" para formas

# Nodos
var trace_line
var guide_line
var progress_bar
var instruction_label
var shape_preview
var word_label
var top_controls
var btn_home
var btn_refresh
var btn_next

# Variables
var trace_points: Array[Vector2] = []
var user_points: Array[Vector2] = []
var current_progress: float = 0.0
var is_tracing: bool = false
var start_time: float = 0.0
var shape_closed: bool = false

# Palabras (animales, <= 6 letras)
var word_list: Array[String] = ["PERRO", "GATO", "OSO", "LORO", "RANA", "VACA", "PATO", "CEBRA"]
var current_word_index: int = 0
var word_bins: Array[bool] = []
var word_bins_count: int = 24

# Tipos de formas
enum ShapeType {
	CIRCLE,
	SQUARE,
	TRIANGLE,
	RECTANGLE,
	STAR,
	HEART,
	DIAMOND,
	HEXAGON,
	PENTAGON,
	OVAL
}

var shape_names: Dictionary = {
	ShapeType.CIRCLE: "Círculo",
	ShapeType.SQUARE: "Cuadrado",
	ShapeType.TRIANGLE: "Triángulo",
	ShapeType.RECTANGLE: "Rectángulo",
	ShapeType.STAR: "Estrella",
	ShapeType.HEART: "Corazón",
	ShapeType.DIAMOND: "Rombo",
	ShapeType.HEXAGON: "Hexágono",
	ShapeType.PENTAGON: "Pentágono",
	ShapeType.OVAL: "Óvalo"
}

var current_shape: ShapeType = ShapeType.CIRCLE
var current_level: int = 1

func _ready():
	# Obtener nodos
	trace_line = get_node_or_null("DrawingArea/UserLine")
	guide_line = get_node_or_null("DrawingArea/TargetLine")
	progress_bar = get_node_or_null("UI/TopBar/ProgressBar")
	# Usar etiqueta existente en escena si no hay InstructionLabel
	instruction_label = get_node_or_null("UI/InstructionLabel")
	if not instruction_label:
		instruction_label = get_node_or_null("UI/TopBar/ShapeLabel")
	shape_preview = get_node_or_null("UI/ShapePreview")

	apply_ui_assets()
	
	setup_game()
	start_time = Time.get_ticks_msec() / 1000.0
	VoiceInstructions.play_instruction("shape_trace_game")
	set_process_input(true)

func setup_game():
	if mode == "word":
		setup_word_mode()
	else:
		load_shape_template(current_shape)
		if guide_line:
			setup_visual_guide()
		if trace_line:
			trace_line.default_color = GameManager.COLOR_PRIMARY_GREEN
			trace_line.width = 12.0
			trace_line.clear_points()
		if instruction_label:
			instruction_label.text = "Dibuja un " + shape_names[current_shape]
		if progress_bar:
			progress_bar.value = 0

func setup_word_mode():
	ensure_top_controls()
	ensure_word_label()
	reset_word_tracing()
	if instruction_label:
		instruction_label.text = "Trazar palabra"
	if trace_line:
		trace_line.default_color = GameManager.COLOR_PRIMARY_GREEN
		trace_line.width = 18.0
		trace_line.clear_points()
	if progress_bar:
		progress_bar.value = 0

func apply_ui_assets():
	# Fondo con textura
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

	# Estilo del botón Atrás si existe
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
		back_button.custom_minimum_size = Vector2(260, 140)
		back_button.add_theme_font_size_override("font_size", 80)

func ensure_top_controls():
	if not top_controls:
		top_controls = HBoxContainer.new()
		top_controls.anchor_left = 0.0
		top_controls.anchor_top = 0.0
		top_controls.anchor_right = 1.0
		top_controls.anchor_bottom = 0.0
		top_controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top_controls.add_theme_constant_override("separation", 30)
		add_child(top_controls)

		btn_home = Button.new()
		btn_home.text = "🏠"
		btn_home.custom_minimum_size = Vector2(220, 160)
		btn_home.add_theme_font_size_override("font_size", 90)
		top_controls.add_child(btn_home)
		btn_home.pressed.connect(_on_home_pressed)

		btn_refresh = Button.new()
		btn_refresh.text = "⟲"
		btn_refresh.custom_minimum_size = Vector2(220, 160)
		btn_refresh.add_theme_font_size_override("font_size", 90)
		top_controls.add_child(btn_refresh)
		btn_refresh.pressed.connect(_on_refresh_pressed)

		btn_next = Button.new()
		btn_next.text = "→"
		btn_next.custom_minimum_size = Vector2(220, 160)
		btn_next.add_theme_font_size_override("font_size", 90)
		top_controls.add_child(btn_next)
		btn_next.pressed.connect(_on_next_pressed)

func ensure_word_label():
	if not word_label:
		word_label = Label.new()
		word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		word_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		word_label.add_theme_font_size_override("font_size", 220)
		word_label.add_theme_color_override("font_color", Color(1,1,1,0.35))
		word_label.anchor_left = 0.1
		word_label.anchor_right = 0.9
		word_label.anchor_top = 0.25
		word_label.anchor_bottom = 0.75
		add_child(word_label)

	set_word(word_list[current_word_index])

func set_word(w: String):
	if not word_label:
		return
	word_label.text = w
	reset_word_tracing()

func reset_word_tracing():
	user_points.clear()
	word_bins = []
	for i in word_bins_count:
		word_bins.append(false)
	if trace_line:
		trace_line.clear_points()
		trace_line.width = 18.0
	if progress_bar:
		progress_bar.value = 0

func load_shape_template(shape: ShapeType):
	trace_points = generate_shape_points(shape)

func generate_shape_points(shape: ShapeType) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var center = get_viewport_rect().size / 2
	var size = 250.0
	
	match shape:
		ShapeType.CIRCLE:
			# Círculo con 40 segmentos
			var segments = 40
			for i in segments + 1:
				var angle = (TAU / segments) * i
				points.append(center + Vector2(cos(angle), sin(angle)) * size)
		
		ShapeType.SQUARE:
			# Cuadrado
			var half = size
			points.append(center + Vector2(-half, -half))
			points.append(center + Vector2(half, -half))
			points.append(center + Vector2(half, half))
			points.append(center + Vector2(-half, half))
			points.append(center + Vector2(-half, -half))
		
		ShapeType.TRIANGLE:
			# Triángulo equilátero
			var height = size * 1.5
			points.append(center + Vector2(0, -height * 0.6))
			points.append(center + Vector2(size, height * 0.4))
			points.append(center + Vector2(-size, height * 0.4))
			points.append(center + Vector2(0, -height * 0.6))
		
		ShapeType.RECTANGLE:
			# Rectángulo
			var width = size * 1.3
			var height = size * 0.8
			points.append(center + Vector2(-width, -height))
			points.append(center + Vector2(width, -height))
			points.append(center + Vector2(width, height))
			points.append(center + Vector2(-width, height))
			points.append(center + Vector2(-width, -height))
		
		ShapeType.STAR:
			# Estrella de 5 puntas
			var outer = size
			var inner = size * 0.4
			for i in 11:
				var angle = (TAU / 10) * i - PI / 2
				var radius = outer if i % 2 == 0 else inner
				points.append(center + Vector2(cos(angle), sin(angle)) * radius)
		
		ShapeType.HEART:
			# Corazón (aproximación con curvas)
			var segments = 30
			for i in segments + 1:
				var t = float(i) / segments * TAU
				var x = 16 * pow(sin(t), 3)
				var y = -(13 * cos(t) - 5 * cos(2*t) - 2 * cos(3*t) - cos(4*t))
				points.append(center + Vector2(x, y) * size / 20)
		
		ShapeType.DIAMOND:
			# Rombo
			points.append(center + Vector2(0, -size))
			points.append(center + Vector2(size * 0.7, 0))
			points.append(center + Vector2(0, size))
			points.append(center + Vector2(-size * 0.7, 0))
			points.append(center + Vector2(0, -size))
		
		ShapeType.HEXAGON:
			# Hexágono
			for i in 7:
				var angle = (TAU / 6) * i - PI / 2
				points.append(center + Vector2(cos(angle), sin(angle)) * size)
		
		ShapeType.PENTAGON:
			# Pentágono
			for i in 6:
				var angle = (TAU / 5) * i - PI / 2
				points.append(center + Vector2(cos(angle), sin(angle)) * size)
		
		ShapeType.OVAL:
			# Óvalo (elipse)
			var segments = 40
			for i in segments + 1:
				var angle = (TAU / segments) * i
				points.append(center + Vector2(cos(angle) * size * 1.3, sin(angle) * size * 0.8))
	
	return points

func setup_visual_guide():
	guide_line.default_color = Color(0.5, 0.5, 0.5, 0.4)
	guide_line.width = 18.0
	guide_line.clear_points()
	
	for point in trace_points:
		guide_line.add_point(point)

func _input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			start_tracing(event.position)
		else:
			end_tracing()
	elif (event is InputEventScreenDrag or event is InputEventMouseMotion) and is_tracing:
		process_touch_input(event.position)

func start_tracing(position: Vector2):
	if trace_points.is_empty():
		# En modo palabra no dependemos de puntos guía
		if mode != "word":
			return
	
	var can_start = true
	var start_point: Vector2 = position
	if mode != "word" and not trace_points.is_empty():
		start_point = trace_points[0]
		var distance = position.distance_to(start_point)
		can_start = distance < trace_tolerance * 2
	
	if can_start:
		is_tracing = true
		shape_closed = false
		user_points.clear()
		user_points.append(position)
		
		if trace_line:
			trace_line.clear_points()
			trace_line.add_point(position)
		
		AudioManager.play_pickup()
	else:
		show_hint_animation(start_point)
		AudioManager.play_error()

func process_touch_input(position: Vector2):
	if not is_tracing:
		return
	
	user_points.append(position)
	
	if trace_line:
		trace_line.add_point(position)
	
	calculate_progress()
	
	if progress_bar:
		progress_bar.value = current_progress * 100
	
	# Verificar si cerró la forma
	check_shape_closure(position)
	
	if current_progress >= success_threshold and shape_closed:
		complete_trace()

func check_shape_closure(current_pos: Vector2):
	if user_points.size() < 10:
		return
	
	var start_point = trace_points[0]
	var distance = current_pos.distance_to(start_point)
	
	if distance < trace_tolerance * 1.5:
		shape_closed = true

func end_tracing():
	is_tracing = false

func calculate_progress() -> float:
	if mode == "word":
		current_progress = calculate_word_progress()
		return current_progress
	else:
		if trace_points.is_empty() or user_points.is_empty():
			return 0.0
		var matched_points = 0
		var total_points = trace_points.size()
		for guide_point in trace_points:
			for user_point in user_points:
				if guide_point.distance_to(user_point) < trace_tolerance:
					matched_points += 1
					break
		current_progress = float(matched_points) / float(total_points)
		return current_progress

func calculate_word_progress() -> float:
	if not word_label or user_points.is_empty():
		return 0.0
	var rect: Rect2 = word_label.get_global_rect().grow(40)
	if rect.size.x <= 0:
		return 0.0
	for p in user_points:
		if rect.has_point(p):
			var rel = (p.x - rect.position.x) / rect.size.x
			var idx = clamp(int(rel * word_bins_count), 0, word_bins_count - 1)
			word_bins[idx] = true
	var covered = 0
	for b in word_bins:
		if b:
			covered += 1
	return float(covered) / float(word_bins_count)

func complete_trace():
	is_tracing = false
	
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - start_time
	var stars = calculate_stars(current_progress, elapsed_time)
	
	celebrate_completion()
	show_completion_screen(stars, elapsed_time)
	
	GameManager.complete_game("ShapeTraceGame", stars, elapsed_time, current_level)
	if VoiceInstructions:
		VoiceInstructions.play_feedback(true)

func calculate_stars(accuracy: float, time: float) -> int:
	if accuracy >= 0.95 and time < 20.0:
		return 3
	elif accuracy >= 0.85 and time < 30.0:
		return 2
	elif accuracy >= success_threshold:
		return 1
	return 0

func celebrate_completion():
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 60)
	AudioManager.play_game_complete()
	VoiceInstructions.play_feedback(true)
	
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(200)

func show_completion_screen(_stars: int, _time: float):
	# TODO: Mostrar pantalla de completado
	pass

func show_hint_animation(position: Vector2):
	var hint_circle = ColorRect.new()
	hint_circle.color = Color.YELLOW
	hint_circle.size = Vector2(60, 60)
	hint_circle.position = position - hint_circle.size / 2
	add_child(hint_circle)
	
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(hint_circle, "scale", Vector2.ONE * 1.5, 0.5)
	tween.tween_property(hint_circle, "scale", Vector2.ONE, 0.5)
	
	await tween.finished
	hint_circle.queue_free()

func next_shape():
	if mode == "word":
		current_word_index = (current_word_index + 1) % word_list.size()
		set_word(word_list[current_word_index])
		reset_word_tracing()
		start_time = Time.get_ticks_msec() / 1000.0
	else:
		current_shape = (current_shape + 1) % ShapeType.size()
		setup_game()
		start_time = Time.get_ticks_msec() / 1000.0

func set_shape(shape: ShapeType):
	current_shape = shape
	setup_game()
	start_time = Time.get_ticks_msec() / 1000.0

func _on_home_pressed():
	# Usar cambio diferido para evitar errores de procesamiento fuera del árbol
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main/GameSelector.tscn")

func _on_refresh_pressed():
	reset_word_tracing()

func _on_next_pressed():
	next_shape()
