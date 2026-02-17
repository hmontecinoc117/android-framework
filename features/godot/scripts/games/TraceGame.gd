## Juego de trazado mejorado con letras/números guía.
## El usuario traza sobre la guía y recibe feedback en tiempo real.

extends Control

# --- Señales ---
signal game_completed(stars: int, time: float)

# --- Constantes ---
const LOGP := "[TraceGame] "

# Letras disponibles (mayúsculas, legibles para niños)
const LETTERS := ["A", "B", "C", "E", "L", "O", "T", "I", "U"]
const NUMBERS := ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

# Configuración de dificultad
const COVERAGE_THRESHOLD := 0.75  # 75% de cobertura para éxito
const MIN_POINTS_FOR_CHECK := 10   # Puntos mínimos antes de verificar

# --- Variables Miembro ---
var is_drawing: bool = false
var last_point: Vector2 = Vector2.ZERO
var current_level: int = 0
var current_character: String = ""
var start_time: float = 0.0
var total_coverage: float = 0.0

# Líneas
var trace_line: Line2D = null
var guide_line: Line2D = null
var guide_points: PackedVector2Array = []

# --- Variables Onready ---
@onready var instruction_label: Label = $UI/InstructionLabel
@onready var back_button: Button = $UI/BackButton
@onready var drawing_area: Control = $DrawingArea
@onready var canvas: Control = $DrawingArea/Canvas
@onready var progress_bar: ProgressBar = $UI/ProgressBar
@onready var character_label: Label = $DrawingArea/CharacterLabel
@onready var next_button: Button = $UI/NextButton

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	print(LOGP, "_ready()")
	set_process_input(true)

	_apply_ui_assets()
	_setup_drawing_lines()
	_load_next_level()
	
	if instruction_label:
		instruction_label.text = "Traza la letra con tu dedo"
		instruction_label.add_theme_font_size_override("font_size", 64)

	if back_button:
		back_button.custom_minimum_size = Vector2(120, 100)
		back_button.add_theme_font_size_override("font_size", 48)
		back_button.text = "🏠"
		back_button.focus_mode = Control.FOCUS_NONE
		back_button.pressed.connect(_on_back_pressed)
	
	if next_button:
		next_button.custom_minimum_size = Vector2(120, 100)
		next_button.add_theme_font_size_override("font_size", 48)
		next_button.text = "▶"
		next_button.focus_mode = Control.FOCUS_NONE
		next_button.pressed.connect(_on_next_pressed)
		next_button.visible = false
	
	if progress_bar:
		progress_bar.value = 0
		progress_bar.max_value = 100
	
	start_time = Time.get_ticks_msec() / 1000.0
	VoiceInstructions.play_instruction("trace_game")

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_in_drawing_area(event.position):
				is_drawing = true
				last_point = event.position
				trace_line.clear_points()
				trace_line.add_point(event.position)
				print(LOGP, "Empezó a dibujar en: ", event.position)
		else:
			is_drawing = false
			print(LOGP, "Dejó de dibujar. Cobertura: ", total_coverage)
			if total_coverage >= COVERAGE_THRESHOLD:
				_show_success()

	elif event is InputEventScreenDrag and is_drawing:
		if _is_in_drawing_area(event.position):
			_add_trace_point(event.position)
			last_point = event.position

func _is_in_drawing_area(pos: Vector2) -> bool:
	if not drawing_area:
		return true
	return drawing_area.get_global_rect().has_point(pos)

# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _setup_drawing_lines() -> void:
	# Crear Line2D para el trazo del usuario
	trace_line = Line2D.new()
	trace_line.width = 12.0
	trace_line.default_color = Color(0.2, 0.6, 1.0, 0.9)  # Azul
	trace_line.joint_mode = Line2D.LINE_JOINT_ROUND
	trace_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	trace_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	if canvas:
		canvas.add_child(trace_line)
	
	# Crear Line2D para la guía
	guide_line = Line2D.new()
	guide_line.width = 16.0
	guide_line.default_color = Color(0.8, 0.8, 0.8, 0.6)  # Gris transparente
	guide_line.joint_mode = Line2D.LINE_JOINT_ROUND
	guide_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	guide_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	if canvas:
		canvas.add_child(guide_line)

