# TraceGame.gd - Juego simple de trazado
extends Control

@onready var instruction_label = $UI/InstructionLabel
@onready var back_button = $UI/BackButton
@onready var drawing_area = $DrawingArea
@onready var canvas = $DrawingArea/Canvas

var is_drawing = false
var last_point = Vector2.ZERO
var points_drawn = 0

func _ready():
	print("TraceGame _ready()")
	set_process_input(true)

	apply_ui_assets()
	
	if instruction_label:
		instruction_label.text = "Dibuja con tu dedo en la pantalla"
		instruction_label.add_theme_font_size_override("font_size", 100)
	
	if back_button:
		back_button.custom_minimum_size = Vector2(300, 150)
		back_button.add_theme_font_size_override("font_size", 80)
		back_button.text = "← Salir"
		back_button.focus_mode = Control.FOCUS_NONE
		back_button.pressed.connect(_on_back_pressed)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			is_drawing = true
			last_point = event.position
			print("🖌️ Empezó a dibujar en:", event.position)
		else:
			is_drawing = false
			print("✋ Dejó de dibujar. Puntos:", points_drawn)
			if points_drawn > 50:
				show_success()
	
	elif event is InputEventScreenDrag and is_drawing:
		draw_line_segment(last_point, event.position)
		last_point = event.position
		points_drawn += 1
	
	# Check back button manually
	if event is InputEventScreenTouch and not event.pressed:
		if back_button and back_button.get_global_rect().has_point(event.position):
			print("🎯 BACK BUTTON")
			_on_back_pressed()

func draw_line_segment(from: Vector2, to: Vector2):
	if canvas:
		canvas.queue_redraw()
	
func show_success():
	print("🎉 ¡Completado!")
	if instruction_label:
		instruction_label.text = "¡Muy bien! 🎉"
	await get_tree().create_timer(2.0).timeout
	_on_back_pressed()

func _on_back_pressed():
	print("⬅️ Volviendo a selector")
	# Usar cambio diferido para evitar errores !is_inside_tree()
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main/GameSelector.tscn")

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

	# Botón atrás estilo
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
