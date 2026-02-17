## Juego de reconocimiento de sonidos.
## El jugador escucha un sonido y selecciona la opción visual correcta
## entre varias alternativas con emoji y nombre.

extends Node2D

# --- Señales ---
signal game_completed(stars: int, time: float)

# --- Constantes ---
const LOGP := "[SoundRecognitionGame] "

const SOUND_CATEGORIES: Dictionary = {
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

# --- Variables Exportadas ---
@export var sound_category: String = "animals"

# --- Variables Miembro ---
var play_sound_button: Button
var options_container: Node
var score_label: Label
var feedback_label: Label
var sound_player: AudioStreamPlayer

var current_sound: String = ""
var current_sound_data: Dictionary = {}
var questions_answered: int = 0
var correct_count: int = 0
var max_questions: int = 8
var start_time: float = 0.0


# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	# Obtener nodos
	play_sound_button = get_node_or_null("UI/PlaySoundButton")
	options_container = get_node_or_null("UI/OptionsContainer")
	score_label = get_node_or_null("UI/TopBar/ScoreLabel")
	feedback_label = get_node_or_null("UI/FeedbackLabel")

	_apply_ui_assets()

	# Configurar reproductor de sonido
	if not sound_player:
		sound_player = AudioStreamPlayer.new()
		add_child(sound_player)

	_setup_game()
	_generate_question()
	start_time = Time.get_ticks_msec() / 1000.0
	VoiceInstructions.play_instruction("sound_recognition_game")
	print(LOGP, "_ready completado")


# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func change_category(new_category: String) -> void:
	if SOUND_CATEGORIES.has(new_category):
		sound_category = new_category
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

	# Conectar botón de reproducir
	if play_sound_button:
		play_sound_button.pressed.connect(_on_play_sound_pressed)

		# Hacer el botón más atractivo
		var label := Label.new()
		label.text = "🔊 Escuchar"
		DesignSystem.setup_label(label, DesignSystem.FONT_LARGE, Color.WHITE)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		play_sound_button.add_child(label)


# ──────────────────────────────────────────────
#  Funciones Privadas — Lógica
# ──────────────────────────────────────────────

func _generate_question() -> void:
	questions_answered += 1

	if questions_answered > max_questions:
		_complete_game()
		return

	_clear_containers()

	# Seleccionar sonido aleatorio de la categoría
	var category_data: Dictionary = SOUND_CATEGORIES.get(sound_category, SOUND_CATEGORIES["animals"])
	var sounds: Array = category_data["sounds"]

	current_sound_data = sounds[randi() % sounds.size()]
	current_sound = current_sound_data["id"]

	# Mostrar instrucción
	if feedback_label:
		feedback_label.text = category_data["instruction"]
		feedback_label.add_theme_color_override("font_color", Color.WHITE)

	# Generar opciones (4 imágenes)
	_generate_visual_options(sounds)

	# Reproducir sonido automáticamente la primera vez
	await get_tree().create_timer(0.5).timeout
	_play_current_sound()


func _generate_visual_options(sounds: Array) -> void:
	if not options_container:
		return

	# Seleccionar opciones (una correcta + 3 incorrectas)
	var options: Array = [current_sound_data]

	# Añadir opciones incorrectas
	var available_sounds: Array = sounds.duplicate()
	available_sounds.erase(current_sound_data)
	available_sounds.shuffle()

	for i in mini(3, available_sounds.size()):
		options.append(available_sounds[i])

	# Mezclar opciones
	options.shuffle()

	# Crear botones visuales
	for option in options:
		var button: Button = _create_option_button(option)
		options_container.add_child(button)


func _create_option_button(sound_data: Dictionary) -> Button:
	var button := Button.new()

	button.custom_minimum_size = DesignSystem.BTN_EXTRA_LARGE

	if ResourceLoader.exists("res://scripts/components/AnimatedButton.gd"):
		button.set_script(load("res://scripts/components/AnimatedButton.gd"))

	# Contenedor vertical para emoji + texto
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	button.add_child(vbox)

	# Emoji grande
	var emoji_label := Label.new()
	emoji_label.text = sound_data["emoji"]
	DesignSystem.setup_label(emoji_label, DesignSystem.FONT_XLARGE, Color.WHITE)
	emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(emoji_label)

	# Nombre
	var name_label := Label.new()
	name_label.text = sound_data["name"]
	DesignSystem.setup_label(name_label, DesignSystem.FONT_SMALL, Color.WHITE)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	# Conectar señal
	button.pressed.connect(_on_option_selected.bind(sound_data))

	return button


func _play_current_sound() -> void:
	if not current_sound_data.has("sound"):
		return

	var sound_path: String = current_sound_data["sound"]

	# Verificar si el archivo existe
	if not ResourceLoader.exists(sound_path):
		# Fallback: reproducir sonido placeholder o usar TTS
		print(LOGP, "Sonido no encontrado: ", sound_path)

		# Alternativa: reproducir descripción por voz
		if current_sound_data.has("name"):
			VoiceInstructions.show_text_instruction("Sonido: " + current_sound_data["name"], 2.0)
		return

	# Cargar y reproducir sonido
	var sound := load(sound_path)
	if sound_player and sound:
		sound_player.stream = sound
		sound_player.play()

		# Animación del botón
		if play_sound_button:
			AnimationHelper.bounce_node(play_sound_button, 1.3, 0.5)


func _on_correct_answer(selected_data: Dictionary) -> void:
	correct_count += 1

	# Feedback visual
	if feedback_label:
		feedback_label.text = "¡Correcto! Es un " + selected_data["name"]
		feedback_label.add_theme_color_override("font_color", DesignSystem.get_color("success"))

	# Efectos
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 40)
	AudioManager.play_success()
	VoiceInstructions.play_feedback(true, false)

	_update_score_label()

	# Siguiente pregunta
	await get_tree().create_timer(2.0).timeout
	_generate_question()


