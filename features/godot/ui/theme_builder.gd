extends Node
class_name ThemeBuilder

static func build(ui: UiGlobals) -> Theme:
	var theme := Theme.new()

	# Button styles
	var normal := StyleBoxFlat.new()
	normal.bg_color = ui.colors["primary"]
	normal.corner_radius_top_left = ui.radii["md"]
	normal.corner_radius_top_right = ui.radii["md"]
	normal.corner_radius_bottom_left = ui.radii["md"]
	normal.corner_radius_bottom_right = ui.radii["md"]
	normal.content_margin_left = ui.spacing["md"]
	normal.content_margin_right = ui.spacing["md"]
	normal.content_margin_top = ui.spacing["sm"]
	normal.content_margin_bottom = ui.spacing["sm"]

	var hover := normal.duplicate()
	hover.bg_color = ui.colors["primary"].lightened(0.06)

	var pressed := normal.duplicate()
	pressed.bg_color = ui.colors["primary"].darkened(0.06)

	var disabled := normal.duplicate()
	disabled.bg_color = ui.colors["primary"].darkened(0.18)
	disabled.border_width_top = 0
	disabled.border_width_bottom = 0

	theme.set_color("font_color", "Button", ui.colors["text_on_primary"])
	theme.set_color("font_color_pressed", "Button", ui.colors["text_on_primary"])
	theme.set_color("font_color_hover", "Button", ui.colors["text_on_primary"])
	theme.set_stylebox("normal", "Button", normal)
	theme.set_stylebox("hover", "Button", hover)
	theme.set_stylebox("pressed", "Button", pressed)
	theme.set_stylebox("disabled", "Button", disabled)
	theme.set_constant("min_height", "Button", ui.sizes["button_height"])
	theme.set_constant("h_separation", "Button", ui.spacing["sm"])

	# Panel style
	var panel := StyleBoxFlat.new()
	panel.bg_color = ui.colors["surface"]
	panel.border_color = ui.colors["primary"].darkened(0.25)
	panel.border_width_all = 2
	panel.corner_radius_top_left = ui.radii["lg"]
	panel.corner_radius_top_right = ui.radii["lg"]
	panel.corner_radius_bottom_left = ui.radii["lg"]
	panel.corner_radius_bottom_right = ui.radii["lg"]
	panel.content_margin_left = ui.spacing["lg"]
	panel.content_margin_right = ui.spacing["lg"]
	panel.content_margin_top = ui.spacing["lg"]
	panel.content_margin_bottom = ui.spacing["lg"]
	theme.set_stylebox("panel", "Panel", panel)

	# Labels
	theme.set_color("font_color", "Label", ui.colors["text"])

	return theme