func _load_next_level() -> void:
	# Determinar qué mostrar según el nivel
	var char_list = LETTERS if current_level < LETTERS.size() else NUMBERS
	var idx = current_level % char_list.size()
	current_character = char_list[idx]
	
	print(LOGP, "Nivel ", current_level, " - Carácter: ", current_character)
	
	# Mostrar el carácter
	if character_label:
		character_label.text = current_character
		character_label.add_theme_font_size_override("font_size", 400)
		character_label.modulate = Color(0.9, 0.9, 0.9, 0.3)  # Muy transparente
	
	# Generar puntos guía
	guide_points = _generate_character_guide(current_character)
	if guide_line:
		guide_line.clear_points()
		for p in guide_points:
			guide_line.add_point(p)
	
	# Reiniciar progreso
	total_coverage = 0.0
	if trace_line:
		trace_line.clear_points()
	if progress_bar:
		progress_bar.value = 0
	if next_button:
		next_button.visible = false

func _generate_character_guide(character: String) -> PackedVector2Array:
	# Generar puntos guía para el carácter
	var points := PackedVector2Array()
	var center := Vector2(960, 540)  # Centro 1920x1080
	var scale_factor := 2.0
	
	match character:
		"A":
			# Forma de A: línea izquierda, derecha, barra horizontal
			points.append_array(_line_points(center + Vector2(-150, 200) * scale_factor, center + Vector2(0, -200) * scale_factor, 20))
			points.append_array(_line_points(center + Vector2(0, -200) * scale_factor, center + Vector2(150, 200) * scale_factor, 20))
			points.append_array(_line_points(center + Vector2(-75, 0) * scale_factor, center + Vector2(75, 0) * scale_factor, 10))
		"B":
			points.append_array(_line_points(center + Vector2(-100, -200) * scale_factor, center + Vector2(-100, 200) * scale_factor, 30))
			points.append_array(_arc_points(center + Vector2(-100, -100) * scale_factor, 100 * scale_factor, 0, PI, 15))
			points.append_array(_arc_points(center + Vector2(-100, 100) * scale_factor, 100 * scale_factor, 0, PI, 15))
		"C":
			points.append_array(_arc_points(center, 150 * scale_factor, PI * 0.2, PI * 1.8, 40))
		"E":
			points.append_array(_line_points(center + Vector2(-100, -200) * scale_factor, center + Vector2(-100, 200) * scale_factor, 30))
			points.append_array(_line_points(center + Vector2(-100, -200) * scale_factor, center + Vector2(100, -200) * scale_factor, 15))
			points.append_array(_line_points(center + Vector2(-100, 0) * scale_factor, center + Vector2(80, 0) * scale_factor, 12))
			points.append_array(_line_points(center + Vector2(-100, 200) * scale_factor, center + Vector2(100, 200) * scale_factor, 15))
		"L":
			points.append_array(_line_points(center + Vector2(-80, -200) * scale_factor, center + Vector2(-80, 200) * scale_factor, 30))
			points.append_array(_line_points(center + Vector2(-80, 200) * scale_factor, center + Vector2(100, 200) * scale_factor, 15))
		"O":
			points.append_array(_arc_points(center, 150 * scale_factor, 0, TAU, 50))
		"T":
			points.append_array(_line_points(center + Vector2(-120, -200) * scale_factor, center + Vector2(120, -200) * scale_factor, 20))
			points.append_array(_line_points(center + Vector2(0, -200) * scale_factor, center + Vector2(0, 200) * scale_factor, 30))
		"I":
			points.append_array(_line_points(center + Vector2(0, -200) * scale_factor, center + Vector2(0, 200) * scale_factor, 40))
		"U":
			points.append_array(_line_points(center + Vector2(-100, -200) * scale_factor, center + Vector2(-100, 100) * scale_factor, 20))
			points.append_array(_arc_points(center + Vector2(0, 100) * scale_factor, 100 * scale_factor, PI, TAU, 20))
			points.append_array(_line_points(center + Vector2(100, 100) * scale_factor, center + Vector2(100, -200) * scale_factor, 20))
		"1":
			points.append_array(_line_points(center + Vector2(-50, -150) * scale_factor, center + Vector2(0, -200) * scale_factor, 8))
			points.append_array(_line_points(center + Vector2(0, -200) * scale_factor, center + Vector2(0, 200) * scale_factor, 35))
		"2":
			points.append_array(_arc_points(center + Vector2(0, -150) * scale_factor, 100 * scale_factor, PI, TAU, 20))
			points.append_array(_line_points(center + Vector2(100, -150) * scale_factor, center + Vector2(-100, 200) * scale_factor, 25))
			points.append_array(_line_points(center + Vector2(-100, 200) * scale_factor, center + Vector2(100, 200) * scale_factor, 15))
		"3":
			points.append_array(_arc_points(center + Vector2(0, -100) * scale_factor, 100 * scale_factor, PI * 1.5, PI * 0.5, 15))
			points.append_array(_arc_points(center + Vector2(0, 100) * scale_factor, 100 * scale_factor, PI * 1.5, PI * 0.5, 15))
		_:
			# Círculo por defecto
			points.append_array(_arc_points(center, 150 * scale_factor, 0, TAU, 50))
	
	return points

