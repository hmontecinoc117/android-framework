## PatternGame.gd
## Juego de reconocimiento y completado de patrones/secuencias.

extends Node2D

# ──────────────────────────────────────────────
#  Señales
# ──────────────────────────────────────────────

signal game_completed(stars: int, time: float)

# ──────────────────────────────────────────────
#  Enums
# ──────────────────────────────────────────────

enum PatternType {
	AB_PATTERN,      # A-B-A-B
	ABC_PATTERN,     # A-B-C-A-B-C
	AABB_PATTERN,    # A-A-B-B-C-C
	GROWING,         # 1-2-3-4-5
	DECREASING,      # 5-4-3-2-1
	SKIP_COUNTING    # 2-4-6-8
}

# ──────────────────────────────────────────────
#  Constantes
# ──────────────────────────────────────────────

const LOGP := "[PatternGame] "

# ──────────────────────────────────────────────
#  Variables Exportadas
# ──────────────────────────────────────────────

@export var current_pattern_type: PatternType = PatternType.AB_PATTERN
@export var difficulty_level: int = 1

# ──────────────────────────────────────────────
#  Variables Miembro
# ──────────────────────────────────────────────

# --- Nodos ---
var pattern_container: Node = null
var options_container: Node = null
var instruction_label: Label = null
var score_label: Label = null
var feedback_label: Label = null

# --- Estado del juego ---
var current_pattern: Array = []
var gap_positions: Array[int] = []
var correct_answers: Array = []
var questions_answered: int = 0
var correct_count: int = 0
var max_questions: int = 8
var start_time: float = 0.0

# --- Datos ---
var pattern_elements: Dictionary = {
	"shapes": ["🔴", "🔵", "🟢", "🟡", "🟣", "🟠"],
	"animals": ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊"],
	"fruits": ["🍎", "🍌", "🍇", "🍊", "🍓", "🥝"],
	"numbers": ["1", "2", "3", "4", "5", "6", "7", "8", "9"],
	"letters": ["A", "B", "C", "D", "E", "F"]
}

var current_element_set: String = "shapes"

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	pattern_container = get_node_or_null("PatternArea/PatternContainer")
	options_container = get_node_or_null("UI/OptionsContainer")
	instruction_label = get_node_or_null("UI/TopBar/InstructionLabel")
	score_label = get_node_or_null("UI/TopBar/ScoreLabel")
	feedback_label = get_node_or_null("UI/FeedbackLabel")

	_apply_ui_assets()
	_setup_game()
	_generate_question()
	start_time = Time.get_ticks_msec() / 1000.0
	VoiceInstructions.play_instruction("pattern_game")
	print(LOGP, "_ready completado")

# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func change_element_set(new_set: String) -> void:
	if pattern_elements.has(new_set):
		current_element_set = new_set
		reset_game()

func change_pattern_type(new_type: PatternType) -> void:
	current_pattern_type = new_type
	reset_game()

func reset_game() -> void:
	questions_answered = 0
	correct_count = 0
	start_time = Time.get_ticks_msec() / 1000.0
	_setup_game()
	_generate_question()

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
	var back_button: Button = get_node_or_null("UI/TopBar/BackButton")
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
	_update_score_label()
	if instruction_label:
		instruction_label.text = "Completa el patrón"

# ──────────────────────────────────────────────
#  Funciones Privadas — Lógica de Preguntas
# ──────────────────────────────────────────────

func _generate_question() -> void:
	questions_answered += 1

	if questions_answered > max_questions:
		_complete_game()
		return

	_clear_containers()

	# Generar patrón según tipo
	current_pattern = _create_pattern(current_pattern_type)

	# Seleccionar posiciones para gaps
	_select_gap_positions()

	# Mostrar patrón con gaps
	_display_pattern_with_gaps()

	# Generar opciones de respuesta
	_generate_options()

