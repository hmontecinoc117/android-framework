## Variables globales de UI: paleta de colores, espaciado, radios,
## escala de fuente y modo de contraste accesible.
## Sincronizado con DesignSystem.gd — usa la misma paleta infantil.

extends Node

# --- Señales ---
signal settings_changed

# --- Constantes ---
const LOGP := "[UiGlobals] "

const FONT_PATH_PRIMARY  := "res://assets/fonts/FredokaOne-Regular.ttf"
const FONT_PATH_FALLBACK := "res://assets/fonts/NotoSans-Bold.ttf"

# Tamaños de fuente base (se escalan con ScreenSizeAdapter en ThemeBuilder)
const FONT_SIZE_TITLE      := 72   # Títulos principales
const FONT_SIZE_SUBTITLE   := 52   # Subtítulos
const FONT_SIZE_BODY       := 40   # Texto general
const FONT_SIZE_BUTTON     := 44   # Texto en botones
const FONT_SIZE_HUD        := 36   # TopBar / HUD
const FONT_SIZE_LABEL      := 32   # Labels de formulario

# --- Variables Miembro ---
var colors := {
	# Paleta infantil optimizada contraste AA
	"primary":          Color("#FF6B35"),
	"primary_hover":    Color("#FF8C5A"),
	"primary_pressed":  Color("#E55A24"),
	"secondary":        Color("#4ECDC4"),
	"success":          Color("#44CF6C"),
	"warning":          Color("#FFD93D"),
	"error":            Color("#FF6B6B"),
	"bg":               Color("#FFF8F0"),
	"background_dark":  Color("#FFE8D6"),
	"surface":          Color("#FFFFFF"),
	"card_back":        Color("#A8DAFF"),
	"card_back_border": Color("#5BA8D9"),
	"text":             Color("#2D2D2D"),
	"text_muted":       Color("#7A7A7A"),
	"star_gold":        Color("#FFD700"),
	# Colores legacy para MemoryTile (compat)
	"tile_hidden":        Color("#A8DAFF"),
	"tile_hidden_border": Color("#5BA8D9"),
	"tile_revealed":      Color("#FFFFFF"),
	"tile_match":         Color("#44CF6C"),
}

# Espaciado y radio siguiendo design_tokens.json
var spacing := { "xs": 6, "sm": 10, "md": 14, "lg": 20, "xl": 28 }
var radii   := { "sm": 12, "md": 16, "lg": 24, "xl": 32 }
var elevation := { "none": 0, "sm": 2, "md": 4, "lg": 8 }

# Fuente del proyecto — Fredoka One con fallback a NotoSans
var font_path: String = FONT_PATH_PRIMARY

# Accesibilidad y tamaños mínimos
var touch_target_min := 180
var font_scale       := 1.0
var contrast_mode    := "normal"  # "normal" | "high"


# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func get_font() -> Font:
	"""Retorna la fuente activa (Fredoka One si existe, sino NotoSans)."""
	if ResourceLoader.exists(font_path):
		return load(font_path)
	if ResourceLoader.exists(FONT_PATH_FALLBACK):
		return load(FONT_PATH_FALLBACK)
	return null


func get_font_size(semantic: String) -> int:
	"""Retorna tamaño de fuente adaptativo por nombre semántico."""
	var base := _get_base_font_size(semantic)
	return ScreenSizeAdapter.get_adaptive_font_size(int(base * font_scale))


func set_font_scale(scale: float) -> void:
	font_scale = clamp(scale, 0.8, 1.6)
	settings_changed.emit()


func set_contrast_mode(mode: String) -> void:
	contrast_mode = mode
	if contrast_mode == "high":
		colors["text"]    = Color("#1A1A1A")
		colors["primary"] = Color("#E55A24")
		colors["primary_hover"]   = Color("#FF6B35")
		colors["primary_pressed"] = Color("#CC4A1A")
	else:
		colors["text"]    = Color("#2D2D2D")
		colors["primary"] = Color("#FF6B35")
		colors["primary_hover"]   = Color("#FF8C5A")
		colors["primary_pressed"] = Color("#E55A24")
	settings_changed.emit()


# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _get_base_font_size(semantic: String) -> int:
	match semantic:
		"title":    return FONT_SIZE_TITLE
		"subtitle": return FONT_SIZE_SUBTITLE
		"body":     return FONT_SIZE_BODY
		"button":   return FONT_SIZE_BUTTON
		"hud":      return FONT_SIZE_HUD
		"label":    return FONT_SIZE_LABEL
		_:          return FONT_SIZE_BODY
