# PatternGame.gd
# Juego de reconocimiento y completado de patrones/secuencias
extends Node2D

signal game_completed(stars: int, time: float)

# Tipos de patrones
enum PatternType {
	AB_PATTERN,      # A-B-A-B
	ABC_PATTERN,     # A-B-C-A-B-C
	AABB_PATTERN,    # A-A-B-B-C-C
	GROWING,         # 1-2-3-4-5
	DECREASING,      # 5-4-3-2-1
	SKIP_COUNTING    # 2-4-6-8
}

@export var current_pattern_type: PatternType = PatternType.AB_PATTERN
@export var difficulty_level: int = 1

# Nodos
var pattern_container
var options_container
var instruction_label
var score_label
var feedback_label

# Variables
var current_pattern: Array = []
var gap_positions: Array[int] = []
var correct_answers: Array = []
var questions_answered: int = 0
var correct_count: int = 0
var max_questions: int = 8
var start_time: float = 0.0

# Elementos de patrón (emojis, formas, colores)
var pattern_elements: Dictionary = {
	"shapes": ["🔴", "🔵", "🟢", "🟡", "🟣", "🟠"],
	"animals": ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊"],
	"fruits": ["🍎", "🍌", "🍇", "🍊", "🍓", "🥝"],
	"numbers": ["1", "2", "3", "4", "5", "6", "7", "8", "9"],
	"letters": ["A", "B", "C", "D", "E", "F"]
}

var current_element_set: String = "shapes"

func _ready():
	# Obtener nodos
	pattern_container = get_node_or_null("PatternArea/PatternContainer")
	options_container = get_node_or_null("UI/OptionsContainer")
	instruction_label = get_node_or_null("UI/TopBar/InstructionLabel")
	score_label = get_node_or_null("UI/TopBar/ScoreLabel")
	feedback_label = get_node_or_null("UI/FeedbackLabel")

	apply_ui_assets()
	
	setup_game()
	generate_question()
	start_time = Time.get_ticks_msec() / 1000.0
		VoiceInstructions.play_instruction("pattern_game")

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
	update_score_label()
	
	if instruction_label:
		instruction_label.text = "Completa el patrón"

func generate_question():
	questions_answered += 1
	
	if questions_answered > max_questions:
		complete_game()
		return
	
	clear_containers()
	
	# Generar patrón según tipo
	current_pattern = create_pattern(current_pattern_type)
	
	# Seleccionar posiciones para gaps
	select_gap_positions()
	
	# Mostrar patrón con gaps
	display_pattern_with_gaps()
	
	# Generar opciones de respuesta
	generate_options()

func create_pattern(pattern_type: PatternType) -> Array:
	var pattern: Array = []
	var elements = pattern_elements[current_element_set]
	var length = 6 + difficulty_level
	
	match pattern_type:
		PatternType.AB_PATTERN:
			var a = elements[0]
			var b = elements[1]
			for i in length:
				pattern.append(a if i % 2 == 0 else b)
		
		PatternType.ABC_PATTERN:
			var a = elements[0]
			var b = elements[1]
			var c = elements[2]
			for i in length:
				match i % 3:
					0: pattern.append(a)
					1: pattern.append(b)
					2: pattern.append(c)
		
		PatternType.AABB_PATTERN:
			var a = elements[0]
			var b = elements[1]
			for i in length:
				pattern.append(a if (i / 2) % 2 == 0 else b)
		
		PatternType.GROWING:
			if current_element_set == "numbers":
				var start_num = randi_range(1, 3)
				for i in length:
					pattern.append(str(start_num + i))
			else:
				# Para no-números, usar patrón simple
				for i in length:
					pattern.append(elements[i % elements.size()])
		
		PatternType.DECREASING:
			if current_element_set == "numbers":
				var start_num = 10 - difficulty_level
				for i in length:
					var num = start_num - i
					if num > 0:
						pattern.append(str(num))
			else:
				var reversed_elements = elements.duplicate()
				reversed_elements.reverse()
				for i in length:
					pattern.append(reversed_elements[i % reversed_elements.size()])
		
		PatternType.SKIP_COUNTING:
			if current_element_set == "numbers":
				var skip = 2
				for i in length:
					pattern.append(str((i + 1) * skip))
			else:
				# Patrón alternado para no-números
				for i in length:
					pattern.append(elements[(i * 2) % elements.size()])
	
	return pattern

func select_gap_positions():
	gap_positions.clear()
	correct_answers.clear()
	
	var num_gaps = 1 + (difficulty_level / 2)  # 1-3 gaps según dificultad
	num_gaps = mini(num_gaps, 3)
	
	# Evitar gaps en los extremos
	var available_positions = range(1, current_pattern.size() - 1)
	available_positions.shuffle()
	
	for i in num_gaps:
		if i < available_positions.size():
			var pos = available_positions[i]
			gap_positions.append(pos)
			correct_answers.append(current_pattern[pos])
	
	gap_positions.sort()

