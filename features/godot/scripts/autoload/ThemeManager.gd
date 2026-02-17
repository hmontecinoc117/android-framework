## Gestor de temas visuales y personalización de colores.
## Permite cambiar paletas de colores y aplicarlas
## recursivamente a todos los nodos de la escena.

extends Node

# --- Señales ---
signal theme_changed(theme: ThemeStyle)

# --- Enums ---
enum ThemeStyle {
	DEFAULT,
	SPACE,
	UNDERWATER,
	FOREST,
	CANDY
}

# --- Constantes ---
const LOGP := "[ThemeManager] "

# --- Variables Miembro ---
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


# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	pass


# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func apply_theme(theme: ThemeStyle) -> void:
	current_theme = theme
	var palette: Dictionary = theme_palettes[theme]

	# Aplicar a todos los nodos con el método "apply_theme_colors"
	_apply_theme_to_tree(get_tree().root, palette)

	theme_changed.emit(theme)
	print(LOGP, "Tema aplicado: ", ThemeStyle.keys()[theme])


func get_current_palette() -> Dictionary:
	return theme_palettes[current_theme]


func get_color(color_name: String) -> Color:
	var palette: Dictionary = theme_palettes[current_theme]
	return palette.get(color_name, Color.WHITE)


func set_theme_by_name(theme_name: String) -> void:
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
			push_warning(LOGP + "Tema desconocido: " + theme_name)


# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _apply_theme_to_tree(node: Node, palette: Dictionary) -> void:
	## Aplica la paleta de colores recursivamente a todos los nodos.
	if node.has_method("apply_theme_colors"):
		node.apply_theme_colors(palette)

	# Aplicar a controles estándar
	if node is Control:
		_apply_theme_to_control(node, palette)

	# Recursivo para hijos
	for child: Node in node.get_children():
		_apply_theme_to_tree(child, palette)


func _apply_theme_to_control(control: Control, palette: Dictionary) -> void:
	## Aplica colores según tipo de control.
	if control is Panel:
		if control.has_theme_stylebox_override("panel"):
			var stylebox: StyleBox = control.get_theme_stylebox("panel").duplicate()
			if stylebox is StyleBoxFlat:
				stylebox.bg_color = palette["background"]
				control.add_theme_stylebox_override("panel", stylebox)

	elif control is Button:
		if control.has_theme_stylebox_override("normal"):
			var stylebox: StyleBox = control.get_theme_stylebox("normal").duplicate()
			if stylebox is StyleBoxFlat:
				stylebox.bg_color = palette["primary"]
				control.add_theme_stylebox_override("normal", stylebox)
