# SoundRecognitionGame.gd
# Juego de reconocimiento de sonidos
extends Node2D

signal game_completed(stars: int, time: float)

@export var sound_category: String = "animals"  # animals, instruments, vehicles

# Nodos
var play_sound_button
var options_container
var score_label
var feedback_label
var sound_player

# Variables
var current_sound: String = ""
var current_sound_data: Dictionary = {}
var questions_answered: int = 0
var correct_count: int = 0
var max_questions: int = 8
var start_time: float = 0.0

# Categorías de sonidos
const SOUND_CATEGORIES = {
	"animals": {
		"name": "Animales",
		"instruction": "¿Qué animal hace este sonido?",
		"sounds": [
			{"id": "dog", "name": "Perro", "emoji": "🐶", "sound": "res://assets/sounds/animals/dog_bark.ogg"},
			{"id": "cat", "name": "Gato", "emoji": "🐱", "sound": "res://assets/sounds/animals/cat_meow.ogg"},
			{"id": "cow", "name": "Vaca", "emoji": "🐮", "sound": "res://assets/sounds/animals/cow_moo.ogg"},
			{"id": "lion", "name": "León", "emoji": "🦁", "sound": "res://assets/sounds/animals/lion_roar.ogg"},
			{"id": "bird", "name": "Pájaro", "emoji": "🐦", "sound": "res://assets/sounds/animals/bird_chirp.ogg"},
			{"id": "frog", "name": "Rana", "emoji": "🐸", "sound": "res://assets/sounds/animals/frog_croak.ogg"}
		]
	},
	"instruments": {
		"name": "Instrumentos",
		"instruction": "¿Qué instrumento suena?",
		"sounds": [
			{"id": "piano", "name": "Piano", "emoji": "🎹", "sound": "res://assets/sounds/instruments/piano.ogg"},
			{"id": "guitar", "name": "Guitarra", "emoji": "🎸", "sound": "res://assets/sounds/instruments/guitar.ogg"},
			{"id": "drums", "name": "Tambor", "emoji": "🥁", "sound": "res://assets/sounds/instruments/drums.ogg"},
			{"id": "trumpet", "name": "Trompeta", "emoji": "🎺", "sound": "res://assets/sounds/instruments/trumpet.ogg"},
			{"id": "violin", "name": "Violín", "emoji": "🎻", "sound": "res://assets/sounds/instruments/violin.ogg"}
		]
	},
	"vehicles": {
		"name": "Vehículos",
		"instruction": "¿Qué vehículo hace este ruido?",
		"sounds": [
			{"id": "car", "name": "Carro", "emoji": "🚗", "sound": "res://assets/sounds/vehicles/car.ogg"},
			{"id": "airplane", "name": "Avión", "emoji": "✈️", "sound": "res://assets/sounds/vehicles/airplane.ogg"},
			{"id": "train", "name": "Tren", "emoji": "🚂", "sound": "res://assets/sounds/vehicles/train.ogg"},
			{"id": "motorcycle", "name": "Moto", "emoji": "🏍️", "sound": "res://assets/sounds/vehicles/motorcycle.ogg"},
			{"id": "boat", "name": "Barco", "emoji": "🚤", "sound": "res://assets/sounds/vehicles/boat.ogg"}
		]
	},
	"nature": {
		"name": "Naturaleza",
		"instruction": "¿Qué sonido de la naturaleza es?",
		"sounds": [
			{"id": "rain", "name": "Lluvia", "emoji": "🌧️", "sound": "res://assets/sounds/nature/rain.ogg"},
			{"id": "thunder", "name": "Trueno", "emoji": "⚡", "sound": "res://assets/sounds/nature/thunder.ogg"},
			{"id": "wind", "name": "Viento", "emoji": "💨", "sound": "res://assets/sounds/nature/wind.ogg"},
			{"id": "ocean", "name": "Olas", "emoji": "🌊", "sound": "res://assets/sounds/nature/ocean.ogg"},
			{"id": "fire", "name": "Fuego", "emoji": "🔥", "sound": "res://assets/sounds/nature/fire.ogg"}
		]
	}
}

func _ready():
	# Obtener nodos
	play_sound_button = get_node_or_null("UI/PlaySoundButton")
	options_container = get_node_or_null("UI/OptionsContainer")
	score_label = get_node_or_null("UI/TopBar/ScoreLabel")
	feedback_label = get_node_or_null("UI/FeedbackLabel")

	apply_ui_assets()
	
	setup_game()
	generate_question()
	start_time = Time.get_ticks_msec() / 1000.0
		VoiceInstructions.play_instruction("sound_recognition_game")
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
	
	# Configurar reproductor de sonido
	if not sound_player:
		sound_player = AudioStreamPlayer.new()
		add_child(sound_player)

func setup_game():
	update_score_label()
	
	# Conectar botón de reproducir
	if play_sound_button:
		play_sound_button.pressed.connect(_on_play_sound_pressed)
		
		# Hacer el botón más atractivo
		var label = Label.new()
		label.text = "🔊 Escuchar"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 48)
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		play_sound_button.add_child(label)

