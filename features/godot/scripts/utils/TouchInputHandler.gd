# TouchInputHandler.gd
# Manejador global de input táctil con detección de gestos
extends Node

signal single_tap(position: Vector2)
signal double_tap(position: Vector2)
signal long_press(position: Vector2)
signal swipe(start_pos: Vector2, end_pos: Vector2, direction: Vector2)
signal pinch(delta: float)
signal drag(position: Vector2, relative: Vector2)

# Constantes de detección
const DOUBLE_TAP_TIME: float = 0.3
const LONG_PRESS_TIME: float = 0.8
const SWIPE_THRESHOLD: float = 100.0
const TAP_THRESHOLD: float = 20.0

# Estado del input
var last_tap_time: float = 0.0
var press_start_time: float = 0.0
var press_start_position: Vector2 = Vector2.ZERO
var is_pressing: bool = false
var has_moved: bool = false
var long_press_triggered: bool = false

# Multi-touch
var touch_points: Dictionary = {}  # index -> position
var initial_pinch_distance: float = 0.0

func _input(event):
	if event is InputEventScreenTouch:
		handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		handle_screen_drag(event)

func handle_screen_touch(event: InputEventScreenTouch):
	if event.pressed:
		# Touch down
		touch_points[event.index] = event.position
		
		if event.index == 0:  # Primer dedo
			on_touch_down(event.position)
		
		# Detectar pinch (dos dedos)
		if touch_points.size() == 2:
			var points = touch_points.values()
			initial_pinch_distance = points[0].distance_to(points[1])
	else:
		# Touch up
		if event.index == 0:  # Primer dedo
			on_touch_up(event.position)
		
		touch_points.erase(event.index)
		
		if touch_points.size() < 2:
			initial_pinch_distance = 0.0

func handle_screen_drag(event: InputEventScreenDrag):
	touch_points[event.index] = event.position
	
	if event.index == 0:  # Primer dedo
		on_touch_drag(event.position, event.relative)
	
	# Detectar pinch
	if touch_points.size() == 2:
		var points = touch_points.values()
		var current_distance = points[0].distance_to(points[1])
		
		if initial_pinch_distance > 0:
			var delta = current_distance - initial_pinch_distance
			pinch.emit(delta)
			initial_pinch_distance = current_distance

func on_touch_down(position: Vector2):
	is_pressing = true
	press_start_position = position
	press_start_time = Time.get_ticks_msec() / 1000.0
	has_moved = false
	long_press_triggered = false
	
	# Detectar doble tap
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_tap_time < DOUBLE_TAP_TIME:
		double_tap.emit(position)
		last_tap_time = 0.0  # Reset para evitar triple tap
	else:
		last_tap_time = current_time

func on_touch_up(position: Vector2):
	is_pressing = false
	var press_duration = (Time.get_ticks_msec() / 1000.0) - press_start_time
	var drag_distance = position.distance_to(press_start_position)
	
	# Detectar swipe
	if drag_distance > SWIPE_THRESHOLD:
		var direction = (position - press_start_position).normalized()
		swipe.emit(press_start_position, position, direction)
		has_moved = true
	
	# Detectar single tap (sin movimiento significativo)
	elif drag_distance < TAP_THRESHOLD and press_duration < LONG_PRESS_TIME:
		single_tap.emit(position)

func on_touch_drag(position: Vector2, relative: Vector2):
	var drag_distance = position.distance_to(press_start_position)
	
	# Detectar long press
	if is_pressing and not long_press_triggered:
		var press_duration = (Time.get_ticks_msec() / 1000.0) - press_start_time
		
		if press_duration > LONG_PRESS_TIME and drag_distance < TAP_THRESHOLD:
			long_press.emit(position)
			long_press_triggered = true
	
	# Emitir drag si se movió significativamente
	if drag_distance > TAP_THRESHOLD:
		has_moved = true
		drag.emit(position, relative)

func get_swipe_direction_name(direction: Vector2) -> String:
	"""Obtener nombre de dirección del swipe"""
	var angle = direction.angle()
	var degrees = rad_to_deg(angle)
	
	if degrees >= -45 and degrees < 45:
		return "right"
	elif degrees >= 45 and degrees < 135:
		return "down"
	elif degrees >= -135 and degrees < -45:
		return "up"
	else:
		return "left"

func is_touch_active() -> bool:
	return is_pressing

func get_touch_count() -> int:
	return touch_points.size()

func get_primary_touch_position() -> Vector2:
	if touch_points.has(0):
		return touch_points[0]
	return Vector2.ZERO
