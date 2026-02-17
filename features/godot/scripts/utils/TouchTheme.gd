## TouchTheme - Tema optimizado para controles táctiles en Android
extends Resource
class_name TouchTheme

# Configuración base para botones touch-friendly
static func create_touch_button_theme() -> Theme:
	var theme = Theme.new()
	
	# StyleBox Normal
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.2, 0.3, 0.5, 1.0)  # Azul
	normal.set_content_margin_all(30)  # Área táctil grande
	normal.corner_radius_top_left = 20
	normal.corner_radius_top_right = 20
	normal.corner_radius_bottom_left = 20
	normal.corner_radius_bottom_right = 20
	
	# StyleBox Hover (retroalimentación visual)
	var hover = StyleBoxFlat.new()
	hover.bg_color = Color(0.3, 0.4, 0.6, 1.0)  # Azul más claro
	hover.set_content_margin_all(30)
	hover.corner_radius_top_left = 20
	hover.corner_radius_top_right = 20
	hover.corner_radius_bottom_left = 20
	hover.corner_radius_bottom_right = 20
	
	# StyleBox Pressed
	var pressed = StyleBoxFlat.new()
	pressed.bg_color = Color(0.1, 0.2, 0.4, 1.0)  # Azul oscuro
	pressed.set_content_margin_all(30)
	pressed.corner_radius_top_left = 20
	pressed.corner_radius_top_right = 20
	pressed.corner_radius_bottom_left = 20
	pressed.corner_radius_bottom_right = 20
	
	# StyleBox Disabled
	var disabled = StyleBoxFlat.new()
	disabled.bg_color = Color(0.3, 0.3, 0.3, 1.0)  # Gris
	disabled.set_content_margin_all(30)
	disabled.corner_radius_top_left = 20
	disabled.corner_radius_top_right = 20
	disabled.corner_radius_bottom_left = 20
	disabled.corner_radius_bottom_right = 20
	
	# Aplicar al tema
	theme.set_stylebox("normal", "Button", normal)
	theme.set_stylebox("hover", "Button", hover)
	theme.set_stylebox("pressed", "Button", pressed)
	theme.set_stylebox("disabled", "Button", disabled)
	
	# Configurar fuente grande para touch
	theme.set_font_size("font_size", "Button", 80)
	theme.set_color("font_color", "Button", Color.WHITE)
	theme.set_color("font_pressed_color", "Button", Color(0.9, 0.9, 0.9))
	theme.set_color("font_hover_color", "Button", Color(1.0, 1.0, 0.8))
	theme.set_color("font_disabled_color", "Button", Color(0.6, 0.6, 0.6))
	
	return theme

# Configurar un botón individual para ser touch-friendly
static func setup_touch_button(button: Button) -> void:
	# Tamaño mínimo grande
	button.custom_minimum_size = Vector2(400, 200)
	
	# Desactivar focus (evita conflictos con teclado virtual)
	button.focus_mode = Control.FOCUS_NONE
	
	# Action mode: responder al press (más rápido en touch)
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	
	# Habilitar feedback
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

# Crear botones grandes pre-configurados
static func create_large_button(text: String, callback: Callable) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(600, 250)
	button.add_theme_font_size_override("font_size", 100)
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	
	if callback:
		button.pressed.connect(callback)
	
	return button

# Configuración para contenedores de botones
static func setup_button_container(container: Container) -> void:
	# Separación entre botones para evitar clicks accidentales
	if container is VBoxContainer:
		container.add_theme_constant_override("separation", 40)
	elif container is HBoxContainer:
		container.add_theme_constant_override("separation", 40)
	elif container is GridContainer:
		container.add_theme_constant_override("h_separation", 40)
		container.add_theme_constant_override("v_separation", 40)
