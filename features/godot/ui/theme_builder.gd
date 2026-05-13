## Constructor de Theme global: genera un recurso Theme completo
## a partir de las variables de UiGlobals (colores, fuente, espaciado).
## Aplica Fredoka One a Label, Button, RichTextLabel y LineEdit.

class_name ThemeBuilder
extends Node

static func build(ui: Node) -> Theme:
	var theme := Theme.new()

	# Cargar fuente (Fredoka One con fallback)
	var font: Font = ui.get_font() if ui.has_method("get_font") else _load_font(ui)

	# Tamaños adaptativos usando UiGlobals.get_font_size()
	# Tipo explícito int porque ui es Node y la llamada dinámica retorna Variant
	var label_size:  int = ui.get_font_size("label")  if ui.has_method("get_font_size") else ScreenSizeAdapter.get_adaptive_font_size(int(32 * ui.font_scale))
	var button_size: int = ui.get_font_size("button") if ui.has_method("get_font_size") else ScreenSizeAdapter.get_adaptive_font_size(int(44 * ui.font_scale))
	var edit_size:   int = ui.get_font_size("body")   if ui.has_method("get_font_size") else ScreenSizeAdapter.get_adaptive_font_size(int(40 * ui.font_scale))
	var rich_size:   int = ui.get_font_size("body")   if ui.has_method("get_font_size") else ScreenSizeAdapter.get_adaptive_font_size(int(40 * ui.font_scale))

	# ── Label ────────────────────────────────────
	theme.set_color("font_color", "Label", ui.colors["text"])
	theme.set_font_size("font_size", "Label", label_size)
	if font:
		theme.set_font("font", "Label", font)

	# ── RichTextLabel ────────────────────────────
	theme.set_color("default_color", "RichTextLabel", ui.colors["text"])
	theme.set_font_size("normal_font_size", "RichTextLabel", rich_size)
	if font:
		theme.set_font("normal_font", "RichTextLabel", font)
		theme.set_font("bold_font",   "RichTextLabel", font)

	# ── Panel ────────────────────────────────────
	var panel_sb := StyleBoxFlat.new()
	panel_sb.bg_color = ui.colors["surface"]
	panel_sb.corner_radius_top_left     = ui.radii["md"]
	panel_sb.corner_radius_top_right    = ui.radii["md"]
	panel_sb.corner_radius_bottom_left  = ui.radii["md"]
	panel_sb.corner_radius_bottom_right = ui.radii["md"]
	panel_sb.shadow_size  = ui.elevation["md"]
	panel_sb.shadow_color = Color(0, 0, 0, 0.12)
	panel_sb.content_margin_left   = ui.spacing["lg"]
	panel_sb.content_margin_right  = ui.spacing["lg"]
	panel_sb.content_margin_top    = ui.spacing["md"]
	panel_sb.content_margin_bottom = ui.spacing["md"]
	theme.set_stylebox("panel", "Panel", panel_sb)

	# ── Button ───────────────────────────────────
	var btn_normal := _make_button_stylebox(ui.colors["primary"], ui)
	var btn_hover  := _make_button_stylebox(ui.colors["primary_hover"], ui)
	btn_hover.shadow_size = 8

	var btn_pressed := _make_button_stylebox(ui.colors["primary_pressed"], ui)
	btn_pressed.shadow_size       = 0
	btn_pressed.shadow_offset     = Vector2.ZERO
	btn_pressed.border_width_bottom = 1

	var btn_disabled := _make_button_stylebox(Color(0.88, 0.88, 0.88, 1.0), ui)
	btn_disabled.shadow_size = 0

	theme.set_stylebox("normal",   "Button", btn_normal)
	theme.set_stylebox("hover",    "Button", btn_hover)
	theme.set_stylebox("pressed",  "Button", btn_pressed)
	theme.set_stylebox("disabled", "Button", btn_disabled)

	theme.set_color("font_color",          "Button", Color.WHITE)
	theme.set_color("font_color_hover",    "Button", Color.WHITE)
	theme.set_color("font_color_pressed",  "Button", Color(1, 1, 1, 0.9))
	theme.set_color("font_color_disabled", "Button", ui.colors["text_muted"])
	theme.set_constant("hseparation", "Button", ui.spacing["sm"])
	theme.set_font_size("font_size", "Button", button_size)
	if font:
		theme.set_font("font", "Button", font)

	# ── LineEdit ─────────────────────────────────
	var le_normal := StyleBoxFlat.new()
	le_normal.bg_color = ui.colors["surface"]
	le_normal.corner_radius_top_left     = ui.radii["md"]
	le_normal.corner_radius_top_right    = ui.radii["md"]
	le_normal.corner_radius_bottom_left  = ui.radii["md"]
	le_normal.corner_radius_bottom_right = ui.radii["md"]
	le_normal.border_color        = ui.colors["primary"]
	le_normal.border_width_top    = 1
	le_normal.border_width_bottom = 1
	le_normal.border_width_left   = 1
	le_normal.border_width_right  = 1
	le_normal.content_margin_left   = ui.spacing["md"]
	le_normal.content_margin_right  = ui.spacing["md"]
	le_normal.content_margin_top    = ui.spacing["sm"]
	le_normal.content_margin_bottom = ui.spacing["sm"]

	var le_focus := le_normal.duplicate()
	le_focus.border_width_top    = 2
	le_focus.border_width_bottom = 2
	le_focus.border_width_left   = 2
	le_focus.border_width_right  = 2

	theme.set_stylebox("normal", "LineEdit", le_normal)
	theme.set_stylebox("focus",  "LineEdit", le_focus)
	theme.set_color("font_color", "LineEdit", ui.colors["text"])
	theme.set_font_size("font_size", "LineEdit", edit_size)
	if font:
		theme.set_font("font", "LineEdit", font)

	return theme


# ──────────────────────────────────────────────
#  Helpers estáticos privados
# ──────────────────────────────────────────────

static func _make_button_stylebox(bg_color: Color, ui: Node) -> StyleBoxFlat:
	"""StyleBoxFlat de botón con efecto 3D (borde inferior + sombra)."""
	var s := StyleBoxFlat.new()
	s.bg_color    = bg_color
	s.corner_radius_top_left     = ui.radii.get("xl", 32)
	s.corner_radius_top_right    = ui.radii.get("xl", 32)
	s.corner_radius_bottom_left  = ui.radii.get("xl", 32)
	s.corner_radius_bottom_right = ui.radii.get("xl", 32)
	s.content_margin_left   = ui.spacing["xl"]
	s.content_margin_right  = ui.spacing["xl"]
	s.content_margin_top    = ui.spacing["sm"]
	s.content_margin_bottom = ui.spacing["sm"]
	s.border_width_bottom = 5
	s.border_color = bg_color.darkened(0.25)
	s.shadow_color  = Color(0, 0, 0, 0.22)
	s.shadow_size   = 6
	s.shadow_offset = Vector2(0, 3)
	return s


static func _load_font(ui: Node) -> Font:
	"""Carga la fuente del path en ui.font_path con fallback."""
	if ResourceLoader.exists(ui.font_path):
		return load(ui.font_path)
	const FALLBACK := "res://assets/fonts/NotoSans-Bold.ttf"
	if ResourceLoader.exists(FALLBACK):
		return load(FALLBACK)
	return null
