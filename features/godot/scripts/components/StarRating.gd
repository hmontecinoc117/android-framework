# StarRating.gd
# Sistema de calificación por estrellas con animaciones
extends HBoxContainer

signal stars_animation_complete
signal star_animated(star_index: int)

@export var max_stars: int = 3
@export var star_size: Vector2 = Vector2(100, 100)
@export var delay_between_stars: float = 0.3
@export var enable_particles: bool = true

var earned_stars: int = 0
var star_nodes: Array[TextureRect] = []

# Paths de texturas (se pueden cambiar)
var star_empty_texture_path: String = "res://assets/images/ui/star_empty.png"
var star_filled_texture_path: String = "res://assets/images/ui/star_filled.png"

func _ready():
	setup_stars()

func setup_stars():
	# Limpiar estrellas existentes
	for child in get_children():
		child.queue_free()
	star_nodes.clear()
	
	# Crear nuevas estrellas
	for i in max_stars:
		var star = TextureRect.new()
		
		# Intentar cargar textura, usar placeholder si no existe
		if ResourceLoader.exists(star_empty_texture_path):
			star.texture = load(star_empty_texture_path)
		else:
			# Crear textura placeholder (cuadrado amarillo)
			var placeholder = PlaceholderTexture2D.new()
			placeholder.size = star_size
			star.texture = placeholder
		
		star.custom_minimum_size = star_size
		star.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		add_child(star)
		star_nodes.append(star)

func show_stars(stars: int, animated: bool = true):
	earned_stars = clampi(stars, 0, max_stars)
	
	if animated:
		animate_stars()
	else:
		display_stars_instantly()

func animate_stars():
	for i in earned_stars:
		await get_tree().create_timer(delay_between_stars).timeout
		animate_star(i)
	
	await get_tree().create_timer(delay_between_stars).timeout
	stars_animation_complete.emit()

func display_stars_instantly():
	for i in max_stars:
		var star = star_nodes[i]
		if i < earned_stars:
			if ResourceLoader.exists(star_filled_texture_path):
				star.texture = load(star_filled_texture_path)
		else:
			if ResourceLoader.exists(star_empty_texture_path):
				star.texture = load(star_empty_texture_path)
	
	stars_animation_complete.emit()

func animate_star(index: int):
	if index >= star_nodes.size():
		return
	
	var star = star_nodes[index]
	
	# Cambiar textura
	if ResourceLoader.exists(star_filled_texture_path):
		star.texture = load(star_filled_texture_path)
	
	# Animación de escala (aparición elástica)
	star.scale = Vector2.ZERO
	star.pivot_offset = star.size / 2
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(star, "scale", Vector2.ONE, 0.8)
	
	# Partículas
	if enable_particles:
		create_star_particles(star)
	
	# Sonido
		AudioManager.play_star_earned()
	
	# Vibración en móvil
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(100)
	
	star_animated.emit(index)

func create_star_particles(star: TextureRect):
	var particles = CPUParticles2D.new()
	star.add_child(particles)
	
	particles.position = star.size / 2
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 20
	particles.lifetime = 1.0
	particles.explosiveness = 0.8
	
	# Configuración de partículas
	particles.direction = Vector2(0, -1)
	particles.spread = 180
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 150.0
	particles.gravity = Vector2(0, 100)
	
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.5
	
	# Color dorado brillante
	particles.color = Color.GOLD
	particles.color_ramp = create_color_gradient()
	
	# Eliminar partículas después de completar
	await get_tree().create_timer(particles.lifetime + 0.5).timeout
	particles.queue_free()

func create_color_gradient() -> Gradient:
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 0, 1))  # Amarillo opaco
	gradient.add_point(0.5, Color(1, 0.8, 0, 0.8))  # Naranja
	gradient.add_point(1.0, Color(1, 1, 0, 0))  # Amarillo transparente
	return gradient

func reset_stars():
	"""Reiniciar todas las estrellas a vacías"""
	earned_stars = 0
	for star in star_nodes:
		if ResourceLoader.exists(star_empty_texture_path):
			star.texture = load(star_empty_texture_path)
		star.scale = Vector2.ONE

func set_star_textures(empty_path: String, filled_path: String):
	"""Cambiar las texturas de las estrellas"""
	star_empty_texture_path = empty_path
	star_filled_texture_path = filled_path
	setup_stars()

func get_earned_stars() -> int:
	return earned_stars
