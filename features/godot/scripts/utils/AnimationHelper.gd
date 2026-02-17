## Funciones helper estáticas para animaciones comunes.
## Incluye efectos de partículas, escala, fade, slide y utilidades.

class_name AnimationHelper


# ──────────────────────────────────────────────
#  Efectos de Partículas
# ──────────────────────────────────────────────

## Crea un efecto de confeti en la posición indicada.
static func create_confetti_at_position(parent: Node, position: Vector2, amount: int = 50) -> void:
	var particles: CPUParticles2D = CPUParticles2D.new()
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
	var gradient: Gradient = Gradient.new()
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

## Crea un efecto de estrellas brillantes en la posición indicada.
static func create_sparkle_effect(parent: Node, position: Vector2, amount: int = 20) -> void:
	var particles: CPUParticles2D = CPUParticles2D.new()
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


# ──────────────────────────────────────────────
#  Efectos de Escala
# ──────────────────────────────────────────────

## Animación de bounce (funciona con Node2D y Control).
static func bounce_node(node: CanvasItem, intensity: float = 1.2, duration: float = 0.5) -> void:
	var original_scale: Vector2 = node.scale
	var tween: Tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(node, "scale", original_scale * intensity, duration * 0.3)
	tween.tween_property(node, "scale", original_scale, duration * 0.7)

## Animación de shake (funciona con Node2D y Control).
static func shake_node(node: CanvasItem, intensity: float = 10.0, duration: float = 0.5) -> void:
	var original_position: Vector2 = node.position
	var tween: Tween = node.create_tween()

	var shake_count: int = int(duration * 30)  # 30 sacudidas por segundo
	for i in shake_count:
		var offset: Vector2 = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(node, "position", original_position + offset, duration / shake_count)

	tween.tween_property(node, "position", original_position, 0.1)

## Pop in (aparecer con escala desde cero).
static func pop_in(node: CanvasItem, duration: float = 0.3) -> void:
	node.scale = Vector2.ZERO
	var tween: Tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "scale", Vector2.ONE, duration)

## Pop out (desaparecer reduciendo escala a cero).
static func pop_out(node: CanvasItem, duration: float = 0.3) -> void:
	var tween: Tween = node.create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "scale", Vector2.ZERO, duration)

## Pulso continuo en bucle (retorna el Tween para poder detenerlo).
static func pulse_loop(node: CanvasItem, scale_factor: float = 1.2, duration: float = 1.0) -> Tween:
	var original_scale: Vector2 = node.scale
	var tween: Tween = node.create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "scale", original_scale * scale_factor, duration / 2)
	tween.tween_property(node, "scale", original_scale, duration / 2)
	return tween

## Rotación continua en bucle (retorna el Tween para poder detenerlo).
static func rotate_loop(node: CanvasItem, speed: float = 1.0) -> Tween:
	var tween: Tween = node.create_tween()
	tween.set_loops()
	tween.tween_property(node, "rotation", TAU, speed)
	return tween


# ──────────────────────────────────────────────
#  Efectos de Fade
# ──────────────────────────────────────────────

## Aparece el nodo con fade in.
static func fade_in(node: CanvasItem, duration: float = 0.5) -> void:
	node.modulate = Color(1, 1, 1, 0)
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "modulate", Color(1, 1, 1, 1), duration)

## Desaparece el nodo con fade out.
static func fade_out(node: CanvasItem, duration: float = 0.5) -> void:
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "modulate", Color(1, 1, 1, 0), duration)


# ──────────────────────────────────────────────
#  Efectos de Slide
# ──────────────────────────────────────────────

## Desliza el nodo hacia su posición original desde la dirección indicada.
static func slide_in(node: Control, direction: String = "bottom", duration: float = 0.5) -> void:
	var original_position: Vector2 = node.position
	var viewport_size: Vector2 = node.get_viewport_rect().size

	match direction:
		"bottom":
			node.position.y = viewport_size.y
		"top":
			node.position.y = -node.size.y
		"left":
			node.position.x = -node.size.x
		"right":
			node.position.x = viewport_size.x

	var tween: Tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "position", original_position, duration)

