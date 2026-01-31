# DraggableObject.gd
# Objeto arrastrable genérico con snap y feedback
extends Area2D

signal drag_started
signal drag_ended
signal dropped_on_target(target: Node2D)
signal returned_to_origin

@export var return_to_original_position: bool = true
@export var snap_to_target: bool = true
@export var snap_threshold: float = 50.0
@export var drag_scale: float = 1.2
@export var enable_rotation: bool = false
@export var can_drag: bool = true

var is_dragging: bool = false
var original_position: Vector2
var original_rotation: float
var drag_offset: Vector2
var current_tween: Tween

func _ready():
	original_position = global_position
	original_rotation = rotation
	
	# Configurar señales
	input_event.connect(_on_input_event)
	
	# Configurar para recibir input
	input_pickable = true

func _on_input_event(_viewport, event, _shape_idx):
	if not can_drag:
		return
	
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			start_drag(event.position)
		else:
			end_drag()

func _process(_delta):
	if is_dragging:
		var target_pos = get_global_mouse_position() + drag_offset
		global_position = target_pos
		
		# Rotación opcional durante arrastre
		if enable_rotation:
			rotation += 0.05

func start_drag(touch_position: Vector2):
	if not can_drag:
		return
	
	is_dragging = true
	drag_offset = global_position - get_global_mouse_position()
	z_index = 100
	
	# Cancelar tween anterior
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	# Animación de "levantar"
	current_tween = create_tween()
	current_tween.set_parallel(true)
	current_tween.tween_property(self, "scale", Vector2.ONE * drag_scale, 0.1)
	if enable_rotation:
		current_tween.tween_property(self, "rotation", 0.1, 0.1)
	
	drag_started.emit()
		AudioManager.play_pickup()

func end_drag():
	if not is_dragging:
		return
	
	is_dragging = false
	z_index = 0
	
	# Verificar si está cerca de un objetivo válido
	var nearby_target = find_nearby_target()
	
	if nearby_target and snap_to_target:
		snap_to(nearby_target)
		dropped_on_target.emit(nearby_target)
			AudioManager.play_success()
	elif return_to_original_position:
		return_to_origin()
			AudioManager.play_error()
		returned_to_origin.emit()
	else:
		# Solo reducir escala
		current_tween = create_tween()
		current_tween.tween_property(self, "scale", Vector2.ONE, 0.2)
	
	# Restaurar rotación
	if enable_rotation:
		var rot_tween = create_tween()
		rot_tween.tween_property(self, "rotation", original_rotation, 0.2)
	
	drag_ended.emit()

func find_nearby_target() -> Area2D:
	var overlapping = get_overlapping_areas()
	
	var closest_target: Area2D = null
	var closest_distance: float = snap_threshold
	
	for area in overlapping:
		if area.is_in_group("drop_targets") and area != self:
			var distance = global_position.distance_to(area.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_target = area
	
	return closest_target

func snap_to(target: Node2D):
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.set_trans(Tween.TRANS_BACK)
	current_tween.set_parallel(true)
	current_tween.tween_property(self, "global_position", target.global_position, 0.3)
	current_tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	
	# Desactivar después de hacer snap
	can_drag = false

func return_to_origin():
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.set_trans(Tween.TRANS_ELASTIC)
	current_tween.set_parallel(true)
	current_tween.tween_property(self, "global_position", original_position, 0.5)
	current_tween.tween_property(self, "scale", Vector2.ONE, 0.5)

func reset():
	"""Reiniciar objeto a su estado original"""
	can_drag = true
	is_dragging = false
	global_position = original_position
	rotation = original_rotation
	scale = Vector2.ONE
	z_index = 0

func set_locked(locked: bool):
	"""Bloquear/desbloquear el objeto"""
	can_drag = not locked
	
	if locked:
		modulate = Color(0.5, 0.5, 0.5, 0.7)
	else:
		modulate = Color.WHITE
