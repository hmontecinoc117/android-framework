## Plantilla para componentes UI reutilizables.
## [Descripción del componente].

@tool
extends Control

# --- Señales ---
signal value_changed(new_value: Variant)

# --- Variables Exportadas ---
@export var animation_duration: float = 0.2
@export var enable_sound: bool = true

# --- Variables Miembro ---
var original_scale: Vector2 = Vector2.ONE
var _tween: Tween

# --- Variables Onready ---

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	original_scale = scale
	_setup_connections()

# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _setup_connections() -> void:
	pass

func _animate_scale(target: Vector2) -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "scale", target, animation_duration)
