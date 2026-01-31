# VoiceInstructions.gd
# Sistema de instrucciones por voz y feedback
extends Node

# Diccionario de instrucciones por juego
var instructions_dict: Dictionary = {
	"trace_game": "Traza la letra con tu dedo siguiendo la línea punteada",
	"shape_trace_game": "Dibuja la forma siguiendo la guía",
	"memory_game": "Encuentra las parejas tocando las cartas",
	"puzzle_game": "Arrastra las piezas para completar la imagen",
	"matching_game": "Une cada objeto con su pareja",
	"counting_game": "Cuenta cuántos objetos ves",
	"color_by_number_game": "Colorea cada sección con el color que le corresponde",
	"pattern_game": "Completa la secuencia con el elemento correcto",
	"maze_game": "Guía al personaje hasta la salida del laberinto",
	"sound_recognition_game": "Escucha el sonido y elige la imagen correcta"
}

# Feedback positivo variado
var feedbacks_positive: Array[String] = [
	"¡Muy bien!",
	"¡Excelente!",
	"¡Lo lograste!",
	"¡Fantástico!",
	"¡Genial!",
	"¡Perfecto!",
	"¡Increíble!",
	"¡Maravilloso!",
	"¡Súper!",
	"¡Bravo!"
]

# Feedback de ánimo (nunca negativo)
var feedbacks_encourage: Array[String] = [
	"Inténtalo de nuevo",
	"Casi lo logras",
	"Tú puedes",
	"Sigue intentando",
	"Muy cerca",
	"Prueba otra vez",
	"Lo harás mejor",
	"Sigue así"
]

# Label para mostrar texto de instrucciones
var instruction_label: Label
var instruction_timer: Timer

func _ready():
	# Esperar un frame para evitar problemas de inicialización
	await get_tree().process_frame
	setup_instruction_ui()

func setup_instruction_ui():
	# Crear timer para auto-ocultar instrucciones
	instruction_timer = Timer.new()
	instruction_timer.one_shot = true
	instruction_timer.timeout.connect(_on_instruction_timeout)
	add_child(instruction_timer)

func play_instruction(game_name: String):
	var instruction_key = game_name.to_snake_case()
	
	if instructions_dict.has(instruction_key):
		var instruction_text = instructions_dict[instruction_key]
		
		# Reproducir voz
		var audio_manager = get_node_or_null("/root/AudioManager")
		if audio_manager:
			audio_manager.play_voice(instruction_key)
		
		# Mostrar texto
		show_text_instruction(instruction_text)
	else:
		push_warning("No hay instrucción para: " + game_name)

func play_feedback(is_correct: bool, use_voice: bool = true):
	var feedback: String
	var audio_manager = get_node_or_null("/root/AudioManager")
	
	if is_correct:
		feedback = feedbacks_positive[randi() % feedbacks_positive.size()]
		if use_voice and audio_manager:
			audio_manager.play_voice("feedback_positive_" + str(randi() % 5))
		if audio_manager:
			audio_manager.play_success()
	else:
		feedback = feedbacks_encourage[randi() % feedbacks_encourage.size()]
		if use_voice and audio_manager:
			audio_manager.play_voice("feedback_encourage_" + str(randi() % 5))
	
	show_text_instruction(feedback, 2.0)

func show_text_instruction(text: String, duration: float = 5.0):
	# Buscar o crear label de instrucciones
	var root = get_tree().root
	instruction_label = root.find_child("InstructionLabel", true, false)
	
	if not instruction_label:
		# Crear label dinámicamente si no existe
		instruction_label = Label.new()
		instruction_label.name = "InstructionLabel"
		instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		instruction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		instruction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		# Estilo del label
		instruction_label.add_theme_font_size_override("font_size", 48)
		instruction_label.add_theme_color_override("font_color", Color.WHITE)
		instruction_label.add_theme_color_override("font_outline_color", Color.BLACK)
		instruction_label.add_theme_constant_override("outline_size", 4)
		
		# Posicionamiento
		instruction_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
		instruction_label.offset_top = 50
		instruction_label.offset_bottom = 200
		instruction_label.z_index = 100
		
		# Añadir al árbol (buscar CanvasLayer o root)
		var canvas_layer = root.find_child("UILayer", true, false)
		if canvas_layer:
			canvas_layer.add_child(instruction_label)
		else:
			root.add_child(instruction_label)
	
	# Actualizar texto y mostrar
	instruction_label.text = text
	instruction_label.visible = true
	
	# Animación de aparición
	instruction_label.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(instruction_label, "modulate", Color(1, 1, 1, 1), 0.3)
	
	# Auto-ocultar
	instruction_timer.start(duration)

func _on_instruction_timeout():
	if instruction_label and instruction_label.visible:
		# Animación de desaparición
		var tween = create_tween()
		tween.tween_property(instruction_label, "modulate", Color(1, 1, 1, 0), 0.3)
		tween.tween_callback(func(): instruction_label.visible = false)

func hide_instruction():
	if instruction_label:
		instruction_label.visible = false
	instruction_timer.stop()

func get_random_positive_feedback() -> String:
	return feedbacks_positive[randi() % feedbacks_positive.size()]

func get_random_encourage_feedback() -> String:
	return feedbacks_encourage[randi() % feedbacks_encourage.size()]
