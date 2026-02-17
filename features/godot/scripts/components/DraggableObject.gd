## Objeto arrastrable genérico con snap y feedback.
## Soporta retorno a posición original y snap a objetivos.

extends Area2D

const LOGP := "[DraggableObject] "

# --- Señales ---
signal drag_started
signal drag_ended
signal dropped_on_target(target: Node2D)
signal returned_to_origin

# --- Variables Exportadas ---
@export var return_to_original_position: bool = true
@export var snap_to_target: bool = true
@export var snap_threshold: float = 50.0
@export var drag_scale: float = 1.2
@export var enable_rotation: bool = false
@export var can_drag: bool = true

# --- Variables Miembro ---
var is_dragging: bool = false
var original_position: Vector2
var original_rotation: float
var drag_offset: Vector2
var _current_tween: Tween

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	original_position = global_position
	original_rotation = rotation
	input_event.connect(_on_input_event)
	input_pickable = true
	print(LOGP, "_ready")

func _process(_delta: float) -> void:
	if is_dragging:
		var target_pos: Vector2 = get_global_mouse_position() + drag_offset
		global_position = target_pos
		if enable_rotation:
			rotation += 0.05

# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func reset() -> void:
	## Reiniciar objeto a su estado original.
	can_drag = true
	is_dragging = false
	global_position = original_position
	rotation = original_rotation
	scale = Vector2.ONE
	z_index = 0

func set_locked(locked: bool) -> void:
	## Bloquear/desbloquear el objeto.
	can_drag = not locked
	if locked:
		modulate = Color(0.5, 0.5, 0.5, 0.7)
	else:
		modulate = Color.WHITE

# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not can_drag:
		return
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			_start_drag(event.position)
		else:
			_end_drag()

func _start_drag(_touch_position: Vector2) -> void:
	if not can_drag:
		return
	is_dragging = true
	drag_offset = global_position - get_global_mouse_position()
	z_index = 100
	if _current_tween and _current_tween.is_running():
		_current_tween.kill()
	_current_tween = create_tween()
	_current_tween.set_parallel(true)
	_current_tween.tween_property(self, "scale", Vector2.ONE * drag_scale, 0.1)
	if enable_rotation:
		_current_tween.tween_property(self, "rotation", 0.1, 0.1)
	drag_started.emit()
	AudioManager.play_pickup()

func _end_drag() -> void:
	if not is_dragging:
		return
	is_dragging = false
	z_index = 0
	var nearby_target: Area2D = _find_nearby_target()
	if nearby_target and snap_to_target:
		_snap_to(nearby_target)
		dropped_on_target.emit(nearby_target)
		AudioManager.play_success()
	elif return_to_original_position:
		_return_to_origin()
		AudioManager.play_error()
		returned_to_origin.emit()
	else:
		_current_tween = create_tween()
		_current_tween.tween_property(self, "scale", Vector2.ONE, 0.2)
	if enable_rotation:
		var rot_tween: Tween = create_tween()
		rot_tween.tween_property(self, "rotation", original_rotation, 0.2)
	drag_ended.emit()

func _find_nearby_target() -> Area2D:
	var overlapping: Array[Area2D] = get_overlapping_areas()
	var closest_target: Area2D = null
	var closest_distance: float = snap_threshold
	for area in overlapping:
		if area.is_in_group("drop_targets") and area != self:
			var distance: float = global_position.distance_to(area.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_target = area
	return closest_target

func _snap_to(target: Node2D) -> void:
	if _current_tween and _current_tween.is_running():
		_current_tween.kill()
	_current_tween = create_tween()
	_current_tween.set_ease(Tween.EASE_OUT)
	_current_tween.set_trans(Tween.TRANS_BACK)
	_current_tween.set_parallel(true)
	_current_tween.tween_property(self, "global_position", target.global_position, 0.3)
	_current_tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	can_drag = false

func _return_to_origin() -> void:
	if _current_tween and _current_tween.is_running():
		_current_tween.kill()
	_current_tween = create_tween()
	_current_tween.set_ease(Tween.EASE_OUT)
	_current_tween.set_trans(Tween.TRANS_ELASTIC)
	_current_tween.set_parallel(true)
	_current_tween.tween_property(self, "global_position", original_position, 0.5)
	_current_tween.tween_property(self, "scale", Vector2.ONE, 0.5)