func _on_wrong_answer(selected_data: Dictionary) -> void:
	# Feedback visual
	if feedback_label:
		feedback_label.text = "Intenta de nuevo. No es un " + selected_data["name"]
		feedback_label.add_theme_color_override("font_color", DesignSystem.get_color("error"))

	# Efecto suave
	AudioManager.play_error()

	# Reproducir el sonido de nuevo como pista
	await get_tree().create_timer(1.0).timeout
	_play_current_sound()

	await get_tree().create_timer(1.5).timeout
	if feedback_label:
		var category_data: Dictionary = SOUND_CATEGORIES.get(sound_category, SOUND_CATEGORIES["animals"])
		feedback_label.text = category_data["instruction"]
		feedback_label.add_theme_color_override("font_color", Color.WHITE)


func _complete_game() -> void:
	var elapsed_time: float = (Time.get_ticks_msec() / 1000.0) - start_time
	var accuracy: float = float(correct_count) / float(max_questions)
	var stars: int = _calculate_stars(accuracy)

	_celebrate_completion()
	GameManager.complete_game("SoundRecognitionGame", stars, elapsed_time)
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


func _update_score_label() -> void:
	if score_label:
		score_label.text = "Puntuación: %d / %d" % [correct_count, questions_answered - 1]


func _clear_containers() -> void:
	if options_container:
		for child in options_container.get_children():
			child.queue_free()


# ──────────────────────────────────────────────
#  Callbacks de UI
# ──────────────────────────────────────────────

func _on_play_sound_pressed() -> void:
	_play_current_sound()


func _on_option_selected(selected_data: Dictionary) -> void:
	var is_correct: bool = selected_data["id"] == current_sound

	if is_correct:
		_on_correct_answer(selected_data)
	else:
		_on_wrong_answer(selected_data)
