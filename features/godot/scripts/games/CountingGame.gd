## Juego de conteo y números.
## Modos: contar objetos, número faltante, ordenar números y suma simple.

extends Node2D

# ──────────────────────────────────────────────
#  Señales
# ──────────────────────────────────────────────

signal game_completed(stars: int, time: float)

# ──────────────────────────────────────────────
#  Enums
# ──────────────────────────────────────────────

# Modos de juego
enum GameMode {
	COUNT_OBJECTS,      # Contar objetos mostrados
	MISSING_NUMBER,     # Encontrar número faltante en secuencia
	SORT_NUMBERS,       # Ordenar números
	SIMPLE_ADDITION     # Suma simple
}

# ──────────────────────────────────────────────
#  Constantes
# ──────────────────────────────────────────────

const LOGP := "[CountingGame] "

# Objetos contables (emojis simples)
const COUNTABLE_OBJECTS: Array = [
	"🍎", "🍌", "🍇", "🍊", "🍓",  # Frutas
	"⭐", "🌟", "💫", "✨", "🌙",  # Estrellas
	"🐶", "🐱", "🐭", "🐹", "🐰",  # Animales
	"🚗", "🚕", "🚙", "🚌", "🚎"   # Vehículos
]

# ──────────────────────────────────────────────
#  Variables Exportadas
# ──────────────────────────────────────────────

@export var current_mode: GameMode = GameMode.COUNT_OBJECTS
@export var difficulty_level: int = 1  # 1-5

# ──────────────────────────────────────────────
#  Variables Miembro
# ──────────────────────────────────────────────

# --- Nodos ---
var question_label: Label = null
var objects_container: Node = null
var answers_container: Node = null
var feedback_label: Label = null
var score_label: Label = null

# --- Estado del juego ---
var correct_answer: int = 0
var attempts: int = 0
var correct_count: int = 0
var questions_answered: int = 0
var max_questions: int = 10
var start_time: float = 0.0

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	# Obtener nodos
	question_label = get_node_or_null("UI/TopBar/QuestionLabel")
	objects_container = get_node_or_null("ObjectsArea/ObjectsContainer")
	answers_container = get_node_or_null("UI/AnswersContainer")
	feedback_label = get_node_or_null("UI/FeedbackLabel")
	score_label = get_node_or_null("UI/TopBar/ScoreLabel")

	_apply_ui_assets()
	_setup_game()
	_generate_question()
	start_time = Time.get_ticks_msec() / 1000.0

	# Reproducir instrucción
	VoiceInstructions.play_instruction("counting_game")
	print(LOGP, "_ready completado")

# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func change_mode(new_mode: GameMode) -> void:
	current_mode = new_mode
	reset_game()

func change_difficulty(level: int) -> void:
	difficulty_level = clampi(level, 1, 5)
	reset_game()

func reset_game() -> void:
	correct_count = 0
	attempts = 0
	questions_answered = 0
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

# ──────────────────────────────────────────────
#  Funciones Privadas — Generación de Preguntas
# ──────────────────────────────────────────────

func _generate_question() -> void:
	questions_answered += 1

	if questions_answered > max_questions:
		_complete_game()
		return

	match current_mode:
		GameMode.COUNT_OBJECTS:
			_generate_count_objects()
		GameMode.MISSING_NUMBER:
			_generate_missing_number()
		GameMode.SORT_NUMBERS:
			_generate_sort_numbers()
		GameMode.SIMPLE_ADDITION:
			_generate_simple_addition()

func _generate_count_objects() -> void:
	# Limpiar contenedores
	_clear_containers()

	# Determinar rango según dificultad
	var max_count: int = 5 + (difficulty_level * 2)  # Nivel 1: 3-7, Nivel 2: 3-9, etc.
	correct_answer = randi_range(3, max_count)

	# Actualizar pregunta
	if question_label:
		question_label.text = "¿Cuántos objetos hay?"

	# Seleccionar objeto aleatorio
	var selected_object: String = COUNTABLE_OBJECTS[randi() % COUNTABLE_OBJECTS.size()]

	# Generar objetos visualmente
	if objects_container:
		for i in correct_answer:
			var obj_label: Label = _create_countable_object(selected_object)
			objects_container.add_child(obj_label)

	# Generar opciones de respuesta
	_generate_number_options(correct_answer, 4)

func _generate_missing_number() -> void:
	_clear_containers()

	# Generar secuencia con número faltante
	var sequence_length: int = 5 + difficulty_level
	var missing_index: int = randi_range(1, sequence_length - 2)  # No en los extremos

	correct_answer = missing_index + 1

	if question_label:
		question_label.text = "¿Qué número falta?"

	# Mostrar secuencia
	if objects_container:
		for i in sequence_length:
			var num_label := Label.new()
			DesignSystem.setup_label(num_label, DesignSystem.FONT_XLARGE, Color.WHITE)
			num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

			if i == missing_index:
				num_label.text = "___"
			else:
				num_label.text = str(i + 1)

			objects_container.add_child(num_label)

	# Generar opciones
	_generate_number_options(correct_answer, 4)

func _generate_sort_numbers() -> void:
	_clear_containers()

	# Generar números desordenados
	var count: int = 5
	var numbers: Array = []
	for i in count:
		numbers.append(i + 1)
	numbers.shuffle()

	if question_label:
		question_label.text = "Ordena los números de menor a mayor"

	# Esta variante requeriría drag & drop
	# Por simplicidad, mostraremos opciones de secuencia

	correct_answer = 1  # Simplificado
	_generate_number_options(correct_answer, 4)