func generate_question():
	questions_answered += 1
	
	if questions_answered > max_questions:
		complete_game()
		return
	
	clear_containers()
	
	# Seleccionar sonido aleatorio de la categoría
	var category_data = SOUND_CATEGORIES.get(sound_category, SOUND_CATEGORIES["animals"])
	var sounds = category_data["sounds"]
	
	current_sound_data = sounds[randi() % sounds.size()]
	current_sound = current_sound_data["id"]
	
	# Mostrar instrucción
	if feedback_label:
		feedback_label.text = category_data["instruction"]
		feedback_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Generar opciones (4 imágenes)
	generate_visual_options(sounds)
	
	# Reproducir sonido automáticamente la primera vez
	await get_tree().create_timer(0.5).timeout
	play_current_sound()

func generate_visual_options(sounds: Array):
	if not options_container:
		return
	
	# Seleccionar opciones (una correcta + 3 incorrectas)
	var options = [current_sound_data]
	
	# Añadir opciones incorrectas
	var available_sounds = sounds.duplicate()
	available_sounds.erase(current_sound_data)
	available_sounds.shuffle()
	
	for i in mini(3, available_sounds.size()):
		options.append(available_sounds[i])
	
	# Mezclar opciones
	options.shuffle()
	
	# Crear botones visuales
	for option in options:
		var button = create_option_button(option)
		options_container.add_child(button)

func create_option_button(sound_data: Dictionary) -> Button:
	var button = Button.new()
	
	button.custom_minimum_size = ScreenSizeAdapter.get_adaptive_button_size(Vector2(180, 180))
	
	if ResourceLoader.exists("res://scripts/components/AnimatedButton.gd"):
		button.set_script(load("res://scripts/components/AnimatedButton.gd"))
	
	# Contenedor vertical para emoji + texto
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	button.add_child(vbox)
	
	# Emoji grande
	var emoji_label = Label.new()
	emoji_label.text = sound_data["emoji"]
	emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji_label.add_theme_font_size_override("font_size", 72)
	vbox.add_child(emoji_label)
	
	# Nombre
	var name_label = Label.new()
	name_label.text = sound_data["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 28)
	vbox.add_child(name_label)
	
	# Conectar señal
	button.pressed.connect(_on_option_selected.bind(sound_data))
	
	return button

func _on_play_sound_pressed():
	play_current_sound()

func play_current_sound():
	if not current_sound_data.has("sound"):
		return
	
	var sound_path = current_sound_data["sound"]
	
	# Verificar si el archivo existe
	if not ResourceLoader.exists(sound_path):
		# Fallback: reproducir sonido placeholder o usar TTS
		print("Sonido no encontrado: " + sound_path)
		
		# Alternativa: reproducir descripción por voz
		if current_sound_data.has("name"):
				VoiceInstructions.show_text_instruction("Sonido: " + current_sound_data["name"], 2.0)
		return
	
	# Cargar y reproducir sonido
	var sound = load(sound_path)
	if sound_player and sound:
		sound_player.stream = sound
		sound_player.play()
		
		# Animación del botón
		if play_sound_button:
			AnimationHelper.bounce_node(play_sound_button, 1.3, 0.5)

func _on_option_selected(selected_data: Dictionary):
	var is_correct = selected_data["id"] == current_sound
	
	if is_correct:
		on_correct_answer(selected_data)
	else:
		on_wrong_answer(selected_data)

func on_correct_answer(selected_data: Dictionary):
	correct_count += 1
	
	# Feedback visual
	if feedback_label:
		feedback_label.text = "¡Correcto! Es un " + selected_data["name"]
		feedback_label.add_theme_color_override("font_color", GameManager.COLOR_SUCCESS)
	
	# Efectos
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 40)
	AudioManager.play_success()
	VoiceInstructions.play_feedback(true, false)
	
	update_score_label()
	
	# Siguiente pregunta
	await get_tree().create_timer(2.0).timeout
	generate_question()

func on_wrong_answer(selected_data: Dictionary):
	# Feedback visual
	if feedback_label:
		feedback_label.text = "Intenta de nuevo. No es un " + selected_data["name"]
		feedback_label.add_theme_color_override("font_color", GameManager.COLOR_ERROR)
	
	# Efecto suave
	AudioManager.play_error()
	
	# Reproducir el sonido de nuevo como pista
	await get_tree().create_timer(1.0).timeout
	play_current_sound()
	
	await get_tree().create_timer(1.5).timeout
	if feedback_label:
		var category_data = SOUND_CATEGORIES.get(sound_category, SOUND_CATEGORIES["animals"])
		feedback_label.text = category_data["instruction"]
		feedback_label.add_theme_color_override("font_color", Color.WHITE)

func complete_game():
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - start_time
	var accuracy = float(correct_count) / float(max_questions)
	var stars = calculate_stars(accuracy)
	
	celebrate_completion()
	GameManager.complete_game("SoundRecognitionGame", stars, elapsed_time)
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
		score_label.text = "Puntuación: %d / %d" % [correct_count, questions_answered - 1]

func clear_containers():
	if options_container:
		for child in options_container.get_children():
			child.queue_free()

func change_category(new_category: String):
	if SOUND_CATEGORIES.has(new_category):
		sound_category = new_category
		reset_game()

func reset_game():
	questions_answered = 0
	correct_count = 0
	start_time = Time.get_ticks_msec() / 1000.0
	setup_game()
	generate_question()