func _line_points(from: Vector2, to: Vector2, count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in count:
		var t := float(i) / float(count - 1) if count > 1 else 0.0
		points.append(from.lerp(to, t))
	return points

func _arc_points(center: Vector2, radius: float, start_angle: float, end_angle: float, count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in count:
		var t := float(i) / float(count - 1) if count > 1 else 0.0
		var angle := lerp(start_angle, end_angle, t)
		var x := center.x + cos(angle) * radius
		var y := center.y + sin(angle) * radius
		points.append(Vector2(x, y))
	return points

func _add_trace_point(pos: Vector2) -> void:
	if trace_line:
		trace_line.add_point(pos)
		
		# Verificar cobertura cada ciertos puntos
		if trace_line.get_point_count() % 5 == 0 and trace_line.get_point_count() >= MIN_POINTS_FOR_CHECK:
			_calculate_coverage()

func _calculate_coverage() -> void:
	if not trace_line or trace_line.get_point_count() < MIN_POINTS_FOR_CHECK:
		return
	if guide_points.size() == 0:
		return
	
	# Calcular qué porcentaje de la guía está cubierto por el trazo
	var covered_points := 0
	var tolerance := 80.0  # Distancia máxima para considerar "cubierto"
	
	for guide_point in guide_points:
		for i in trace_line.get_point_count():
			var trace_point = trace_line.get_point_position(i)
			if guide_point.distance_to(trace_point) < tolerance:
				covered_points += 1
				break
	
	total_coverage = float(covered_points) / float(guide_points.size())
	
	# Actualizar barra de progreso
	if progress_bar:
		progress_bar.value = total_coverage * 100
	
	print(LOGP, "Cobertura: ", snappedf(total_coverage * 100, 0.1), "%")

func _draw_line_segment(from: Vector2, to: Vector2) -> void:
	# Ya no se usa, reemplazado por Line2D
	pass

func _show_success() -> void:
	print(LOGP, "¡Completado! Cobertura: ", snappedf(total_coverage * 100, 1), "%")
	is_drawing = false
	
	var elapsed_time := (Time.get_ticks_msec() / 1000.0) - start_time
	var stars := _calculate_stars(total_coverage)
	
	# Celebración
	AudioManager.play_success()
	VoiceInstructions.play_feedback(true)
	if canvas:
		AnimationHelper.create_confetti_at_position(self, canvas.global_position + canvas.size / 2, 50)
	
	# Vibración
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(200)
	
	# Mostrar feedback
	if instruction_label:
		var msg := "¡Excelente!" if stars == 3 else "¡Muy bien!" if stars == 2 else "¡Bien hecho!"
		instruction_label.text = msg + " ⭐".repeat(stars)
	
	# Registrar progreso
	GameManager.complete_game("TraceGame", stars, elapsed_time)
	game_completed.emit(stars, elapsed_time)
	
	# Mostrar botón siguiente
	if next_button:
		next_button.visible = true
		var tween := create_tween()
		tween.tween_property(next_button, "scale", Vector2(1.2, 1.2), 0.3)
		tween.tween_property(next_button, "scale", Vector2.ONE, 0.2)

func _calculate_stars(coverage: float) -> int:
	if coverage >= 0.90:
		return 3
	elif coverage >= 0.75:
		return 2
	else:
		return 1

func _on_next_pressed() -> void:
	AudioManager.play_button_press()
	current_level += 1
	start_time = Time.get_ticks_msec() / 1000.0
	_load_next_level()
	
	if instruction_label:
		instruction_label.text = "Traza la letra con tu dedo"

func _on_back_pressed() -> void:
	print(LOGP, "Volviendo a selector")
	AudioManager.play_back()
	var bootstrap: Node = get_node_or_null("/root/UiBootstrap")
	if bootstrap and bootstrap.has_method("fade_to_scene"):
		bootstrap.fade_to_scene("res://scenes/main/GameSelector.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main/GameSelector.tscn")

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

	# Botón atrás estilo
	if back_button:
		var normal_tex_path: String = "res://assets/images/ui/button_grey.png"
		var pressed_tex_path: String = "res://assets/images/ui/button_red_close.png"
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