func display_pattern_with_gaps():
	if not pattern_container:
		return
	
	for i in current_pattern.size():
		var element_panel = Panel.new()
		element_panel.custom_minimum_size = Vector2(100, 100)
		
		var label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 64)
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		if i in gap_positions:
			# Gap (espacio vacío)
			label.text = "?"
			label.add_theme_color_override("font_color", Color.GRAY)
			element_panel.set_meta("is_gap", true)
			element_panel.set_meta("gap_index", gap_positions.find(i))
			
			# Estilo diferente para gaps
			var stylebox = StyleBoxFlat.new()
			stylebox.bg_color = Color(0.9, 0.9, 0.9, 1)
			stylebox.border_width_all = 3
			stylebox.border_color = GameManager.COLOR_PRIMARY_YELLOW
			element_panel.add_theme_stylebox_override("panel", stylebox)
		else:
			# Elemento normal
			label.text = current_pattern[i]
			element_panel.set_meta("is_gap", false)
		
		element_panel.add_child(label)
		pattern_container.add_child(element_panel)
		
		# Animación de aparición
		element_panel.scale = Vector2.ZERO
		var tween = create_tween()
		tween.tween_property(element_panel, "scale", Vector2.ONE, 0.3).set_delay(i * 0.1)

func generate_options():
	if not options_container:
		return
	
	var options = correct_answers.duplicate()
	
	# Añadir opciones incorrectas
	var elements = pattern_elements[current_element_set]
	while options.size() < 4:
		var random_element = elements[randi() % elements.size()]
		if random_element not in options:
			options.append(random_element)
	
	options.shuffle()
	
	# Crear botones de opciones
	for option in options:
		var button = Button.new()
		button.text = option
		
		button.custom_minimum_size = ScreenSizeAdapter.get_adaptive_button_size(Vector2(120, 120))
		
		button.add_theme_font_size_override("font_size", 64)
		
		if ResourceLoader.exists("res://scripts/components/AnimatedButton.gd"):
			button.set_script(load("res://scripts/components/AnimatedButton.gd"))
		
		button.pressed.connect(_on_option_selected.bind(option))
		options_container.add_child(button)

func _on_option_selected(selected_option: String):
	# Verificar si es correcto
	var is_correct = selected_option in correct_answers
	
	if is_correct:
		on_correct_answer(selected_option)
	else:
		on_wrong_answer()

func on_correct_answer(answer: String):
	correct_count += 1
	
	# Llenar el gap en el patrón
	fill_gap_with_answer(answer)
	
	# Feedback visual
	if feedback_label:
		feedback_label.text = "¡Correcto! ✓"
		feedback_label.add_theme_color_override("font_color", GameManager.COLOR_SUCCESS)
	
	# Efectos
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 30)
	AudioManager.play_success()
	
	# Verificar si completó todos los gaps
	if all_gaps_filled():
			VoiceInstructions.play_feedback(true, false)
		update_score_label()
		await get_tree().create_timer(1.5).timeout
		generate_question()
	else:
		await get_tree().create_timer(0.5).timeout
		if feedback_label:
			feedback_label.text = ""

func fill_gap_with_answer(answer: String):
	# Encontrar el primer gap sin llenar y actualizarlo
	for child in pattern_container.get_children():
		if child.get_meta("is_gap", false):
			var label = child.get_child(0) as Label
			if label and label.text == "?":
				label.text = answer
				label.add_theme_color_override("font_color", GameManager.COLOR_SUCCESS)
				
				# Animación de éxito
				AnimationHelper.success_effect(child)
				
				# Cambiar estilo
				var stylebox = StyleBoxFlat.new()
				stylebox.bg_color = Color(0.5, 1, 0.5, 0.3)
				stylebox.border_width_all = 3
				stylebox.border_color = GameManager.COLOR_SUCCESS
				child.add_theme_stylebox_override("panel", stylebox)
				
				child.set_meta("is_gap", false)
				break

func all_gaps_filled() -> bool:
	for child in pattern_container.get_children():
		if child.get_meta("is_gap", false):
			return false
	return true

func on_wrong_answer():
	# Feedback visual suave
	if feedback_label:
		feedback_label.text = "Intenta de nuevo"
		feedback_label.add_theme_color_override("font_color", GameManager.COLOR_ERROR)
	
	AudioManager.play_error()
	
	await get_tree().create_timer(1.0).timeout
	if feedback_label:
		feedback_label.text = ""

func complete_game():
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - start_time
	var accuracy = float(correct_count) / float(max_questions * gap_positions.size())
	var stars = calculate_stars(accuracy)
	
	celebrate_completion()
	GameManager.complete_game("PatternGame", stars, elapsed_time)
	game_completed.emit(stars, elapsed_time)

func calculate_stars(accuracy: float) -> int:
	if accuracy >= 0.9:
		return 3
	elif accuracy >= 0.7:
		return 2
	else:
		return 1

func celebrate_completion():
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 100)
	AudioManager.play_game_complete()
	VoiceInstructions.play_feedback(true)
	
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(300)

func update_score_label():
	if score_label:
		score_label.text = "Pregunta: %d / %d" % [questions_answered - 1, max_questions]

func clear_containers():
	if pattern_container:
		for child in pattern_container.get_children():
			child.queue_free()
	
	if options_container:
		for child in options_container.get_children():
			child.queue_free()

func change_element_set(new_set: String):
	if pattern_elements.has(new_set):
		current_element_set = new_set
		reset_game()

func change_pattern_type(new_type: PatternType):
	current_pattern_type = new_type
	reset_game()

func reset_game():
	questions_answered = 0
	correct_count = 0
	start_time = Time.get_ticks_msec() / 1000.0
	setup_game()
	generate_question()
