## Arranque visual del framework: aplica el theme global y gestiona
## transiciones fade entre escenas.
## NOTA: Copia de respaldo — la versión activa está en ui/autoload/

#class_name UiBootstrap
extends Node

# --- Constantes ---
const LOGP := "[UiBootstrap] "

# --- Variables Miembro ---
var _fade_layer: CanvasLayer
var _fade_rect: ColorRect

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	# Aplicar theme global
	var theme := ThemeBuilder.build(UiGlobals)
	get_tree().root.theme = theme
	get_tree().root.modulate = Color(1, 1, 1, 1)
	UiGlobals.settings_changed.connect(rebuild_theme)

	# Capa de transición fade
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100
	get_tree().root.add_child(_fade_layer)
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.anchor_right = 1.0
	_fade_rect.anchor_bottom = 1.0
	_fade_layer.add_child(_fade_rect)
	print(LOGP, "_ready completado")

# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func rebuild_theme() -> void:
	var theme := ThemeBuilder.build(UiGlobals)
	get_tree().root.theme = theme

func fade_to_scene(path: String, duration: float = 0.25) -> void:
	var t := create_tween()
	t.tween_property(_fade_rect, "color", Color(0, 0, 0, 1), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.tween_callback(func() -> void:
		get_tree().change_scene_to_file(path)
	)
	t.tween_property(_fade_rect, "color", Color(0, 0, 0, 0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
