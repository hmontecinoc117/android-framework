## Variables globales de UI: paleta de colores, espaciado, radios,
## escala de fuente y modo de contraste accesible.
## NOTA: Copia de respaldo — la versión activa está en ui/autoload/

#class_name UiGlobals
extends Node

# --- Señales ---
signal settings_changed

# --- Constantes ---
const LOGP := "[UiGlobals] "

# --- Variables Miembro ---
var colors := {
	"primary": Color("6d4aff"),
	"primary_hover": Color("5a3de6"),
	"primary_pressed": Color("4c35cc"),
	"bg": Color("f8f6ff"),
	"surface": Color("ffffff"),
	"text": Color("3a2e5e"),
	"text_muted": Color("7d73a6"),
	"accent_yellow": Color("ffc83d"),
	"accent_pink": Color("ff6dae"),
	"success": Color("2ecc71"),
	"danger": Color("ff4d4f"),
	"tile_hidden": Color("ffffff"),
	"tile_hidden_border": Color("d7cffc"),
	"tile_revealed": Color("fff3c4"),
	"tile_match": Color("c8f7c5")
}

var spacing := { "xs": 6, "sm": 10, "md": 14, "lg": 20, "xl": 28 }
var radii := { "sm": 12, "md": 16, "lg": 24 }
var elevation := { "none": 0, "sm": 2, "md": 4, "lg": 8 }

# Fuente del proyecto
var font_path := "res://assets/fonts/NotoSans-Bold.ttf"

# Accesibilidad
var touch_target_min := 56
var font_scale := 1.0
var contrast_mode := "normal" # "normal" | "high"

# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func set_font_scale(scale: float) -> void:
	font_scale = clamp(scale, 0.8, 1.6)
	settings_changed.emit()

func set_contrast_mode(mode: String) -> void:
	contrast_mode = mode
	if contrast_mode == "high":
		colors["text"] = Color("1e1638")
		colors["primary"] = Color("5a3de6")
		colors["primary_hover"] = Color("4f35d1")
		colors["primary_pressed"] = Color("422cab")
		colors["tile_hidden_border"] = Color("b7aef0")
	else:
		colors["text"] = Color("3a2e5e")
		colors["primary"] = Color("6d4aff")
		colors["primary_hover"] = Color("5a3de6")
		colors["primary_pressed"] = Color("4c35cc")
		colors["tile_hidden_border"] = Color("d7cffc")
	settings_changed.emit()