func _create_pattern(pattern_type: PatternType) -> Array:
	var pattern: Array = []
	var elements: Array = pattern_elements[current_element_set]
	var length: int = 6 + difficulty_level

	match pattern_type:
		PatternType.AB_PATTERN:
			var a: String = elements[0]
			var b: String = elements[1]
			for i in length:
				pattern.append(a if i % 2 == 0 else b)

		PatternType.ABC_PATTERN:
			var a: String = elements[0]
			var b: String = elements[1]
			var c: String = elements[2]
			for i in length:
				match i % 3:
					0: pattern.append(a)
					1: pattern.append(b)
					2: pattern.append(c)

		PatternType.AABB_PATTERN:
			var a: String = elements[0]
			var b: String = elements[1]
			for i in length:
				pattern.append(a if (i / 2) % 2 == 0 else b)

		PatternType.GROWING:
			if current_element_set == "numbers":
				var start_num: int = randi_range(1, 3)
				for i in length:
					pattern.append(str(start_num + i))
			else:
				# Para no-números, usar patrón simple
				for i in length:
					pattern.append(elements[i % elements.size()])

		PatternType.DECREASING:
			if current_element_set == "numbers":
				var start_num: int = 10 - difficulty_level
				for i in length:
					var num: int = start_num - i
					if num > 0:
						pattern.append(str(num))
			else:
				var reversed_elements: Array = elements.duplicate()
				reversed_elements.reverse()
				for i in length:
					pattern.append(reversed_elements[i % reversed_elements.size()])

		PatternType.SKIP_COUNTING:
			if current_element_set == "numbers":
				var skip: int = 2
				for i in length:
					pattern.append(str((i + 1) * skip))
			else:
				# Patrón alternado para no-números
				for i in length:
					pattern.append(elements[(i * 2) % elements.size()])

	return pattern

func _select_gap_positions() -> void:
	gap_positions.clear()
	correct_answers.clear()

	var num_gaps: int = 1 + (difficulty_level / 2)  # 1-3 gaps según dificultad
	num_gaps = mini(num_gaps, 3)

	# Evitar gaps en los extremos
	var available_positions: Array = range(1, current_pattern.size() - 1)
	available_positions.shuffle()

	for i in num_gaps:
		if i < available_positions.size():
			var pos: int = available_positions[i]
			gap_positions.append(pos)
			correct_answers.append(current_pattern[pos])

	gap_positions.sort()

# ──────────────────────────────────────────────
#  Funciones Privadas — UI / Display
# ──────────────────────────────────────────────

func _display_pattern_with_gaps() -> void:
	if not pattern_container:
		return

	for i in current_pattern.size():
		var element_panel := Panel.new()
		element_panel.custom_minimum_size = Vector2(100, 100)

		var label := Label.new()
		DesignSystem.setup_label(label, DesignSystem.FONT_XLARGE, Color.WHITE)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_preset(Control.PRESET_FULL_RECT)

		if i in gap_positions:
			# Gap (espacio vacío)
			label.text = "?"
			label.add_theme_color_override("font_color", Color.GRAY)
			element_panel.set_meta("is_gap", true)
			element_panel.set_meta("gap_index", gap_positions.find(i))

			# Estilo diferente para gaps
			var stylebox := StyleBoxFlat.new()
			stylebox.bg_color = Color(0.9, 0.9, 0.9, 1)
			stylebox.border_width_all = 3
			stylebox.border_color = DesignSystem.get_color("primary")
			element_panel.add_theme_stylebox_override("panel", stylebox)
		else:
			# Elemento normal
			label.text = current_pattern[i]
			element_panel.set_meta("is_gap", false)

		element_panel.add_child(label)
		pattern_container.add_child(element_panel)

		# Animación de aparición
		element_panel.scale = Vector2.ZERO
		var tween: Tween = create_tween()
		tween.tween_property(element_panel, "scale", Vector2.ONE, DesignSystem.ANIM_FAST).set_delay(i * 0.1).set_trans(Tween.TRANS_BACK)

func _generate_options() -> void:
	if not options_container:
		return

	var options: Array = correct_answers.duplicate()

	# Añadir opciones incorrectas
	var elements: Array = pattern_elements[current_element_set]
	while options.size() < 4:
		var random_element: String = elements[randi() % elements.size()]
		if random_element not in options:
			options.append(random_element)

	options.shuffle()

	# Crear botones de opciones
	for option in options:
		var button := Button.new()
		button.text = option

		button.custom_minimum_size = DesignSystem.BTN_LARGE
		button.add_theme_font_size_override("font_size", DesignSystem.FONT_XLARGE)

		if ResourceLoader.exists("res://scripts/components/AnimatedButton.gd"):
			button.set_script(load("res://scripts/components/AnimatedButton.gd"))

		button.pressed.connect(_on_option_selected.bind(option))
		options_container.add_child(button)

