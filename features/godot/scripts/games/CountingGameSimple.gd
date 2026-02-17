extends Control

const LOGP := "[CountingGame] "

var target_number: int = 0
var current_count: int = 0
var objects: Array = []

func _ready():
	print(LOGP, "Iniciando Counting Game...")
	
	# Número objetivo aleatorio entre 3 y 8
	target_number = randi_range(3, 8)
	
	# Instrucción
	var instruction = Label.new()
	instruction.text = "Cuenta los 🍎\n¿Cuántas hay?"
	instruction.add_theme_font_size_override("font_size", 70)
	instruction.add_theme_color_override("font_color", Color.WHITE)
	instruction.set_anchors_preset(Control.PRESET_TOP_WIDE)
	instruction.offset_top = 20
	instruction.offset_bottom = 200
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(instruction)
	
	# Crear manzanas aleatorias
	for i in target_number:
		var apple = Label.new()
		apple.text = "🍎"
		apple.add_theme_font_size_override("font_size", 120)
		apple.position = Vector2(
			randf_range(200, 1700),
			randf_range(250, 800)
		)
		add_child(apple)
		objects.append(apple)
	
	# Botones de números (1 al 10)
	var buttons_container = HBoxContainer.new()
	buttons_container.add_theme_constant_override("separation", 15)
	buttons_container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	buttons_container.offset_top = -150
	buttons_container.offset_bottom = -20
	buttons_container.offset_left = 100
	buttons_container.offset_right = -100
	buttons_container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(buttons_container)
	
	for i in range(1, 11):
		var btn = Button.new()
		btn.text = str(i)
		btn.custom_minimum_size = Vector2(140, 120)
		btn.add_theme_font_size_override("font_size", 70)
		btn.pressed.connect(func(): check_answer(i))
		buttons_container.add_child(btn)
	
	# Botón volver
	var back_btn = Button.new()
	back_btn.text = "🏠"
	back_btn.custom_minimum_size = Vector2(100, 100)
	back_btn.add_theme_font_size_override("font_size", 60)
	back_btn.set_anchors_preset(Control.PRESET_TOP_LEFT)
	back_btn.offset_left = 20
	back_btn.offset_top = 20
	back_btn.offset_right = 120
	back_btn.offset_bottom = 120
	back_btn.pressed.connect(go_back)
	add_child(back_btn)
	
	print(LOGP, "✅ Juego creado - número correcto:", target_number)


func check_answer(selected: int):
	print(LOGP, "Seleccionado:", selected, "Correcto:", target_number)
	
	if selected == target_number:
		show_result("¡CORRECTO! 🎉\n¡Bien hecho!", Color(0, 1, 0))
		await get_tree().create_timer(2.0).timeout
		go_back()
	else:
		show_result("Intenta otra vez 🤔", Color(1, 0.5, 0))
		await get_tree().create_timer(1.5).timeout
		# Limpiar mensaje
		for child in get_children():
			if child.name == "ResultLabel":
				child.queue_free()


func show_result(text: String, color: Color):
	# Eliminar mensaje anterior si existe
	for child in get_children():
		if child.name == "ResultLabel":
			child.queue_free()
	
	var label = Label.new()
	label.name = "ResultLabel"
	label.text = text
	label.add_theme_font_size_override("font_size", 100)
	label.add_theme_color_override("font_color", color)
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.offset_left = -500
	label.offset_right = 500
	label.offset_top = -100
	label.offset_bottom = 100
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)


func go_back():
	get_tree().change_scene_to_file("res://scenes/main/GameSelector.tscn")