func _generate_simple_addition() -> void:
	_clear_containers()

	# Generar suma simple
	var max_num: int = 5 + difficulty_level
	var num1: int = randi_range(1, max_num)
	var num2: int = randi_range(1, max_num)
	correct_answer = num1 + num2

	if question_label:
		question_label.text = "%d + %d = ?" % [num1, num2]

	# Mostrar grupos visuales
	if objects_container:
		var selected_object: String = COUNTABLE_OBJECTS[randi() % COUNTABLE_OBJECTS.size()]

		# Primer grupo
		var group1 := HBoxContainer.new()
		for i in num1:
			var obj: Label = _create_countable_object(selected_object)
			group1.add_child(obj)
		objects_container.add_child(group1)

		# Símbolo +
		var plus_label := Label.new()
		plus_label.text = "+"
		DesignSystem.setup_label(plus_label, DesignSystem.FONT_XLARGE, Color.WHITE)
		objects_container.add_child(plus_label)

		# Segundo grupo
		var group2 := HBoxContainer.new()
		for i in num2:
			var obj: Label = _create_countable_object(selected_object)
			group2.add_child(obj)
		objects_container.add_child(group2)

	# Generar opciones
	_generate_number_options(correct_answer, 4)

# ──────────────────────────────────────────────
#  Funciones Privadas — Helpers
# ──────────────────────────────────────────────

func _create_countable_object(emoji: String) -> Label:
	var obj_label := Label.new()
	obj_label.text = emoji
	DesignSystem.setup_label(obj_label, DesignSystem.FONT_XLARGE, Color.WHITE)

	# Posición y rotación aleatorias (efecto más natural)
	obj_label.rotation = randf_range(-0.2, 0.2)

	# Animación de aparición
	obj_label.scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(obj_label, "scale", Vector2.ONE, DesignSystem.ANIM_FAST).set_trans(Tween.TRANS_BACK)

	return obj_label

func _generate_number_options(correct: int, num_options: int) -> void:
	_clear_answers_container()

	# Generar opciones (una correcta + otras incorrectas)
	var options: Array = [correct]

	# Generar opciones incorrectas
	while options.size() < num_options:
		var option: int = correct + randi_range(-3, 3)
		if option > 0 and option != correct and option not in options:
			options.append(option)

	# Mezclar opciones
	options.shuffle()

	# Crear botones de respuesta
	for option in options:
		var button := Button.new()
		button.text = str(option)

		button.custom_minimum_size = DesignSystem.BTN_LARGE
		button.add_theme_font_size_override("font_size", DesignSystem.FONT_XLARGE)

		# Aplicar script de AnimatedButton
		if ResourceLoader.exists("res://scripts/components/AnimatedButton.gd"):
			button.set_script(load("res://scripts/components/AnimatedButton.gd"))

		button.pressed.connect(_on_answer_selected.bind(option))

		answers_container.add_child(button)

# ──────────────────────────────────────────────
#  Funciones Privadas — Respuestas y Puntuación
# ──────────────────────────────────────────────

func _on_answer_selected(selected_answer: int) -> void:
	attempts += 1

	if selected_answer == correct_answer:
		# ¡Respuesta correcta!
		_on_correct_answer()
	else:
		# Respuesta incorrecta
		_on_wrong_answer()

func _on_correct_answer() -> void:
	correct_count += 1

	# Feedback visual
	if feedback_label:
		feedback_label.text = "¡Correcto! ✓"
		feedback_label.add_theme_color_override("font_color", DesignSystem.get_color("success"))

	# Efectos
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 30)
	AudioManager.play_success()
	VoiceInstructions.play_feedback(true, false)

	# Actualizar puntaje
	_update_score_label()

	# Siguiente pregunta
	await get_tree().create_timer(1.5).timeout
	_generate_question()

func _on_wrong_answer() -> void:
	# Feedback visual
	if feedback_label:
		feedback_label.text = "Intenta de nuevo"
		feedback_label.add_theme_color_override("font_color", DesignSystem.get_color("error"))

	# Efectos suaves
	AudioManager.play_error()

	# El juego continúa, puede intentar de nuevo
	await get_tree().create_timer(1.0).timeout
	if feedback_label:
		feedback_label.text = ""

func _complete_game() -> void:
	var elapsed_time: float = (Time.get_ticks_msec() / 1000.0) - start_time

	# Calcular estrellas según precisión
	var accuracy: float = float(correct_count) / float(max_questions)
	var stars: int = _calculate_stars(accuracy)

	# Celebración
	_celebrate_completion()

	# Registrar progreso
	GameManager.complete_game("CountingGame", stars, elapsed_time)
	print(LOGP, "Juego completado: estrellas=", stars, " tiempo=", elapsed_time)

	game_completed.emit(stars, elapsed_time)

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

func _update_score_label() -> void:
	if score_label:
		score_label.text = "Puntuación: %d / %d" % [correct_count, questions_answered]

func _clear_containers() -> void:
	if objects_container:
		for child in objects_container.get_children():
			child.queue_free()
	_clear_answers_container()

func _clear_answers_container() -> void:
	if answers_container:
		for child in answers_container.get_children():
			child.queue_free()