func _update_score_label() -> void:
	if score_label:
		score_label.text = "Pregunta: %d / %d" % [questions_answered - 1, max_questions]

func _clear_containers() -> void:
	if pattern_container:
		for child in pattern_container.get_children():
			child.queue_free()

	if options_container:
		for child in options_container.get_children():
			child.queue_free()

# ──────────────────────────────────────────────
#  Funciones Privadas — Respuestas / Feedback
# ──────────────────────────────────────────────

func _on_option_selected(selected_option: String) -> void:
	var is_correct: bool = selected_option in correct_answers

	if is_correct:
		_on_correct_answer(selected_option)
	else:
		_on_wrong_answer()

func _on_correct_answer(answer: String) -> void:
	correct_count += 1

	# Llenar el gap en el patrón
	_fill_gap_with_answer(answer)

	# Feedback visual
	if feedback_label:
		feedback_label.text = "¡Correcto!"
		feedback_label.add_theme_color_override("font_color", DesignSystem.get_color("success"))

	# Efectos
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 30)
	AudioManager.play_success()

	# Verificar si completó todos los gaps
	if _all_gaps_filled():
		VoiceInstructions.play_feedback(true, false)
		_update_score_label()
		await get_tree().create_timer(1.5).timeout
		_generate_question()
	else:
		await get_tree().create_timer(0.5).timeout
		if feedback_label:
			feedback_label.text = ""

func _on_wrong_answer() -> void:
	# Feedback visual suave
	if feedback_label:
		feedback_label.text = "Intenta de nuevo"
		feedback_label.add_theme_color_override("font_color", DesignSystem.get_color("error"))

	AudioManager.play_error()

	await get_tree().create_timer(1.0).timeout
	if feedback_label:
		feedback_label.text = ""

func _fill_gap_with_answer(answer: String) -> void:
	# Encontrar el primer gap sin llenar y actualizarlo
	for child in pattern_container.get_children():
		if child.get_meta("is_gap", false):
			var label: Label = child.get_child(0) as Label
			if label and label.text == "?":
				label.text = answer
				label.add_theme_color_override("font_color", DesignSystem.get_color("success"))

				# Animación de éxito
				AnimationHelper.success_effect(child)

				# Cambiar estilo
				var stylebox := StyleBoxFlat.new()
				stylebox.bg_color = Color(0.5, 1, 0.5, 0.3)
				stylebox.border_width_all = 3
				stylebox.border_color = DesignSystem.get_color("success")
				child.add_theme_stylebox_override("panel", stylebox)

				child.set_meta("is_gap", false)
				break

func _all_gaps_filled() -> bool:
	for child in pattern_container.get_children():
		if child.get_meta("is_gap", false):
			return false
	return true

# ──────────────────────────────────────────────
#  Funciones Privadas — Fin de Juego
# ──────────────────────────────────────────────

func _complete_game() -> void:
	var elapsed_time: float = (Time.get_ticks_msec() / 1000.0) - start_time
	var accuracy: float = float(correct_count) / float(max_questions * gap_positions.size())
	var stars: int = _calculate_stars(accuracy)

	_celebrate_completion()
	GameManager.complete_game("PatternGame", stars, elapsed_time)
	game_completed.emit(stars, elapsed_time)
	print(LOGP, "Juego completado: estrellas=", stars, " tiempo=", elapsed_time)

func _calculate_stars(accuracy: float) -> int:
	if accuracy >= 0.9:
		return 3
	elif accuracy >= 0.7:
		return 2
	else:
		return 1

func _celebrate_completion() -> void:
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 100)
	AudioManager.play_game_complete()
	VoiceInstructions.play_feedback(true)

	if OS.has_feature("mobile"):
		Input.vibrate_handheld(300)
