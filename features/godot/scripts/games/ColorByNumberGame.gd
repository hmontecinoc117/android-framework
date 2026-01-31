# ColorByNumberGame.gd
# Juego de colorear por números
extends Node2D

signal game_completed(stars: int, time: float)

@export var template_name: String = "simple_flower"

# Nodos
var coloring_area
var color_palette
var progress_bar
var undo_button
var clear_button

# Variables
var color_map: Dictionary = {
	1: Color.RED,
	2: Color.BLUE,
	3: Color.GREEN,
	4: Color.YELLOW,
	5: Color.ORANGE,
	6: Color.PURPLE,
	7: Color.PINK,
	8: Color.BROWN
}

var selected_color_number: int = 0
var sections: Array = []
var colored_sections: int = 0
var total_sections: int = 0
var start_time: float = 0.0
var color_history: Array = []  # Para undo

# Plantillas de dibujos
var templates: Dictionary = {
	"simple_flower": {
		"sections": [
			{"number": 1, "position": Vector2(400, 300), "type": "circle"},  # Centro rojo
			{"number": 4, "position": Vector2(400, 200), "type": "petal"},   # Pétalo amarillo
			{"number": 4, "position": Vector2(500, 300), "type": "petal"},
			{"number": 4, "position": Vector2(400, 400), "type": "petal"},
			{"number": 4, "position": Vector2(300, 300), "type": "petal"},
			{"number": 3, "position": Vector2(400, 450), "type": "stem"}     # Tallo verde
		]
	},
	"house": {
		"sections": [
			{"number": 1, "position": Vector2(400, 400), "type": "square"},  # Paredes rojas
			{"number": 2, "position": Vector2(400, 250), "type": "triangle"}, # Techo azul
			{"number": 5, "position": Vector2(380, 450), "type": "rect"},    # Puerta naranja
			{"number": 6, "position": Vector2(350, 350), "type": "rect"}     # Ventana morada
		]
	},
	"car": {
		"sections": [
			{"number": 1, "position": Vector2(400, 350), "type": "rect"},    # Cuerpo rojo
			{"number": 2, "position": Vector2(400, 300), "type": "rect"},    # Cabina azul
			{"number": 8, "position": Vector2(350, 400), "type": "circle"},  # Rueda marrón
			{"number": 8, "position": Vector2(450, 400), "type": "circle"}   # Rueda marrón
		]
	}
}

func _ready():
	# Obtener nodos
	coloring_area = get_node_or_null("ColoringArea")
	color_palette = get_node_or_null("UI/ColorPalette")
	progress_bar = get_node_or_null("UI/TopBar/ProgressBar")
	undo_button = get_node_or_null("UI/BottomBar/UndoButton")
	clear_button = get_node_or_null("UI/BottomBar/ClearButton")

	apply_ui_assets()
	
	setup_game()
	start_time = Time.get_ticks_msec() / 1000.0
		VoiceInstructions.play_instruction("color_by_number_game")

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
	# Crear paleta de colores
	setup_color_palette()
	
	# Cargar plantilla de dibujo
	load_coloring_template(template_name)
	
	# Conectar botones
	if undo_button:
		undo_button.pressed.connect(_on_undo_pressed)
	if clear_button:
		clear_button.pressed.connect(_on_clear_pressed)
	
	update_progress()

func setup_color_palette():
	if not color_palette:
		return
	
	# Crear botones de color
	for number in color_map.keys():
		var color_button = Button.new()
		color_button.custom_minimum_size = Vector2(80, 80)
		color_button.set_script(load("res://scripts/components/AnimatedButton.gd"))
		
		# Estilo del botón con el color
		var stylebox = StyleBoxFlat.new()
		stylebox.bg_color = color_map[number]
		stylebox.border_width_all = 3
		stylebox.border_color = Color.BLACK
		color_button.add_theme_stylebox_override("normal", stylebox)
		
		# Número en el botón
		color_button.text = str(number)
		color_button.add_theme_font_size_override("font_size", 36)
		color_button.add_theme_color_override("font_color", Color.BLACK)
		
		color_button.pressed.connect(_on_color_selected.bind(number))
		color_palette.add_child(color_button)

func load_coloring_template(template_key: String):
	if not templates.has(template_key):
		push_error("Plantilla no encontrada: " + template_key)
		return
	
	var template = templates[template_key]
	sections.clear()
	
	total_sections = template["sections"].size()
	
	# Crear secciones coloreables
	for section_data in template["sections"]:
		var section = create_coloring_section(section_data)
		coloring_area.add_child(section)
		sections.append(section)

func create_coloring_section(data: Dictionary) -> Control:
	var section = Panel.new()
	section.position = data["position"]
	section.set_meta("expected_number", data["number"])
	section.set_meta("is_colored", false)
	
	# Tamaño según tipo
	match data["type"]:
		"circle":
			section.custom_minimum_size = Vector2(80, 80)
		"petal":
			section.custom_minimum_size = Vector2(60, 100)
		"square", "rect":
			section.custom_minimum_size = Vector2(100, 100)
		"triangle":
			section.custom_minimum_size = Vector2(120, 80)
		"stem":
			section.custom_minimum_size = Vector2(40, 150)
		_:
			section.custom_minimum_size = Vector2(80, 80)
	
	section.pivot_offset = section.custom_minimum_size / 2
	
	# Estilo inicial (blanco con número)
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color.WHITE
	stylebox.border_width_all = 2
	stylebox.border_color = Color.BLACK
	section.add_theme_stylebox_override("panel", stylebox)
	
	# Label con el número
	var label = Label.new()
	label.text = str(data["number"])
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 32)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.name = "NumberLabel"
	section.add_child(label)
	
	# Conectar input
	section.gui_input.connect(_on_section_input.bind(section))
	
	return section