## Desliza el nodo fuera de pantalla hacia la dirección indicada.
static func slide_out(node: Control, direction: String = "bottom", duration: float = 0.5) -> void:
	var viewport_size: Vector2 = node.get_viewport_rect().size
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

	var tween: Tween = node.create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "position", target_position, duration)


# ──────────────────────────────────────────────
#  Efectos Compuestos
# ──────────────────────────────────────────────

## Efecto de éxito (escala + brillo temporal).
static func success_effect(node: CanvasItem, duration: float = 0.5) -> void:
	# Brillo temporal
	var original_modulate: Color = node.modulate
	var bright_color: Color = Color(1.5, 1.5, 1.5, 1.0)

	var tween: Tween = node.create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "modulate", bright_color, duration * 0.3)
	tween.tween_property(node, "modulate", original_modulate, duration * 0.7).set_delay(duration * 0.3)

	if node is Node2D:
		var original_scale: Vector2 = node.scale
		tween.tween_property(node, "scale", original_scale * 1.2, duration * 0.3)
		tween.tween_property(node, "scale", original_scale, duration * 0.7).set_delay(duration * 0.3)

## Efecto de error (shake + color rojo temporal).
static func error_effect(node: CanvasItem, intensity: float = 10.0) -> void:
	# Color rojo temporal
	var original_modulate: Color = node.modulate
	var error_color: Color = Color(1.5, 0.5, 0.5, 1.0)

	var tween: Tween = node.create_tween()
	tween.tween_property(node, "modulate", error_color, 0.1)
	tween.tween_property(node, "modulate", original_modulate, 0.3)

	# Shake
	if node is Node2D:
		shake_node(node, intensity, 0.4)


# ──────────────────────────────────────────────
#  Fondos y Decoraciones
# ──────────────────────────────────────────────

## Aplica un degradado vertical suave al fondo existente (ColorRect).
## Crea un segundo ColorRect semitransparente encima.
static func apply_gradient_background(parent: Node, top_color: Color, bottom_color: Color) -> void:
	# Buscar ColorRect de fondo existente o crear uno
	var bg: ColorRect
	for child in parent.get_children():
		if child is ColorRect and child.name == "Background":
			bg = child
			break

	if bg:
		bg.color = top_color

	# Agregar overlay de degradado
	var overlay: ColorRect = ColorRect.new()
	overlay.name = "GradientOverlay"
	overlay.color = bottom_color
	overlay.modulate = Color(1, 1, 1, 0.4)
	overlay.z_index = -1
	if parent is Control:
		overlay.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		overlay.offset_top = -parent.get_viewport_rect().size.y * 0.5
	elif parent is Node2D:
		var vp_size: Vector2 = parent.get_viewport_rect().size
		overlay.position = Vector2(0, vp_size.y * 0.5)
		overlay.size = Vector2(vp_size.x, vp_size.y * 0.5)
	parent.add_child(overlay)
	parent.move_child(overlay, 0 if not bg else bg.get_index() + 1)


## Agrega decoraciones flotantes al fondo de un juego.
static func add_floating_decorations(parent: Node, emojis: Array[String], count: int = 6) -> void:
	var vp_size: Vector2 = parent.get_viewport_rect().size
	for i: int in count:
		var emoji_idx: int = i % emojis.size()
		var label: Label = Label.new()
		label.text = emojis[emoji_idx]
		label.add_theme_font_size_override("font_size", randi_range(30, 50))
		label.modulate = Color(1, 1, 1, randf_range(0.15, 0.3))
		label.z_index = -1
		label.rotation = randf_range(-0.3, 0.3)
		if parent is Control:
			label.position = Vector2(
				randf_range(20, vp_size.x - 80),
				randf_range(20, vp_size.y - 80)
			)
		else:
			label.position = Vector2(
				randf_range(20, vp_size.x - 80),
				randf_range(20, vp_size.y - 80)
			)
		parent.add_child(label)
