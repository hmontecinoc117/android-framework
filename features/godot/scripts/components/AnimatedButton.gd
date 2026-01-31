# AnimatedButton.gd
# Botón con animaciones automáticas para interacciones
@tool
extends Button

@export var hover_scale: float = 1.1
@export var press_scale: float = 0.95
@export var animation_duration: float = 0.2
@export var enable_sound: bool = true
@export var bounce_on_press: bool = true

var original_scale: Vector2 = Vector2.ONE
var is_pressed_down: bool = false
var hover_tween: Tween
var press_tween: Tween

func _ready():
	original_scale = scale
	
	# Conectar señales
	mouse_entered.connect(_on_hover_start)
	mouse_exited.connect(_on_hover_end)
	button_down.connect(_on_press_start)
	button_up.connect(_on_press_end)
	pressed.connect(_on_button_pressed)

func _on_hover_start():
	if not is_pressed_down and not disabled:
		animate_scale(original_scale * hover_scale)

func _on_hover_end():
	if not is_pressed_down:
		animate_scale(original_scale)

func _on_press_start():
	if disabled:
		return
	
	is_pressed_down = true
	animate_scale(original_scale * press_scale)
	
	if enable_sound and AudioManager:
		AudioManager.play_button_press()

func _on_press_end():
	is_pressed_down = false
	
	if _is_mouse_hovering():
		animate_scale(original_scale * hover_scale)
	else:
		animate_scale(original_scale)

func _on_button_pressed():
	if bounce_on_press:
		create_bounce_effect()

func animate_scale(target_scale: Vector2):
	# Cancelar tween anterior si existe
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
	
	hover_tween = create_tween()
	hover_tween.set_ease(Tween.EASE_OUT)
	hover_tween.set_trans(Tween.TRANS_BACK)
	hover_tween.tween_property(self, "scale", target_scale, animation_duration)

func create_bounce_effect():
	if press_tween and press_tween.is_running():
		press_tween.kill()
	
	press_tween = create_tween()
	press_tween.set_ease(Tween.EASE_OUT)
	press_tween.set_trans(Tween.TRANS_ELASTIC)
	press_tween.tween_property(self, "scale", original_scale * 1.15, 0.1)
	press_tween.tween_property(self, "scale", original_scale, 0.3)

func pulse_animation(duration: float = 1.0, scale_factor: float = 1.2):
	"""Animación de pulso continuo para llamar la atención"""
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.set_ease(Tween.EASE_IN_OUT)
	pulse_tween.set_trans(Tween.TRANS_SINE)
	pulse_tween.tween_property(self, "scale", original_scale * scale_factor, duration / 2)
	pulse_tween.tween_property(self, "scale", original_scale, duration / 2)

func stop_pulse():
	"""Detener animación de pulso"""
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
	scale = original_scale

func shake_animation(intensity: float = 10.0, duration: float = 0.5):
	"""Animación de sacudida (para errores o llamar atención)"""
	var original_position = position
	var shake_tween = create_tween()
	
	for i in range(int(duration * 20)):  # 20 sacudidas por segundo
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		shake_tween.tween_property(self, "position", original_position + offset, 0.05)
	
	shake_tween.tween_property(self, "position", original_position, 0.1)

func _is_mouse_hovering() -> bool:
	"""Verifica si el mouse está sobre el botón"""
	if not is_inside_tree():
		return false
	var mouse_pos = get_viewport().get_mouse_position()
	return get_global_rect().has_point(mouse_pos)
