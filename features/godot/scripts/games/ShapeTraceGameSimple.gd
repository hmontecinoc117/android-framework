extends Control

# Simple Shape Trace Game - Traza las formas
var SHAPES = [
	{"name": "Círculo", "emoji": "⭕", "color": Color(1, 0.3, 0.3)},
	{"name": "Estrella", "emoji": "⭐", "color": Color(1, 0.9, 0.2)},
	{"name": "Corazón", "emoji": "❤️", "color": Color(1, 0.2, 0.5)},
	{"name": "Cuadrado", "emoji": "🟦", "color": Color(0.3, 0.5, 1)}
]

var current_shape = 0
var drawing = false
var line_points = []
var drawn_lines = []

func _ready():
	setup_ui()
	new_shape()

func setup_ui():
	# Background gradient
	var bg = ColorRect.new()
	bg.color = Color(0.95, 0.95, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Título
	var title = Label.new()
	title.text = "✏️ TRAZA LA FORMA ✏️"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 60)
	title.position = Vector2(440, 50)
	title.size = Vector2(1000, 100)
	add_child(title)
	
	# Botón Home
	var home_btn = Button.new()
	home_btn.text = "🏠"
	home_btn.position = Vector2(50, 50)
	home_btn.size = Vector2(120, 120)
	home_btn.add_theme_font_size_override("font_size", 70)
	home_btn.pressed.connect(go_home)
	add_child(home_btn)
	
	# Botón Siguiente
	var next_btn = Button.new()
	next_btn.text = "➡️"
	next_btn.position = Vector2(1710, 50)
	next_btn.size = Vector2(140, 120)
	next_btn.add_theme_font_size_override("font_size", 70)
	next_btn.pressed.connect(new_shape)
	add_child(next_btn)
	
	# Botón Borrar
	var clear_btn = Button.new()
	clear_btn.text = "🗑️"
	clear_btn.position = Vector2(850, 1000)
	clear_btn.size = Vector2(140, 120)
	clear_btn.add_theme_font_size_override("font_size", 70)
	clear_btn.pressed.connect(clear_drawing)
	add_child(clear_btn)

func new_shape():
	clear_drawing()
	current_shape = randi() % SHAPES.size()
	
	# Mostrar la forma a trazar
	for child in get_children():
		if child.name == "ShapeDisplay":
			child.queue_free()
	
	var shape_label = Label.new()
	shape_label.name = "ShapeDisplay"
	shape_label.text = SHAPES[current_shape].emoji
	shape_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shape_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	shape_label.position = Vector2(740, 200)
	shape_label.size = Vector2(400, 400)
	shape_label.add_theme_font_size_override("font_size", 280)
	shape_label.modulate = SHAPES[current_shape].color
	shape_label.modulate.a = 0.3
	add_child(shape_label)
	
	var name_label = Label.new()
	name_label.name = "ShapeDisplay"
	name_label.text = "Traza: " + SHAPES[current_shape].name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.position = Vector2(540, 630)
	name_label.size = Vector2(800, 80)
	name_label.add_theme_font_size_override("font_size", 50)
	add_child(name_label)

func clear_drawing():
	line_points.clear()
	for line in drawn_lines:
		line.queue_free()
	drawn_lines.clear()

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Área de dibujo
			if event.position.y > 720 and event.position.y < 980:
				drawing = true
				line_points.clear()
		else:
			if drawing:
				drawing = false
				if line_points.size() > 5:
					create_permanent_line()
				line_points.clear()
	
	elif event is InputEventMouseMotion and drawing:
		if event.position.y > 720 and event.position.y < 980:
			line_points.append(event.position)
			queue_redraw()

func _draw():
	if line_points.size() > 1:
		var color = SHAPES[current_shape].color
		for i in range(line_points.size() - 1):
			draw_line(line_points[i], line_points[i + 1], color, 12.0)

func create_permanent_line():
	var line = Line2D.new()
	line.default_color = SHAPES[current_shape].color
	line.width = 12
	line.points = PackedVector2Array(line_points)
	add_child(line)
	drawn_lines.append(line)

func go_home():
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
