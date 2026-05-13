## Botón con microanimaciones táctiles para niños de 3 años.
## Soporta press, hover, error (shake) y pulse continuo.

@tool
extends Button

# --- Constantes ---
const LOGP := "[AnimatedButton] "

# --- Variables Exportadas ---
@export var hover_scale:       float = 1.06
@export var press_scale:       float = 0.92
@export var animation_duration: float = 0.18
@export var enable_sound:      bool = true
@export var bounce_on_press:   bool = true

# --- Variables Miembro ---
var original_scale: Vector2  = Vector2.ONE
var is_pressed_down: bool    = false
var _hover_tween:  Tween
var _press_tween:  Tween
var _pulse_tween:  Tween
var _error_tween:  Tween


# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	original_scale = scale
	mouse_entered.connect(_on_hover_start)
	mouse_exited.connect(_on_hover_end)
	button_down.connect(_on_press_start)
	button_up.connect(_on_press_end)
	pressed.connect(_on_button_pressed)


# ──────────────────────────────────────────────
#  Callbacks de Señales
# ──────────────────────────────────────────────

func _on_hover_start() -> void:
	if not is_pressed_down and not disabled:
		play_hover()

func _on_hover_end() -> void:
	if not is_pressed_down:
		_animate_scale(original_scale)

func _on_press_start() -> void:
	if disabled:
		return
	is_pressed_down = true
	play_press()
	if enable_sound and AudioManager:
		AudioManager.play_button_press()

func _on_press_end() -> void:
	is_pressed_down = false
	if _is_mouse_hovering():
		_animate_scale(original_scale * hover_scale)
	else:
		_animate_scale(original_scale)

func _on_button_pressed() -> void:
	if bounce_on_press:
		_create_bounce_effect()


# ──────────────────────────────────────────────
#  API Pública — Microanimaciones
# ──────────────────────────────────────────────

## Animación de pulsación al presionar: squish rápido con TRANS_BACK.
func play_press() -> void:
	_kill_tween(_hover_tween)
	_hover_tween = create_tween()
	_hover_tween.set_trans(Tween.TRANS_BACK)
	_hover_tween.set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "scale", original_scale * press_scale, 0.08)
	_hover_tween.tween_property(self, "scale", original_scale,               0.18)


## Animación de hover suave: ligero agrandamiento con TRANS_SINE.
func play_hover() -> void:
	_kill_tween(_hover_tween)
	_hover_tween = create_tween()
	_hover_tween.set_trans(Tween.TRANS_SINE)
	_hover_tween.set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "scale", original_scale * hover_scale, 0.15)


## Shake horizontal para indicar error o acción inválida.
func play_error() -> void:
	_kill_tween(_error_tween)
	var origin_x: float = position.x
	_error_tween = create_tween()
	_error_tween.set_trans(Tween.TRANS_SINE)
	for i: int in 3:
		_error_tween.tween_property(self, "position:x", origin_x + 10.0, 0.05)
		_error_tween.tween_property(self, "position:x", origin_x - 10.0, 0.05)
	_error_tween.tween_property(self, "position:x", origin_x, 0.05)


## Pulso continuo para llamar la atención.
func pulse_animation(duration: float = 1.0, scale_factor: float = 1.2) -> void:
	_kill_tween(_pulse_tween)
	_pulse_tween = create_tween()
	_pulse_tween.set_loops()
	_pulse_tween.set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(self, "scale", original_scale * scale_factor, duration / 2.0)
	_pulse_tween.tween_property(self, "scale", original_scale,                duration / 2.0)


## Detener pulso y restaurar escala.
func stop_pulse() -> void:
	_kill_tween(_pulse_tween)
	scale = original_scale


## Animación de sacudida legada (compatibilidad).
func shake_animation(intensity: float = 10.0, duration: float = 0.3) -> void:
	play_error()


# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _animate_scale(target: Vector2) -> void:
	_kill_tween(_hover_tween)
	_hover_tween = create_tween()
	_hover_tween.set_ease(Tween.EASE_OUT)
	_hover_tween.set_trans(Tween.TRANS_BACK)
	_hover_tween.tween_property(self, "scale", target, animation_duration)


func _create_bounce_effect() -> void:
	_kill_tween(_press_tween)
	_press_tween = create_tween()
	_press_tween.set_ease(Tween.EASE_OUT)
	_press_tween.set_trans(Tween.TRANS_BACK)
	_press_tween.tween_property(self, "scale", original_scale * 1.12, 0.12)
	_press_tween.tween_property(self, "scale", original_scale,        0.18)


func _kill_tween(t: Tween) -> void:
	if t and t.is_running():
		t.kill()


func _is_mouse_hovering() -> bool:
	if not is_inside_tree():
		return false
	return get_global_rect().has_point(get_viewport().get_mouse_position())