func _on_color_selected(color_number: int):
	selected_color_number = color_number
	AudioManager.play_button_press()
	
	# Highlight del color seleccionado
	highlight_selected_color(color_number)

func highlight_selected_color(color_number: int):
	# Resaltar el botón de color seleccionado
	for child in color_palette.get_children():
		if child is Button:
			var stylebox = child.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
			
			# Verificar si es el seleccionado
			var button_text = child.text
			if button_text.is_valid_int() and int(button_text) == color_number:
				stylebox.border_width_all = 5
				stylebox.border_color = Color.GOLD
			else:
				stylebox.border_width_all = 3
				stylebox.border_color = Color.BLACK
			
			child.add_theme_stylebox_override("normal", stylebox)

func _on_section_input(event: InputEvent, section: Control):
	if not event is InputEventMouseButton and not event is InputEventScreenTouch:
		return
	
	if not event.pressed:
		return
	
	if selected_color_number == 0:
		# No hay color seleccionado
		AudioManager.play_error()
		VoiceInstructions.show_text_instruction("Selecciona un color primero", 2.0)
		return
	
	# Colorear sección
	color_section(section, selected_color_number)

func color_section(section: Control, color_number: int):
	var expected_number = section.get_meta("expected_number")
	
	if color_number == expected_number:
		# ¡Color correcto!
		apply_color_to_section(section, color_number, true)
		
		if not section.get_meta("is_colored"):
			colored_sections += 1
			section.set_meta("is_colored", true)
		
		# Guardar en historial
		color_history.append({"section": section, "correct": true})
		
		# Efectos de éxito
		AnimationHelper.success_effect(section)
		AudioManager.play_success()
		
		update_progress()
		
		# Verificar si completó
		if colored_sections >= total_sections:
			await get_tree().create_timer(0.5).timeout
			complete_drawing()
	else:
		# Color incorrecto
		apply_color_to_section(section, color_number, false)
		AudioManager.play_error()
		AnimationHelper.shake_node(section, 10.0, 0.3)
		
		# Mostrar brevemente el error y revertir
		await get_tree().create_timer(1.0).timeout
		reset_section(section)

func apply_color_to_section(section: Control, color_number: int, correct: bool):
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = color_map[color_number]
	
	if correct:
		stylebox.border_width_all = 3
		stylebox.border_color = GameManager.COLOR_SUCCESS
	else:
		stylebox.border_width_all = 3
		stylebox.border_color = GameManager.COLOR_ERROR
	
	section.add_theme_stylebox_override("panel", stylebox)
	
	# Ocultar número si está correcto
	var label = section.get_node_or_null("NumberLabel")
	if label and correct:
		label.visible = false

func reset_section(section: Control):
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color.WHITE
	stylebox.border_width_all = 2
	stylebox.border_color = Color.BLACK
	section.add_theme_stylebox_override("panel", stylebox)
	
	# Mostrar número de nuevo
	var label = section.get_node_or_null("NumberLabel")
	if label:
		label.visible = true

func _on_undo_pressed():
	if color_history.is_empty():
		return
	
	var last_action = color_history.pop_back()
	var section = last_action["section"]
	
	if last_action["correct"]:
		reset_section(section)
		section.set_meta("is_colored", false)
		colored_sections -= 1
		update_progress()
	
	AudioManager.play_button_press()

func _on_clear_pressed():
	# Confirmar limpieza
	for section in sections:
		reset_section(section)
		section.set_meta("is_colored", false)
	
	colored_sections = 0
	color_history.clear()
	update_progress()
	AudioManager.play_button_press()

func update_progress():
	if progress_bar:
		var progress = float(colored_sections) / float(total_sections) * 100
		progress_bar.value = progress

func complete_drawing():
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - start_time
	var stars = calculate_stars(elapsed_time)
	
	celebrate_completion()
	GameManager.complete_game("ColorByNumberGame", stars, elapsed_time)
	game_completed.emit(stars, elapsed_time)

func calculate_stars(time: float) -> int:
	var expected_time = total_sections * 8.0  # 8 segundos por sección
	
	if time < expected_time * 0.6:
		return 3
	elif time < expected_time:
		return 2
	else:
		return 1

func celebrate_completion():
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 80)
	AudioManager.play_game_complete()
	VoiceInstructions.play_feedback(true)
	
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(300)

func change_template(new_template: String):
	if templates.has(new_template):
		template_name = new_template
		reset_drawing()

func reset_drawing():
	colored_sections = 0
	color_history.clear()
	selected_color_number = 0
	start_time = Time.get_ticks_msec() / 1000.0
	
	# Limpiar secciones existentes
	for child in coloring_area.get_children():
		child.queue_free()
	sections.clear()
	
	setup_game()
