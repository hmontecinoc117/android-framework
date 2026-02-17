extends Control

const LOGP := "[PatternGame] "

const COLORS := [
	{"emoji": "🔴", "color": Color(1, 0.2, 0.2)},
	{"emoji": "🔵", "color": Color(0.2, 0.4, 1)},
	{"emoji": "🟢", "color": Color(0.2, 1, 0.2)},
	{"emoji": "🟡", "color": Color(1, 1, 0.2)}
]

var pattern: Array = []
var player_input: Array = []
var pattern_length: int = 3
var showing_pattern: bool = false

func _ready():
	print(LOGP, "Iniciando Pattern Game...")
	
	# Título
	var title = Label.new()
	title.text = "Repite la secuencia 🎯"
	title.add_theme_font_size_override("font_size", 70)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 20
	title.offset_bottom = 120
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	
	# Área de demostración
	var demo_container = HBoxContainer.new()
	demo_container.name = "DemoContainer"
	demo_container.add_theme_constant_override("separation", 20)
	demo_container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	demo_container.offset_top = 150
	demo_container.offset_bottom = 350
	demo_container.offset_left = -400
	demo_container.offset_right = 400
	demo_container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(demo_container)
	
	# Botones de colores
	var buttons_container = HBoxContainer.new()
	buttons_container.name = "ButtonsContainer"
	buttons_container.add_theme_constant_override("separation", 30)
	buttons_container.set_anchors_preset(Control.PRESET_CENTER)
	buttons_container.offset_top = 100
	buttons_container.offset_bottom = 300
	buttons_container.offset_left = -500
	buttons_container.offset_right = 500
	buttons_container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(buttons_container)
	
	for i in COLORS.size():
		var btn = Button.new()
		btn.text = COLORS[i]["emoji"]
		btn.custom_minimum_size = Vector2(220, 220)
		btn.add_theme_font_size_override("font_size", 120)
		btn.focus_mode = Control.FOCUS_NONE
		var style = StyleBoxFlat.new()
		style.bg_color = COLORS[i]["color"]
		style.corner_radius_top_left = 110
		style.corner_radius_top_right = 110
		style.corner_radius_bottom_left = 110
		style.corner_radius_bottom_right = 110
		btn.add_theme_stylebox_override("normal", style)
		btn.pressed.connect(func(): on_color_pressed(i))
		btn.disabled = true  # Deshabilitado hasta que se muestre el patrón
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
	
	print(LOGP, "✅ Juego creado")
	
	# Comenzar juego
	await get_tree().create_timer(1.0).timeout
	start_round()


func start_round():
	# Generar patrón aleatorio
	pattern.clear()
	player_input.clear()
	
	for i in pattern_length:
		pattern.append(randi() % COLORS.size())
	
	print(LOGP, "Patrón generado:", pattern)
	show_pattern()


func show_pattern():
	showing_pattern = true
	var demo = get_node("DemoContainer")
	
	# Limpiar demostración anterior
	for child in demo.get_children():
		child.queue_free()
	
	# Mostrar patrón
	for i in pattern.size():
		await get_tree().create_timer(0.8).timeout
		var color_idx = pattern[i]
		
		# Crear círculo del color
		var circle = ColorRect.new()
		circle.custom_minimum_size = Vector2(150, 150)
		circle.color = COLORS[color_idx]["color"]
		demo.add_child(circle)
		
		# Mostrar emoji
		var label = Label.new()
		label.text = COLORS[color_idx]["emoji"]
		label.add_theme_font_size_override("font_size", 100)
		label.set_anchors_preset(Control.PRESET_CENTER)
		label.offset_left = -75
		label.offset_right = 75
		label.offset_top = -75
		label.offset_bottom = 75
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		circle.add_child(label)
	
	# Esperar y luego permitir input
	await get_tree().create_timer(1.5).timeout
	showing_pattern = false
	enable_buttons(true)


func enable_buttons(enabled: bool):
	var buttons = get_node("ButtonsContainer")
	for btn in buttons.get_children():
		btn.disabled = not enabled


func on_color_pressed(color_idx: int):
	if showing_pattern:
		return
	
	print(LOGP, "Color presionado:", color_idx)
	player_input.append(color_idx)
	
	# Verificar input
	var current_idx = player_input.size() - 1
	if player_input[current_idx] != pattern[current_idx]:
		# Error
		show_result("¡Ups! Intenta de nuevo", Color(1, 0.3, 0.3))
		await get_tree().create_timer(1.5).timeout
		start_round()
		return
	
	# Si completó el patrón correctamente
	if player_input.size() == pattern.size():
		show_result("¡PERFECTO! 🎉", Color(0, 1, 0))
		await get_tree().create_timer(2.0).timeout
		
		# Aumentar dificultad y siguiente ronda
		if pattern_length < 6:
			pattern_length += 1
		start_round()


func show_result(text: String, color: Color):
	var label = Label.new()
	label.name = "ResultLabel"
	label.text = text
	label.add_theme_font_size_override("font_size", 90)
	label.add_theme_color_override("font_color", color)
	label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	label.offset_top = -200
	label.offset_bottom = -50
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	
	await get_tree().create_timer(1.5).timeout
	label.queue_free()


func go_back():
	get_tree().change_scene_to_file("res://scenes/main/GameSelector.tscn")
