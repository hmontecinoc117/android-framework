## Juego de colorear por números.
## El jugador selecciona colores y pinta las secciones indicadas.

extends Node2D

# ──────────────────────────────────────────────
#  Señales
# ──────────────────────────────────────────────

signal game_completed(stars: int, time: float)

# ──────────────────────────────────────────────
#  Constantes
# ──────────────────────────────────────────────

const LOGP := "[ColorByNumberGame] "

# ──────────────────────────────────────────────
#  Variables Exportadas
# ──────────────────────────────────────────────

@export var template_name: String = "simple_flower"

# ──────────────────────────────────────────────
#  Variables Miembro — Nodos
# ──────────────────────────────────────────────

var coloring_area: Node = null
var color_palette: Node = null
var progress_bar: ProgressBar = null
var undo_button: Button = null
var clear_button: Button = null

# ──────────────────────────────────────────────
#  Variables Miembro — Datos
# ──────────────────────────────────────────────

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

# ──────────────────────────────────────────────
#  Variables Miembro — Estado
# ──────────────────────────────────────────────

var selected_color_number: int = 0
var sections: Array = []
var colored_sections: int = 0
var total_sections: int = 0
var start_time: float = 0.0
var color_history: Array = []  # Para undo


# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	coloring_area = get_node_or_null("ColoringArea")
	color_palette = get_node_or_null("UI/ColorPalette")
	progress_bar = get_node_or_null("UI/TopBar/ProgressBar")
	undo_button = get_node_or_null("UI/BottomBar/UndoButton")
	clear_button = get_node_or_null("UI/BottomBar/ClearButton")

	_apply_ui_assets()
	_setup_game()
	start_time = Time.get_ticks_msec() / 1000.0
	VoiceInstructions.play_instruction("color_by_number_game")
	print(LOGP, "_ready completado")


# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func change_template(new_template: String) -> void:
	if templates.has(new_template):
		template_name = new_template
		reset_drawing()


func reset_drawing() -> void:
	colored_sections = 0
	color_history.clear()
	selected_color_number = 0
	start_time = Time.get_ticks_msec() / 1000.0

	# Limpiar secciones existentes
	for child in coloring_area.get_children():
		child.queue_free()
	sections.clear()

	_setup_game()


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
	_setup_color_palette()
	_load_coloring_template(template_name)

	if undo_button:
		undo_button.pressed.connect(_on_undo_pressed)
	if clear_button:
		clear_button.pressed.connect(_on_clear_pressed)

	_update_progress()


func _setup_color_palette() -> void:
	if not color_palette:
		return

	# Crear botones de color
	for number in color_map.keys():
		var color_button: Button = Button.new()
		color_button.custom_minimum_size = DesignSystem.BTN_SMALL
		color_button.set_script(load("res://scripts/components/AnimatedButton.gd"))

		# Estilo del botón con el color
		var stylebox: StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = color_map[number]
		stylebox.border_width_all = 3
		stylebox.border_color = Color.BLACK
		color_button.add_theme_stylebox_override("normal", stylebox)

		# Número en el botón
		color_button.text = str(number)
		color_button.add_theme_font_size_override("font_size", DesignSystem.FONT_MEDIUM)
		color_button.add_theme_color_override("font_color", Color.BLACK)

		color_button.pressed.connect(_on_color_selected.bind(number))
		color_palette.add_child(color_button)


func _load_coloring_template(template_key: String) -> void:
	if not templates.has(template_key):
		push_error(LOGP + "Plantilla no encontrada: " + template_key)
		return

	var template: Dictionary = templates[template_key]
	sections.clear()

	total_sections = template["sections"].size()

	# Crear secciones coloreables
	for section_data in template["sections"]:
		var section: Control = _create_coloring_section(section_data)
		coloring_area.add_child(section)
		sections.append(section)


func _create_coloring_section(data: Dictionary) -> Control:
	var section: Panel = Panel.new()
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
	var stylebox: StyleBoxFlat = StyleBoxFlat.new()
	stylebox.bg_color = Color.WHITE
	stylebox.border_width_all = 2
	stylebox.border_color = Color.BLACK
	section.add_theme_stylebox_override("panel", stylebox)

	# Label con el número
	var label: Label = Label.new()
	label.text = str(data["number"])
	DesignSystem.setup_label(label, DesignSystem.FONT_MEDIUM, Color.BLACK)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.name = "NumberLabel"
	section.add_child(label)

	# Conectar input
	section.gui_input.connect(_on_section_input.bind(section))

	return section


# ──────────────────────────────────────────────
#  Funciones Privadas — Lógica del Juego
# ──────────────────────────────────────────────

