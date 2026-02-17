## ButtonHelper - Autoload para facilitar creación de botones touch
extends Node

# Tema compartido
var touch_theme: Theme

func _ready():
	# Cargar tema touch una sola vez
	touch_theme = _create_touch_theme()
	print("✅ ButtonHelper inicializado con tema touch")

# Crear tema optimizado para touch
func _create_touch_theme() -> Theme:
	var theme = Theme.new()
	
	# Normal
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.2, 0.4, 0.6)
	normal.set_content_margin_all(25)
	normal.corner_radius_top_left = 15
	normal.corner_radius_top_right = 15
	normal.corner_radius_bottom_left = 15
	normal.corner_radius_bottom_right = 15
	normal.shadow_size = 5
	normal.shadow_offset = Vector2(2, 2)
	
	# Pressed
	var pressed = StyleBoxFlat.new()
	pressed.bg_color = Color(0.15, 0.3, 0.5)
	pressed.set_content_margin_all(25)
	pressed.corner_radius_top_left = 15
	pressed.corner_radius_top_right = 15
	pressed.corner_radius_bottom_left = 15
	pressed.corner_radius_bottom_right = 15
	
	# Hover
	var hover = StyleBoxFlat.new()
	hover.bg_color = Color(0.25, 0.45, 0.7)
	hover.set_content_margin_all(25)
	hover.corner_radius_top_left = 15
	hover.corner_radius_top_right = 15
	hover.corner_radius_bottom_left = 15
	hover.corner_radius_bottom_right = 15
	
	theme.set_stylebox("normal", "Button", normal)
	theme.set_stylebox("pressed", "Button", pressed)
	theme.set_stylebox("hover", "Button", hover)
	
	theme.set_font_size("font_size", "Button", 80)
	theme.set_color("font_color", "Button", Color.WHITE)
	
	return theme

# Factory method para crear botón touch-ready
func create_button(text: String, min_size: Vector2 = Vector2(500, 200)) -> Button:
	var button = Button.new()
	button.text = text
	button.theme = touch_theme
	button.custom_minimum_size = min_size
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	return button

# Configurar botones existentes
func make_touch_friendly(button: Button, large: bool = true) -> void:
	button.theme = touch_theme
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	
	if large:
		button.custom_minimum_size = Vector2(500, 200)
		button.add_theme_font_size_override("font_size", 90)

# Configurar todos los botones en un nodo
func setup_all_buttons_in(node: Node, large: bool = true) -> void:
	for child in node.get_children():
		if child is Button:
			make_touch_friendly(child, large)
		# Recursivo para botones dentro de contenedores
		if child.get_child_count() > 0:
			setup_all_buttons_in(child, large)
