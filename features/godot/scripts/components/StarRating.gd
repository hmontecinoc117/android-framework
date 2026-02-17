## Sistema de calificación por estrellas con animaciones.
## Muestra estrellas ganadas con efectos visuales y de sonido.

extends HBoxContainer

const LOGP := "[StarRating] "

# --- Señales ---
signal stars_animation_complete
signal star_animated(star_index: int)

# --- Variables Exportadas ---
@export var max_stars: int = 3
@export var star_size: Vector2 = Vector2(100, 100)
@export var delay_between_stars: float = 0.3
@export var enable_particles: bool = true

# --- Variables Miembro ---
var earned_stars: int = 0
var star_nodes: Array[TextureRect] = []
var star_empty_texture_path: String = "res://assets/images/ui/star_empty.png"
var star_filled_texture_path: String = "res://assets/images/ui/star_filled.png"

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	_setup_stars()

# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func show_stars(stars: int, animated: bool = true) -> void:
	earned_stars = clampi(stars, 0, max_stars)
	if animated:
		_animate_stars()
	else:
		_display_stars_instantly()

func reset_stars() -> void:
	## Reiniciar todas las estrellas a vacías.
	earned_stars = 0
	for star in star_nodes:
		if ResourceLoader.exists(star_empty_texture_path):
			star.texture = load(star_empty_texture_path)
		star.scale = Vector2.ONE

func set_star_textures(empty_path: String, filled_path: String) -> void:
	## Cambiar las texturas de las estrellas.
	star_empty_texture_path = empty_path
	star_filled_texture_path = filled_path
	_setup_stars()

func get_earned_stars() -> int:
	return earned_stars

# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _setup_stars() -> void:
	for child in get_children():
		child.queue_free()
	star_nodes.clear()
	for i in max_stars:
		var star: TextureRect = TextureRect.new()
		if ResourceLoader.exists(star_empty_texture_path):
			star.texture = load(star_empty_texture_path)
		else:
			var placeholder: PlaceholderTexture2D = PlaceholderTexture2D.new()
			placeholder.size = star_size
			star.texture = placeholder
		star.custom_minimum_size = star_size
		star.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(star)
		star_nodes.append(star)

func _animate_stars() -> void:
	for i in earned_stars:
		await get_tree().create_timer(delay_between_stars).timeout
		_animate_star(i)
	await get_tree().create_timer(delay_between_stars).timeout
	stars_animation_complete.emit()

func _display_stars_instantly() -> void:
	for i in max_stars:
		var star: TextureRect = star_nodes[i]
		if i < earned_stars:
			if ResourceLoader.exists(star_filled_texture_path):
				star.texture = load(star_filled_texture_path)
		else:
			if ResourceLoader.exists(star_empty_texture_path):
				star.texture = load(star_empty_texture_path)
	stars_animation_complete.emit()

func _animate_star(index: int) -> void:
	if index >= star_nodes.size():
		return
	var star: TextureRect = star_nodes[index]
	if ResourceLoader.exists(star_filled_texture_path):
		star.texture = load(star_filled_texture_path)
	star.scale = Vector2.ZERO
	star.pivot_offset = star.size / 2
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(star, "scale", Vector2.ONE, 0.8)
	if enable_particles:
		_create_star_particles(star)
	AudioManager.play_star_earned()
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(100)
	star_animated.emit(index)

func _create_star_particles(star: TextureRect) -> void:
	var particles: CPUParticles2D = CPUParticles2D.new()
	star.add_child(particles)
	particles.position = star.size / 2
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 20
	particles.lifetime = 1.0
	particles.explosiveness = 0.8
	particles.direction = Vector2(0, -1)
	particles.spread = 180
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 150.0
	particles.gravity = Vector2(0, 100)
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.5
	particles.color = Color.GOLD
	particles.color_ramp = _create_color_gradient()
	await get_tree().create_timer(particles.lifetime + 0.5).timeout
	particles.queue_free()

func _create_color_gradient() -> Gradient:
	var gradient: Gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 0, 1))
	gradient.add_point(0.5, Color(1, 0.8, 0, 0.8))
	gradient.add_point(1.0, Color(1, 1, 0, 0))
	return gradient
