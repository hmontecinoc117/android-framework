## Constructor de Theme global: genera un recurso Theme completo
## a partir de las variables de UiGlobals (colores, fuente, espaciado).

class_name ThemeBuilder
extends Node

static func build(ui: Node) -> Theme:
	var theme := Theme.new()

	var font: Font = null
	if ResourceLoader.exists(ui.font_path):
		font = load(ui.font_path)

	# Usar ScreenSizeAdapter para tamaños adaptativos
	var label_size := ScreenSizeAdapter.get_adaptive_font_size(int(20 * ui.font_scale))
	var button_size := ScreenSizeAdapter.get_adaptive_font_size(int(24 * ui.font_scale))
	var edit_size := ScreenSizeAdapter.get_adaptive_font_size(int(20 * ui.font_scale))

	# Labels
	theme.set_color("font_color", "Label", ui.colors["text"])
	if font:
		theme.set_font("font", "Label", font)
	theme.set_font_size("font_size", "Label", label_size)

	# Panel
	var panel_sb := StyleBoxFlat.new()
	panel_sb.bg_color = ui.colors["surface"]
	panel_sb.corner_radius_top_left = ui.radii["md"]
	panel_sb.corner_radius_top_right = ui.radii["md"]
	panel_sb.corner_radius_bottom_left = ui.radii["md"]
	panel_sb.corner_radius_bottom_right = ui.radii["md"]
	panel_sb.shadow_size = ui.elevation["md"]
	panel_sb.shadow_color = Color(0, 0, 0, 0.12)
	panel_sb.content_margin_left = ui.spacing["lg"]
	panel_sb.content_margin_right = ui.spacing["lg"]
	panel_sb.content_margin_top = ui.spacing["md"]
	panel_sb.content_margin_bottom = ui.spacing["md"]
	theme.set_stylebox("panel", "Panel", panel_sb)

	# Button estándar
	var btn_normal := StyleBoxFlat.new()
	btn_normal.bg_color = ui.colors["primary"]
	btn_normal.corner_radius_top_left = ui.radii["lg"]
	btn_normal.corner_radius_top_right = ui.radii["lg"]
	btn_normal.corner_radius_bottom_left = ui.radii["lg"]
	btn_normal.corner_radius_bottom_right = ui.radii["lg"]
	btn_normal.content_margin_left = ui.spacing["xl"]
	btn_normal.content_margin_right = ui.spacing["xl"]
	btn_normal.content_margin_top = ui.spacing["sm"]
	btn_normal.content_margin_bottom = ui.spacing["sm"]

	var btn_hover := btn_normal.duplicate()
	btn_hover.bg_color = ui.colors["primary_hover"]
	var btn_pressed := btn_normal.duplicate()
	btn_pressed.bg_color = ui.colors["primary_pressed"]
	var btn_disabled := btn_normal.duplicate()
	btn_disabled.bg_color = Color(0.9, 0.9, 0.9, 1.0)

	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_stylebox("hover", "Button", btn_hover)
	theme.set_stylebox("pressed", "Button", btn_pressed)
	theme.set_stylebox("disabled", "Button", btn_disabled)
	theme.set_color("font_color", "Button", Color(1, 1, 1))
	theme.set_color("font_color_hover", "Button", Color(1, 1, 1))
	theme.set_color("font_color_pressed", "Button", Color(1, 1, 1))
	theme.set_color("font_color_disabled", "Button", ui.colors["text_muted"])
	theme.set_constant("hseparation", "Button", ui.spacing["sm"])
	if font:
		theme.set_font("font", "Button", font)
	theme.set_font_size("font_size", "Button", button_size)

	# LineEdit
	var le_normal := StyleBoxFlat.new()
	le_normal.bg_color = ui.colors["surface"]
	le_normal.corner_radius_top_left = ui.radii["md"]
	le_normal.corner_radius_top_right = ui.radii["md"]
	le_normal.corner_radius_bottom_left = ui.radii["md"]
	le_normal.corner_radius_bottom_right = ui.radii["md"]
	le_normal.border_color = ui.colors["primary"]
	le_normal.border_width_top = 1
	le_normal.border_width_bottom = 1
	le_normal.border_width_left = 1
	le_normal.border_width_right = 1
	le_normal.content_margin_left = ui.spacing["md"]
	le_normal.content_margin_right = ui.spacing["md"]
	le_normal.content_margin_top = ui.spacing["sm"]
	le_normal.content_margin_bottom = ui.spacing["sm"]

	var le_focus := le_normal.duplicate()
	le_focus.border_width_top = 2
	le_focus.border_width_bottom = 2
	le_focus.border_width_left = 2
	le_focus.border_width_right = 2

	theme.set_stylebox("normal", "LineEdit", le_normal)
	theme.set_stylebox("focus", "LineEdit", le_focus)
	theme.set_color("font_color", "LineEdit", ui.colors["text"])
	if font:
		theme.set_font("font", "LineEdit", font)
	theme.set_font_size("font_size", "LineEdit", edit_size)

	# MemoryTile aplica sus propios overrides directamente — no necesita variación en theme global.

	return theme
