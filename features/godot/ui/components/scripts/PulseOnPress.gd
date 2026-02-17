## Efecto de pulso al presionar un botón: escala brevemente
## hacia abajo y vuelve al tamaño original.

extends Button

# --- Constantes ---
const LOGP := "[PulseOnPress] "

# --- Variables Onready ---
@onready var _tween: Tween = create_tween()

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	custom_minimum_size = Vector2(UiGlobals.touch_target_min, UiGlobals.touch_target_min)
	focus_mode = Control.FOCUS_ALL
	connect("pressed", _on_pressed)

# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _on_pressed() -> void:
	_tween.kill()
	scale = Vector2.ONE
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
