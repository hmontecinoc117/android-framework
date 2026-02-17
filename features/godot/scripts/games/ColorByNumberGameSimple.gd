extends Control

# Simple Color by Number Game
var COLORS = [
	{"num": "1", "emoji": "🔴", "color": Color(1, 0.2, 0.2)},
	{"num": "2", "emoji": "🟡", "color": Color(1, 0.9, 0.2)},
	{"num": "3", "emoji": "🟢", "color": Color(0.2, 0.8, 0.2)},
	{"num": "4", "emoji": "🔵", "color": Color(0.2, 0.5, 1)}
]

var PATTERNS = [
	[1, 2, 1, 2, 3, 4, 3, 4],  # Pattern 1
	[1, 1, 2, 2, 3, 3, 4, 4],  # Pattern 2
	[1, 3, 2, 4, 1, 3, 2, 4],  # Pattern 3
]

var current_color = 0
var cells = []
var cell_colors = []
var current_pattern = []

func _ready():
	setup_ui()
	new_drawing()

func setup_ui():
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.9, 0.95, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Título
	var title = Label.new()
	title.text = "🎨 COLOREA POR NÚMEROS 🎨"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 58)
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
	
	# Botón Nuevo
	var new_btn = Button.new()
	new_btn.text = "🆕"
	new_btn.position = Vector2(1710, 50)
	new_btn.size = Vector2(140, 120)
	new_btn.add_theme_font_size_override("font_size", 70)
	new_btn.pressed.connect(new_drawing)
	add_child(new_btn)
	
	# Paleta de colores
	var palette_start = Vector2(440, 200)
	for i in range(4):
		var color_btn = Button.new()
		color_btn.text = COLORS[i].emoji + " " + COLORS[i].num
		color_btn.position = palette_start + Vector2(i * 250, 0)
		color_btn.size = Vector2(230, 130)
		color_btn.add_theme_font_size_override("font_size", 60)
		
		var style = StyleBoxFlat.new()
		style.bg_color = COLORS[i].color
		style.corner_radius_top_left = 20
		style.corner_radius_top_right = 20
		style.corner_radius_bottom_left = 20
		style.corner_radius_bottom_right = 20
		color_btn.add_theme_stylebox_override("normal", style)
		color_btn.add_theme_stylebox_override("hover", style)
		
		color_btn.pressed.connect(_on_color_selected.bind(i))
		add_child(color_btn)
	
	# Grid de celdas 4x2
	var grid_start = Vector2(490, 400)
	var cell_size = 220
	var gap = 30
	
	for i in range(8):
		var row = i / 4
		var col = i % 4
		var pos = grid_start + Vector2(col * (cell_size + gap), row * (cell_size + gap))
		
		var cell = Button.new()
		cell.position = pos
		cell.size = Vector2(cell_size, cell_size)
		cell.add_theme_font_size_override("font_size", 90)
		cell.pressed.connect(_on_cell_pressed.bind(i))
		cells.append(cell)
		add_child(cell)

func new_drawing():
	current_pattern = PATTERNS[randi() % PATTERNS.size()].duplicate()
	cell_colors = []
	for i in range(8):
		cell_colors.append(-1)
	
	update_cells()

func update_cells():
	for i in range(8):
		var target_color = current_pattern[i] - 1
		var cell = cells[i]
		
		if cell_colors[i] == -1:
			# Sin colorear - mostrar número
			cell.text = str(current_pattern[i])
			var style = StyleBoxFlat.new()
			style.bg_color = Color(1, 1, 1)
			style.border_color = Color(0.5, 0.5, 0.5)
			style.border_width_left = 4
			style.border_width_right = 4
			style.border_width_top = 4
			style.border_width_bottom = 4
			style.corner_radius_top_left = 15
			style.corner_radius_top_right = 15
			style.corner_radius_bottom_left = 15
			style.corner_radius_bottom_right = 15
			cell.add_theme_stylebox_override("normal", style)
			cell.add_theme_stylebox_override("hover", style)
			cell.modulate = Color(1, 1, 1)
		else:
			# Coloreado
			cell.text = COLORS[cell_colors[i]].emoji
			var style = StyleBoxFlat.new()
			style.bg_color = COLORS[cell_colors[i]].color
			style.corner_radius_top_left = 15
			style.corner_radius_top_right = 15
			style.corner_radius_bottom_left = 15
			style.corner_radius_bottom_right = 15
			cell.add_theme_stylebox_override("normal", style)
			cell.add_theme_stylebox_override("hover", style)
			
			if cell_colors[i] == target_color:
				cell.modulate = Color(1, 1, 1)
			else:
				cell.modulate = Color(0.6, 0.6, 0.6)
	
	check_complete()

func _on_color_selected(color_idx):
	current_color = color_idx

func _on_cell_pressed(cell_idx):
	cell_colors[cell_idx] = current_color
	update_cells()

func check_complete():
	for i in range(8):
		var target = current_pattern[i] - 1
		if cell_colors[i] != target:
			return
	
	# ¡Completado!
	show_success()

func show_success():
	var msg = Label.new()
	msg.text = "¡PERFECTO! 🌟"
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.position = Vector2(540, 980)
	msg.size = Vector2(800, 120)
	msg.add_theme_font_size_override("font_size", 70)
	msg.modulate = Color(1, 0.8, 0)
	add_child(msg)
	
	await get_tree().create_timer(2.0).timeout
	msg.queue_free()
	new_drawing()

func go_home():
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
