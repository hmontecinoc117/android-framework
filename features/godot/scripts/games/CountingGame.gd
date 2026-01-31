# CountingGame.gd
# Juego de conteo y números
extends Node2D

signal game_completed(stars: int, time: float)

# Modos de juego
enum GameMode {
	COUNT_OBJECTS,      # Contar objetos mostrados
	MISSING_NUMBER,     # Encontrar número faltante en secuencia
	SORT_NUMBERS,       # Ordenar números
	SIMPLE_ADDITION     # Suma simple
}

@export var current_mode: GameMode = GameMode.COUNT_OBJECTS
@export var difficulty_level: int = 1  # 1-5

# Nodos
var question_label
var objects_container
var answers_container
var feedback_label
var score_label

# Variables
var correct_answer: int = 0
var attempts: int = 0
var correct_count: int = 0
var questions_answered: int = 0
var max_questions: int = 10
var start_time: float = 0.0

# Objetos contables (emojis simples)
var countable_objects = [
	"🍎", "🍌", "🍇", "🍊", "🍓",  # Frutas
	"⭐", "🌟", "💫", "✨", "🌙",  # Estrellas
	"🐶", "🐱", "🐭", "🐹", "🐰",  # Animales
	"🚗", "🚕", "🚙", "🚌", "🚎"   # Vehículos
]

func _ready():
	# Obtener nodos
	question_label = get_node_or_null("UI/TopBar/QuestionLabel")
	objects_container = get_node_or_null("ObjectsArea/ObjectsContainer")
	answers_container = get_node_or_null("UI/AnswersContainer")
	feedback_label = get_node_or_null("UI/FeedbackLabel")
	score_label = get_node_or_null("UI/TopBar/ScoreLabel")

	apply_ui_assets()
	
	setup_game()
	generate_question()
	start_time = Time.get_ticks_msec() / 1000.0
	
	# Reproducir instrucción
	VoiceInstructions.play_instruction("counting_game")
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

func generate_question():
	questions_answered += 1
	
	if questions_answered > max_questions:
		complete_game()
		return
	
	match current_mode:
		GameMode.COUNT_OBJECTS:
			generate_count_objects()
		GameMode.MISSING_NUMBER:
			generate_missing_number()
		GameMode.SORT_NUMBERS:
			generate_sort_numbers()
		GameMode.SIMPLE_ADDITION:
			generate_simple_addition()

func generate_count_objects():
	# Limpiar contenedores
	clear_containers()
	
	# Determinar rango según dificultad
	var max_count = 5 + (difficulty_level * 2)  # Nivel 1: 3-7, Nivel 2: 3-9, etc.
	correct_answer = randi_range(3, max_count)
	
	# Actualizar pregunta
	if question_label:
		question_label.text = "¿Cuántos objetos hay?"
	
	# Seleccionar objeto aleatorio
	var selected_object = countable_objects[randi() % countable_objects.size()]
	
	# Generar objetos visualmente
	if objects_container:
		for i in correct_answer:
			var obj_label = create_countable_object(selected_object)
			objects_container.add_child(obj_label)
	
	# Generar opciones de respuesta
	generate_number_options(correct_answer, 4)

func generate_missing_number():
	clear_containers()
	
	# Generar secuencia con número faltante
	var sequence_length = 5 + difficulty_level
	var missing_index = randi_range(1, sequence_length - 2)  # No en los extremos
	
	correct_answer = missing_index + 1
	
	if question_label:
		question_label.text = "¿Qué número falta?"
	
	# Mostrar secuencia
	if objects_container:
		for i in sequence_length:
			var num_label = Label.new()
			num_label.add_theme_font_size_override("font_size", 64)
			num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			
			if i == missing_index:
				num_label.text = "___"
			else:
				num_label.text = str(i + 1)
			
			objects_container.add_child(num_label)
	
	# Generar opciones
	generate_number_options(correct_answer, 4)

func generate_sort_numbers():
	clear_containers()
	
	# Generar números desordenados
	var count = 5
	var numbers = []
	for i in count:
		numbers.append(i + 1)
	numbers.shuffle()
	
	if question_label:
		question_label.text = "Ordena los números de menor a mayor"
	
	# Esta variante requeriría drag & drop
	# Por simplicidad, mostraremos opciones de secuencia
	
	correct_answer = 1  # Simplificado
	generate_number_options(correct_answer, 4)

