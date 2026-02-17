## Botón con animaciones automáticas para interacciones táctiles.
## Soporta hover, press, bounce, pulse y shake.

@tool
extends Button

# --- Constantes ---
const LOGP := "[AnimatedButton] "

# --- Variables Exportadas ---
@export var hover_scale: float = 1.1
@export var press_scale: float = 0.95
@export var animation_duration: float = 0.2
@export var enable_sound: bool = true
@export var bounce_on_press: bool = true

# --- Variables Miembro ---
var original_scale: Vector2 = Vector2.ONE
var is_pressed_down: bool = false
var hover_tween: Tween
var press_tween: Tween


# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	original_scale = scale

	# Conectar señales
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
		_animate_scale(original_scale * hover_scale)

func _on_hover_end() -> void:
	if not is_pressed_down:
		_animate_scale(original_scale)

func _on_press_start() -> void:
	if disabled:
		return

	is_pressed_down = true
	_animate_scale(original_scale * press_scale)

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
#  Funciones Públicas
# ──────────────────────────────────────────────

## Animación de pulso continuo para llamar la atención.
func pulse_animation(duration: float = 1.0, scale_factor: float = 1.2) -> void:
	var pulse_tween: Tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.set_ease(Tween.EASE_IN_OUT)
	pulse_tween.set_trans(Tween.TRANS_SINE)
	pulse_tween.tween_property(self, "scale", original_scale * scale_factor, duration / 2)
	pulse_tween.tween_property(self, "scale", original_scale, duration / 2)

## Detener animación de pulso.
func stop_pulse() -> void:
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
	scale = original_scale

## Animación de sacudida (para errores o llamar atención).
func shake_animation(intensity: float = 10.0, duration: float = 0.5) -> void:
	var original_position: Vector2 = position
	var shake_tween: Tween = create_tween()

	for i in range(int(duration * 20)):  # 20 sacudidas por segundo
		var offset: Vector2 = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		shake_tween.tween_property(self, "position", original_position + offset, 0.05)

	shake_tween.tween_property(self, "position", original_position, 0.1)


# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

## Anima la escala del botón hacia el valor objetivo.
func _animate_scale(target_scale: Vector2) -> void:
	# Cancelar tween anterior si existe
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()

	hover_tween = create_tween()
	hover_tween.set_ease(Tween.EASE_OUT)
	hover_tween.set_trans(Tween.TRANS_BACK)
	hover_tween.tween_property(self, "scale", target_scale, animation_duration)

## Crea efecto de rebote al presionar.
func _create_bounce_effect() -> void:
	if press_tween and press_tween.is_running():
		press_tween.kill()

	press_tween = create_tween()
	press_tween.set_ease(Tween.EASE_OUT)
	press_tween.set_trans(Tween.TRANS_ELASTIC)
	press_tween.tween_property(self, "scale", original_scale * 1.15, 0.1)
	press_tween.tween_property(self, "scale", original_scale, 0.3)

## Verifica si el mouse está sobre el botón.
func _is_mouse_hovering() -> bool:
	if not is_inside_tree():
		return false
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	return get_global_rect().has_point(mouse_pos)