func _color_section(section: Control, color_number: int) -> void:
	var expected_number: int = section.get_meta("expected_number")

	if color_number == expected_number:
		# ¡Color correcto!
		_apply_color_to_section(section, color_number, true)

		if not section.get_meta("is_colored"):
			colored_sections += 1
			section.set_meta("is_colored", true)

		# Guardar en historial
		color_history.append({"section": section, "correct": true})

		# Efectos de éxito
		AnimationHelper.success_effect(section)
		AudioManager.play_success()

		_update_progress()

		# Verificar si completó
		if colored_sections >= total_sections:
			await get_tree().create_timer(0.5).timeout
			_complete_drawing()
	else:
		# Color incorrecto
		_apply_color_to_section(section, color_number, false)
		AudioManager.play_error()
		AnimationHelper.shake_node(section, 10.0, 0.3)

		# Mostrar brevemente el error y revertir
		await get_tree().create_timer(1.0).timeout
		_reset_section(section)


func _apply_color_to_section(section: Control, color_number: int, correct: bool) -> void:
	var stylebox: StyleBoxFlat = StyleBoxFlat.new()
	stylebox.bg_color = color_map[color_number]

	if correct:
		stylebox.border_width_all = 3
		stylebox.border_color = DesignSystem.get_color("success")
	else:
		stylebox.border_width_all = 3
		stylebox.border_color = DesignSystem.get_color("error")

	section.add_theme_stylebox_override("panel", stylebox)

	# Ocultar número si está correcto
	var label: Label = section.get_node_or_null("NumberLabel")
	if label and correct:
		label.visible = false


func _reset_section(section: Control) -> void:
	var stylebox: StyleBoxFlat = StyleBoxFlat.new()
	stylebox.bg_color = Color.WHITE
	stylebox.border_width_all = 2
	stylebox.border_color = Color.BLACK
	section.add_theme_stylebox_override("panel", stylebox)

	# Mostrar número de nuevo
	var label: Label = section.get_node_or_null("NumberLabel")
	if label:
		label.visible = true


func _highlight_selected_color(color_number: int) -> void:
	# Resaltar el botón de color seleccionado
	for child in color_palette.get_children():
		if child is Button:
			var stylebox: StyleBoxFlat = child.get_theme_stylebox("normal").duplicate() as StyleBoxFlat

			# Verificar si es el seleccionado
			var button_text: String = child.text
			if button_text.is_valid_int() and int(button_text) == color_number:
				stylebox.border_width_all = 5
				stylebox.border_color = Color.GOLD
			else:
				stylebox.border_width_all = 3
				stylebox.border_color = Color.BLACK

			child.add_theme_stylebox_override("normal", stylebox)


func _update_progress() -> void:
	if progress_bar:
		var progress: float = float(colored_sections) / float(total_sections) * 100
		progress_bar.value = progress


func _complete_drawing() -> void:
	var elapsed_time: float = (Time.get_ticks_msec() / 1000.0) - start_time
	var stars: int = _calculate_stars(elapsed_time)

	_celebrate_completion()
	GameManager.complete_game("ColorByNumberGame", stars, elapsed_time)
	game_completed.emit(stars, elapsed_time)
	print(LOGP, "Dibujo completado: estrellas=", stars, " tiempo=", elapsed_time)


func _calculate_stars(time: float) -> int:
	var expected_time: float = total_sections * 8.0  # 8 segundos por sección

	if time < expected_time * 0.6:
		return 3
	elif time < expected_time:
		return 2
	else:
		return 1


func _celebrate_completion() -> void:
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 80)
	AudioManager.play_game_complete()
	VoiceInstructions.play_feedback(true)

	if OS.has_feature("mobile"):
		Input.vibrate_handheld(300)


# ──────────────────────────────────────────────
#  Callbacks de UI
# ──────────────────────────────────────────────

func _on_color_selected(color_number: int) -> void:
	selected_color_number = color_number
	AudioManager.play_button_press()
	_highlight_selected_color(color_number)


func _on_section_input(event: InputEvent, section: Control) -> void:
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
	_color_section(section, selected_color_number)


func _on_undo_pressed() -> void:
	if color_history.is_empty():
		return

	var last_action: Dictionary = color_history.pop_back()
	var section: Control = last_action["section"]

	if last_action["correct"]:
		_reset_section(section)
		section.set_meta("is_colored", false)
		colored_sections -= 1
		_update_progress()

	AudioManager.play_button_press()


func _on_clear_pressed() -> void:
	# Confirmar limpieza
	for section in sections:
		_reset_section(section)
		section.set_meta("is_colored", false)

	colored_sections = 0
	color_history.clear()
	_update_progress()
	AudioManager.play_button_press()
