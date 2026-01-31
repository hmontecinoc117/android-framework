# AnimationHelper.gd
# Funciones helper para animaciones comunes
class_name AnimationHelper

# Crear efecto de confeti
static func create_confetti_at_position(parent: Node, position: Vector2, amount: int = 50):
	var particles = CPUParticles2D.new()
	parent.add_child(particles)
	
	particles.global_position = position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = amount
	particles.lifetime = 2.0
	particles.explosiveness = 0.9
	
	# Configuración
	particles.direction = Vector2(0, -1)
	particles.spread = 180
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 300.0
	particles.gravity = Vector2(0, 200)
	particles.angular_velocity_min = -360
	particles.angular_velocity_max = 360
	
	# Colores variados
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color.RED)
	gradient.add_point(0.2, Color.YELLOW)
	gradient.add_point(0.4, Color.GREEN)
	gradient.add_point(0.6, Color.CYAN)
	gradient.add_point(0.8, Color.BLUE)
	gradient.add_point(1.0, Color.MAGENTA)
	particles.color_ramp = gradient
	
	# Auto-eliminar
	await parent.get_tree().create_timer(particles.lifetime + 0.5).timeout
	particles.queue_free()

# Crear efecto de estrellas brillantes
static func create_sparkle_effect(parent: Node, position: Vector2, amount: int = 20):
	var particles = CPUParticles2D.new()
	parent.add_child(particles)
	
	particles.global_position = position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = amount
	particles.lifetime = 0.8
	particles.explosiveness = 0.8
	
	particles.direction = Vector2(0, -1)
	particles.spread = 180
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 150.0
	particles.gravity = Vector2(0, 50)
	
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 2.0
	
	particles.color = Color.GOLD
	
	# Auto-eliminar
	await parent.get_tree().create_timer(particles.lifetime + 0.5).timeout
	particles.queue_free()

# Animación de bounce (funciona con Node2D y Control)
static func bounce_node(node: CanvasItem, intensity: float = 1.2, duration: float = 0.5):
	var original_scale = node.scale
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(node, "scale", original_scale * intensity, duration * 0.3)
	tween.tween_property(node, "scale", original_scale, duration * 0.7)

# Animación de shake (funciona con Node2D y Control)
static func shake_node(node: CanvasItem, intensity: float = 10.0, duration: float = 0.5):
	var original_position = node.position
	var tween = node.create_tween()
	
	var shake_count = int(duration * 30)  # 30 sacudidas por segundo
	for i in shake_count:
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(node, "position", original_position + offset, duration / shake_count)
	
	tween.tween_property(node, "position", original_position, 0.1)

# Fade in
static func fade_in(node: CanvasItem, duration: float = 0.5):
	node.modulate = Color(1, 1, 1, 0)
	var tween = node.create_tween()
	tween.tween_property(node, "modulate", Color(1, 1, 1, 1), duration)

# Fade out
static func fade_out(node: CanvasItem, duration: float = 0.5):
	var tween = node.create_tween()
	tween.tween_property(node, "modulate", Color(1, 1, 1, 0), duration)

# Pop in (aparecer con escala) - funciona con Node2D y Control
static func pop_in(node: CanvasItem, duration: float = 0.3):
	node.scale = Vector2.ZERO
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "scale", Vector2.ONE, duration)

# Pop out (desaparecer con escala) - funciona con Node2D y Control
static func pop_out(node: CanvasItem, duration: float = 0.3):
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "scale", Vector2.ZERO, duration)

# Pulso continuo - funciona con Node2D y Control
static func pulse_loop(node: CanvasItem, scale_factor: float = 1.2, duration: float = 1.0):
	var original_scale = node.scale
	var tween = node.create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "scale", original_scale * scale_factor, duration / 2)
	tween.tween_property(node, "scale", original_scale, duration / 2)
	return tween

# Rotación continua - funciona con Node2D y Control
static func rotate_loop(node: CanvasItem, speed: float = 1.0):
	var tween = node.create_tween()
	tween.set_loops()
	tween.tween_property(node, "rotation", TAU, speed)
	return tween

# Slide in desde dirección
static func slide_in(node: Control, direction: String = "bottom", duration: float = 0.5):
	var original_position = node.position
	var viewport_size = node.get_viewport_rect().size
	
	match direction:
		"bottom":
			node.position.y = viewport_size.y
		"top":
			node.position.y = -node.size.y
		"left":
			node.position.x = -node.size.x
		"right":
			node.position.x = viewport_size.x
	
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "position", original_position, duration)

# Slide out hacia dirección
static func slide_out(node: Control, direction: String = "bottom", duration: float = 0.5):
	var viewport_size = node.get_viewport_rect().size
	var target_position: Vector2
	
	match direction:
		"bottom":
			target_position = Vector2(node.position.x, viewport_size.y)
		"top":
			target_position = Vector2(node.position.x, -node.size.y)
		"left":
			target_position = Vector2(-node.size.x, node.position.y)
		"right":
			target_position = Vector2(viewport_size.x, node.position.y)
	
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "position", target_position, duration)

# Efecto de éxito (escala + brillo)
static func success_effect(node: CanvasItem, duration: float = 0.5):
	# Brillo temporal
	var original_modulate = node.modulate
	var bright_color = Color(1.5, 1.5, 1.5, 1.0)
	
	var tween = node.create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "modulate", bright_color, duration * 0.3)
	tween.tween_property(node, "modulate", original_modulate, duration * 0.7).set_delay(duration * 0.3)
	
	if node is Node2D:
		var original_scale = node.scale
		tween.tween_property(node, "scale", original_scale * 1.2, duration * 0.3)
		tween.tween_property(node, "scale", original_scale, duration * 0.7).set_delay(duration * 0.3)

# Efecto de error (shake + color rojo temporal)
static func error_effect(node: CanvasItem, intensity: float = 10.0):
	# Color rojo temporal
	var original_modulate = node.modulate
	var error_color = Color(1.5, 0.5, 0.5, 1.0)
	
	var tween = node.create_tween()
	tween.tween_property(node, "modulate", error_color, 0.1)
	tween.tween_property(node, "modulate", original_modulate, 0.3)
	
	# Shake
	if node is Node2D:
		shake_node(node, intensity, 0.4)
