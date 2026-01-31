# ThemeManager.gd
# Gestor de temas visuales y personalización
extends Node

enum ThemeStyle {
	DEFAULT,
	SPACE,
	UNDERWATER,
	FOREST,
	CANDY
}

var current_theme: ThemeStyle = ThemeStyle.DEFAULT

var theme_palettes: Dictionary = {
	ThemeStyle.DEFAULT: {
		"background": Color("#E8F4F8"),
		"primary": Color("#4A90E2"),
		"secondary": Color("#F5A623"),
		"accent": Color("#7ED321")
	},
	ThemeStyle.SPACE: {
		"background": Color("#1A1A2E"),
		"primary": Color("#0F3460"),
		"secondary": Color("#E94560"),
		"accent": Color("#FFD700")
	},
	ThemeStyle.UNDERWATER: {
		"background": Color("#C1E1EC"),
		"primary": Color("#1E90FF"),
		"secondary": Color("#00CED1"),
		"accent": Color("#FFD700")
	},
	ThemeStyle.FOREST: {
		"background": Color("#E8F5E9"),
		"primary": Color("#4CAF50"),
		"secondary": Color("#8BC34A"),
		"accent": Color("#FFEB3B")
	},
	ThemeStyle.CANDY: {
		"background": Color("#FFF0F5"),
		"primary": Color("#FF69B4"),
		"secondary": Color("#FFB6C1"),
		"accent": Color("#FFA500")
	}
}

signal theme_changed(theme: ThemeStyle)

func _ready():
	pass

func apply_theme(theme: ThemeStyle):
	current_theme = theme
	var palette = theme_palettes[theme]
	
	# Aplicar a todos los nodos con el método "apply_theme_colors"
	apply_theme_to_tree(get_tree().root, palette)
	
	theme_changed.emit(theme)
	print("Tema aplicado: ", ThemeStyle.keys()[theme])

func apply_theme_to_tree(node: Node, palette: Dictionary):
	# Verificar si el nodo tiene método personalizado de tema
	if node.has_method("apply_theme_colors"):
		node.apply_theme_colors(palette)
	
	# Aplicar a controles estándar
	if node is Control:
		apply_theme_to_control(node, palette)
	
	# Recursivo para hijos
	for child in node.get_children():
		apply_theme_to_tree(child, palette)

func apply_theme_to_control(control: Control, palette: Dictionary):
	# Aplicar colores según tipo de control
	if control is Panel:
		if control.has_theme_stylebox_override("panel"):
			var stylebox = control.get_theme_stylebox("panel").duplicate()
			if stylebox is StyleBoxFlat:
				stylebox.bg_color = palette["background"]
				control.add_theme_stylebox_override("panel", stylebox)
	
	elif control is Button:
		if control.has_theme_stylebox_override("normal"):
			var stylebox = control.get_theme_stylebox("normal").duplicate()
			if stylebox is StyleBoxFlat:
				stylebox.bg_color = palette["primary"]
				control.add_theme_stylebox_override("normal", stylebox)

func get_current_palette() -> Dictionary:
	return theme_palettes[current_theme]

func get_color(color_name: String) -> Color:
	var palette = theme_palettes[current_theme]
	return palette.get(color_name, Color.WHITE)

func set_theme_by_name(theme_name: String):
	match theme_name.to_lower():
		"default":
			apply_theme(ThemeStyle.DEFAULT)
		"space", "espacio":
			apply_theme(ThemeStyle.SPACE)
		"underwater", "submarino":
			apply_theme(ThemeStyle.UNDERWATER)
		"forest", "bosque":
			apply_theme(ThemeStyle.FOREST)
		"candy", "dulce":
			apply_theme(ThemeStyle.CANDY)
		_:
			push_warning("Tema desconocido: " + theme_name)
