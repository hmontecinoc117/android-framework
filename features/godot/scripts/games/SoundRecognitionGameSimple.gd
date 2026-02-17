extends Control

# Simple Sound Recognition Game - Asocia emojis con sonidos
var SOUNDS = [
	{"emoji": "🐶", "name": "Perro", "sound": "¡Guau!", "color": Color(0.9, 0.7, 0.5)},
	{"emoji": "🐱", "name": "Gato", "sound": "¡Miau!", "color": Color(1, 0.8, 0.6)},
	{"emoji": "🐮", "name": "Vaca", "sound": "¡Muuu!", "color": Color(0.7, 0.6, 0.5)},
	{"emoji": "🐷", "name": "Cerdo", "sound": "¡Oink!", "color": Color(1, 0.7, 0.8)}
]

var current_sound = 0
var answer_buttons = []

func _ready():
	setup_ui()
	new_question()

func setup_ui():
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.95, 0.9, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Título
	var title = Label.new()
	title.text = "🔊 ¿QUÉ SONIDO ES? 🔊"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 60)
	title.position = Vector2(390, 50)
	title.size = Vector2(1100, 100)
	add_child(title)
	
	# Botón Home
	var home_btn = Button.new()
	home_btn.text = "🏠"
	home_btn.position = Vector2(50, 50)
	home_btn.size = Vector2(120, 120)
	home_btn.add_theme_font_size_override("font_size", 70)
	home_btn.pressed.connect(go_home)
	add_child(home_btn)
	
	# Área del sonido (mostrar el texto del sonido)
	# Este Label se actualizará en new_question()

func new_question():
	# Limpiar botones anteriores
	for btn in answer_buttons:
		btn.queue_free()
	answer_buttons.clear()
	
	# Limpiar sonido anterior
	for child in get_children():
		if child.name == "SoundDisplay":
			child.queue_free()
	
	# Seleccionar sonido aleatorio
	current_sound = randi() % SOUNDS.size()
	
	# Mostrar el sonido (texto grande)
	var sound_label = Label.new()
	sound_label.name = "SoundDisplay"
	sound_label.text = SOUNDS[current_sound].sound
	sound_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sound_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sound_label.position = Vector2(440, 230)
	sound_label.size = Vector2(1000, 250)
	sound_label.add_theme_font_size_override("font_size", 100)
	sound_label.modulate = Color(0.3, 0.3, 0.8)
	add_child(sound_label)
	
	var instruction = Label.new()
	instruction.name = "SoundDisplay"
	instruction.text = "¿Quién hace este sonido?"
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction.position = Vector2(440, 500)
	instruction.size = Vector2(1000, 80)
	instruction.add_theme_font_size_override("font_size", 50)
	add_child(instruction)
	
	# Crear botones de respuesta (2x2)
	var grid_start = Vector2(540, 630)
	var btn_size = Vector2(340, 240)
	var gap = 40
	
	var options = [0, 1, 2, 3]
	options.shuffle()
	
	for i in range(4):
		var row = i / 2
		var col = i % 2
		var pos = grid_start + Vector2(col * (btn_size.x + gap), row * (btn_size.y + gap))
		
		var sound_idx = options[i]
		var btn = Button.new()
		btn.text = SOUNDS[sound_idx].emoji + "\n" + SOUNDS[sound_idx].name
		btn.position = pos
		btn.size = btn_size
		btn.add_theme_font_size_override("font_size", 90)
		
		var style = StyleBoxFlat.new()
		style.bg_color = SOUNDS[sound_idx].color
		style.corner_radius_top_left = 25
		style.corner_radius_top_right = 25
		style.corner_radius_bottom_left = 25
		style.corner_radius_bottom_right = 25
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		
		btn.pressed.connect(_on_answer.bind(sound_idx))
		answer_buttons.append(btn)
		add_child(btn)

func _on_answer(selected_idx):
	if selected_idx == current_sound:
		show_feedback(true)
	else:
		show_feedback(false)

func show_feedback(correct: bool):
	# Limpiar feedback anterior
	for child in get_children():
		if child.name == "Feedback":
			child.queue_free()
	
	var msg = Label.new()
	msg.name = "Feedback"
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.position = Vector2(540, 180)
	msg.size = Vector2(800, 120)
	msg.add_theme_font_size_override("font_size", 70)
	
	if correct:
		msg.text = "¡CORRECTO! 🎉"
		msg.modulate = Color(0, 1, 0)
	else:
		msg.text = "Intenta otra vez 🤔"
		msg.modulate = Color(1, 0.5, 0)
	
	add_child(msg)
	
	if correct:
		await get_tree().create_timer(1.5).timeout
		msg.queue_free()
		new_question()
	else:
		await get_tree().create_timer(1.5).timeout
		msg.queue_free()

func go_home():
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
