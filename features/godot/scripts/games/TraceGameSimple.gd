extends Control

const LOGP := "[TraceGame] "

var drawing: bool = false
var last_point: Vector2 = Vector2.ZERO
var current_color: Color = Color(1, 0, 0)  # Rojo por defecto
var brush_size: float = 20.0

const COLORS := [
	Color(1, 0, 0),      # Rojo
	Color(0, 0, 1),      # Azul
	Color(0, 1, 0),      # Verde
	Color(1, 1, 0),      # Amarillo
	Color(1, 0.5, 0),    # Naranja
	Color(0.5, 0, 0.5),  # Morado
	Color(0, 0, 0),      # Negro
	Color(1, 1, 1)       # Blanco
]

var canvas: Node2D

func _ready():
	print(LOGP, "Iniciando Trace Game...")
	
	# Título
	var title = Label.new()
	title.text = "Dibuja lo que quieras! 🎨"
	title.add_theme_font_size_override("font_size", 60)
	title.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 10
	title.offset_bottom = 80
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	
	# Canvas para dibujar
	canvas = Node2D.new()
	canvas.name = "Canvas"
	add_child(canvas)
	
	# Paleta de colores
	var palette = HBoxContainer.new()
	palette.add_theme_constant_override("separation", 15)
	palette.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	palette.offset_top = -120
	palette.offset_bottom = -20
	palette.offset_left = 100
	palette.offset_right = -100
	palette.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(palette)
	
	for color in COLORS:
		var btn = Button.new()
		btn.text = "●"
		btn.custom_minimum_size = Vector2(100, 90)
		btn.add_theme_font_size_override("font_size", 70)
		var style = StyleBoxFlat.new()
		style.bg_color = color
		style.corner_radius_top_left = 45
		style.corner_radius_top_right = 45
		style.corner_radius_bottom_left = 45
		style.corner_radius_bottom_right = 45
		btn.add_theme_stylebox_override("normal", style)
		btn.pressed.connect(func(): select_color(color))
		palette.add_child(btn)
	
	# Botón limpiar
	var clear_btn = Button.new()
	clear_btn.text = "🗑️"
	clear_btn.custom_minimum_size = Vector2(120, 90)
	clear_btn.add_theme_font_size_override("font_size", 60)
	clear_btn.pressed.connect(clear_canvas)
	palette.add_child(clear_btn)
	
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


func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			drawing = true
			last_point = event.position
		else:
			drawing = false
	elif event is InputEventScreenDrag:
		if drawing:
			draw_line_segment(last_point, event.position)
			last_point = event.position


func draw_line_segment(from: Vector2, to: Vector2):
	# Crear línea visual
	var line = Line2D.new()
	line.width = brush_size
	line.default_color = current_color
	line.add_point(Vector2.ZERO)
	line.add_point(to - from)
	line.position = from
	line.antialiased = true
	canvas.add_child(line)


func select_color(color: Color):
	current_color = color
	print(LOGP, "Color seleccionado:", color)


func clear_canvas():
	print(LOGP, "Limpiando canvas...")
	for child in canvas.get_children():
		child.queue_free()


func go_back():
	get_tree().change_scene_to_file("res://scenes/main/GameSelector.tscn")