func generate_simple_addition():
	clear_containers()
	
	# Generar suma simple
	var max_num = 5 + difficulty_level
	var num1 = randi_range(1, max_num)
	var num2 = randi_range(1, max_num)
	correct_answer = num1 + num2
	
	if question_label:
		question_label.text = "%d + %d = ?" % [num1, num2]
	
	# Mostrar grupos visuales
	if objects_container:
		var selected_object = countable_objects[randi() % countable_objects.size()]
		
		# Primer grupo
		var group1 = HBoxContainer.new()
		for i in num1:
			var obj = create_countable_object(selected_object)
			group1.add_child(obj)
		objects_container.add_child(group1)
		
		# Símbolo +
		var plus_label = Label.new()
		plus_label.text = "+"
		plus_label.add_theme_font_size_override("font_size", 64)
		objects_container.add_child(plus_label)
		
		# Segundo grupo
		var group2 = HBoxContainer.new()
		for i in num2:
			var obj = create_countable_object(selected_object)
			group2.add_child(obj)
		objects_container.add_child(group2)
	
	# Generar opciones
	generate_number_options(correct_answer, 4)

func create_countable_object(emoji: String) -> Label:
	var obj_label = Label.new()
	obj_label.text = emoji
	obj_label.add_theme_font_size_override("font_size", 72)
	
	# Posición y rotación aleatorias (efecto más natural)
	obj_label.rotation = randf_range(-0.2, 0.2)
	
	# Animación de aparición
	obj_label.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(obj_label, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
	
	return obj_label

func generate_number_options(correct: int, num_options: int):
	clear_answers_container()
	
	# Generar opciones (una correcta + otras incorrectas)
	var options = [correct]
	
	# Generar opciones incorrectas
	while options.size() < num_options:
		var option = correct + randi_range(-3, 3)
		if option > 0 and option != correct and option not in options:
			options.append(option)
	
	# Mezclar opciones
	options.shuffle()
	
	# Crear botones de respuesta
	for option in options:
		var button = Button.new()
		button.text = str(option)
		
		button.custom_minimum_size = ScreenSizeAdapter.get_adaptive_button_size(Vector2(120, 120))
		
		var font_size = ScreenSizeAdapter.get_adaptive_font_size(64)
		button.add_theme_font_size_override("font_size", font_size)
		
		# Aplicar script de AnimatedButton
		if ResourceLoader.exists("res://scripts/components/AnimatedButton.gd"):
			button.set_script(load("res://scripts/components/AnimatedButton.gd"))
		
		button.pressed.connect(_on_answer_selected.bind(option))
		
		answers_container.add_child(button)

func _on_answer_selected(selected_answer: int):
	attempts += 1
	
	if selected_answer == correct_answer:
		# ¡Respuesta correcta!
		on_correct_answer()
	else:
		# Respuesta incorrecta
		on_wrong_answer()

func on_correct_answer():
	correct_count += 1
	
	# Feedback visual
	if feedback_label:
		feedback_label.text = "¡Correcto! ✓"
		feedback_label.add_theme_color_override("font_color", GameManager.COLOR_SUCCESS)
	
	# Efectos
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 30)
	AudioManager.play_success()
	VoiceInstructions.play_feedback(true, false)
	
	# Actualizar puntaje
	update_score_label()
	
	# Siguiente pregunta
	await get_tree().create_timer(1.5).timeout
	generate_question()

func on_wrong_answer():
	# Feedback visual
	if feedback_label:
		feedback_label.text = "Intenta de nuevo"
		feedback_label.add_theme_color_override("font_color", GameManager.COLOR_ERROR)
	
	# Efectos suaves
	AudioManager.play_error()
	
	# El juego continúa, puede intentar de nuevo
	await get_tree().create_timer(1.0).timeout
	if feedback_label:
		feedback_label.text = ""

func complete_game():
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - start_time
	
	# Calcular estrellas según precisión
	var accuracy = float(correct_count) / float(max_questions)
	var stars = calculate_stars(accuracy)
	
	# Celebración
	celebrate_completion()
	
	# Registrar progreso
	GameManager.complete_game("CountingGame", stars, elapsed_time)
	
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
		score_label.text = "Puntuación: %d / %d" % [correct_count, questions_answered]

func clear_containers():
	if objects_container:
		for child in objects_container.get_children():
			child.queue_free()
	clear_answers_container()

func clear_answers_container():
	if answers_container:
		for child in answers_container.get_children():
			child.queue_free()

func change_mode(new_mode: GameMode):
	current_mode = new_mode
	reset_game()

func change_difficulty(level: int):
	difficulty_level = clampi(level, 1, 5)
	reset_game()

func reset_game():
	correct_count = 0
	attempts = 0
	questions_answered = 0
	start_time = Time.get_ticks_msec() / 1000.0
	setup_game()
	generate_question()
