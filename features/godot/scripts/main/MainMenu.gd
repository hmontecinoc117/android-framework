## Menú principal: pantalla de bienvenida animada con título,
## decoraciones y botón de jugar.

extends Control

# --- Constantes ---
const LOGP := "[MainMenu] "

const COLOR_SKY_TOP := Color(0.45, 0.75, 0.95)
const COLOR_SKY_BOTTOM := Color(0.6, 0.85, 0.95)
const COLOR_GRASS := Color(0.4, 0.78, 0.35)

# --- Variables Miembro ---
var _title_label: Label
var _play_button: Button
var _subtitle_label: Label
var _clouds: Array[ColorRect] = []
var _bg_top: ColorRect
var _bg_bottom: ColorRect
var _grass_rect: ColorRect
var _decorations: Array[Label] = []

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

var _auto_timer: SceneTreeTimer
var _auto_advance_triggered: bool = false

func _ready() -> void:
	print(LOGP, "_ready()")
	_build_background()
	_build_decorative_clouds()
	_build_grass()
	_build_decorative_elements()
	_build_title()
	_build_subtitle()
	_build_play_button()
	_animate_entrance()
	AudioManager.play_music("menu_theme", 2.0)

	# TODO: Implementar tutorial cuando esté listo
	# await get_tree().create_timer(0.5).timeout
	# if Tutorial.should_show_tutorial():
	# 	Tutorial.show_tutorial(self)
	# 	await get_tree().create_timer(1.0).timeout

	# Auto-avance al selector de juegos tras 5 segundos máximo
	_auto_timer = get_tree().create_timer(5.0)
	_auto_timer.timeout.connect(_on_auto_advance)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and not event.pressed:
		if _play_button and _play_button.get_global_rect().has_point(event.position):
			_on_play_pressed()


# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _build_background() -> void:
	## Fondo degradado cielo.
	var viewport_size: Vector2 = get_viewport_rect().size

	_bg_top = ColorRect.new()
	_bg_top.color = COLOR_SKY_TOP
	_bg_top.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_bg_top)

	# Degradado simulado con segundo rect
	_bg_bottom = ColorRect.new()
	_bg_bottom.color = COLOR_SKY_BOTTOM
	_bg_bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bg_bottom.offset_top = -viewport_size.y * 0.4
	_bg_bottom.modulate = Color(1, 1, 1, 0.6)
	add_child(_bg_bottom)


func _build_grass() -> void:
	## Franja de césped en la parte inferior.
	_grass_rect = ColorRect.new()
	_grass_rect.color = COLOR_GRASS
	_grass_rect.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_grass_rect.offset_top = -120
	add_child(_grass_rect)
	# Arbolitos / flores decorativos
	var flowers: Label = Label.new()
	flowers.text = "🌻 🌷 🌼 🌸 🌻 🌷 🌼 🌸 🌻 🌷"
	flowers.add_theme_font_size_override("font_size", 50)
	flowers.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flowers.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	flowers.offset_top = -140
	flowers.offset_bottom = -90
	add_child(flowers)


func _build_decorative_clouds() -> void:
	## Nubes flotantes.
	var viewport_size: Vector2 = get_viewport_rect().size
	var cloud_positions: Array[Vector2] = [
		Vector2(100, 60), Vector2(500, 120), Vector2(900, 40),
		Vector2(1400, 100), Vector2(1700, 60)
	]
	for pos: Vector2 in cloud_positions:
		var cloud: ColorRect = ColorRect.new()
		cloud.color = Color(1, 1, 1, 0.7)
		cloud.custom_minimum_size = Vector2(randi_range(120, 200), randi_range(40, 60))
		cloud.position = pos
		cloud.size = cloud.custom_minimum_size
		# Esquinas redondeadas simuladas
		add_child(cloud)
		_clouds.append(cloud)


func _build_decorative_elements() -> void:
	## Elementos decorativos animados.
	var viewport_size: Vector2 = get_viewport_rect().size
	var emojis: Array[String] = ["⭐", "🌈", "🎈", "🦋", "🎵"]
	var positions: Array[Vector2] = [
		Vector2(80, 200), Vector2(viewport_size.x - 150, 180),
		Vector2(120, viewport_size.y - 250), Vector2(viewport_size.x - 180, viewport_size.y - 280),
		Vector2(viewport_size.x / 2 + 300, 150)
	]
	for i: int in emojis.size():
		var deco: Label = Label.new()
		deco.text = emojis[i]
		deco.add_theme_font_size_override("font_size", 60)
		deco.position = positions[i]
		deco.modulate = Color(1, 1, 1, 0)
		add_child(deco)
		_decorations.append(deco)


func _build_title() -> void:
	## Título principal centrado.
	_title_label = Label.new()
	_title_label.text = "🎮 Juegos GustaNuno 🎮"
	_title_label.add_theme_font_size_override("font_size", 100)
	_title_label.add_theme_color_override("font_color", Color.WHITE)
	_title_label.add_theme_color_override("font_outline_color", Color(0.2, 0.1, 0.5))
	_title_label.add_theme_constant_override("outline_size", 8)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_title_label.offset_top = 180
	_title_label.offset_bottom = 320
	_title_label.offset_left = -600
	_title_label.offset_right = 600
	_title_label.modulate = Color(1, 1, 1, 0)
	_title_label.scale = Vector2(0.5, 0.5)
	_title_label.pivot_offset = Vector2(600, 70)
	add_child(_title_label)


func _build_subtitle() -> void:
	## Subtítulo debajo del título.
	_subtitle_label = Label.new()
	_subtitle_label.text = "¡Aprende jugando!"
	_subtitle_label.add_theme_font_size_override("font_size", 50)
	_subtitle_label.add_theme_color_override("font_color", Color(1, 1, 0.8))
	_subtitle_label.add_theme_color_override("font_outline_color", Color(0.3, 0.2, 0.1))
	_subtitle_label.add_theme_constant_override("outline_size", 4)
	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_subtitle_label.offset_top = 320
	_subtitle_label.offset_bottom = 400
	_subtitle_label.offset_left = -400
	_subtitle_label.offset_right = 400
	_subtitle_label.modulate = Color(1, 1, 1, 0)
	add_child(_subtitle_label)


func _build_play_button() -> void:
	## Botón grande de JUGAR.
	_play_button = Button.new()
	_play_button.text = "▶  JUGAR"
	_play_button.custom_minimum_size = Vector2(500, 160)
	_play_button.add_theme_font_size_override("font_size", 80)
	_play_button.focus_mode = Control.FOCUS_NONE
	_play_button.set_anchors_preset(Control.PRESET_CENTER)
	_play_button.offset_top = 60
	_play_button.offset_bottom = 220
	_play_button.offset_left = -250
	_play_button.offset_right = 250

	# Estilo verde atractivo
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.3, 0.8, 0.3)
	normal.corner_radius_top_left = 40
	normal.corner_radius_top_right = 40
	normal.corner_radius_bottom_left = 40
	normal.corner_radius_bottom_right = 40
	normal.shadow_size = 6
	normal.shadow_color = Color(0, 0, 0, 0.3)
	normal.shadow_offset = Vector2(0, 4)
	normal.content_margin_left = 40
	normal.content_margin_right = 40
	normal.content_margin_top = 20
	normal.content_margin_bottom = 20

	var hovered := normal.duplicate()
	hovered.bg_color = Color(0.35, 0.85, 0.35)
	hovered.shadow_size = 8

	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.25, 0.7, 0.25)
	pressed.shadow_size = 2
	pressed.shadow_offset = Vector2(0, 2)

	_play_button.add_theme_stylebox_override("normal", normal)
	_play_button.add_theme_stylebox_override("hover", hovered)
	_play_button.add_theme_stylebox_override("pressed", pressed)
	_play_button.add_theme_color_override("font_color", Color.WHITE)
	_play_button.add_theme_color_override("font_hover_color", Color.WHITE)
	_play_button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 0.9))

	_play_button.modulate = Color(1, 1, 1, 0)
	_play_button.scale = Vector2(0.3, 0.3)
	_play_button.pivot_offset = Vector2(250, 80)

	_play_button.pressed.connect(_on_play_pressed)
	add_child(_play_button)


func _animate_entrance() -> void:
	## Secuencia de animaciones de entrada.
	# 1. Título aparece con bounce
	var t1: Tween = create_tween()
	t1.set_ease(Tween.EASE_OUT)
	t1.set_trans(Tween.TRANS_BACK)
	t1.set_parallel(true)
	t1.tween_property(_title_label, "modulate", Color.WHITE, 0.8)
	t1.tween_property(_title_label, "scale", Vector2.ONE, 0.8)

	# 2. Subtítulo fade in
	var t2: Tween = create_tween()
	t2.tween_interval(0.5)
	t2.tween_property(_subtitle_label, "modulate", Color.WHITE, 0.6)

	# 3. Botón aparece con elástico
	var t3: Tween = create_tween()
	t3.tween_interval(0.8)
	t3.set_ease(Tween.EASE_OUT)
	t3.set_trans(Tween.TRANS_ELASTIC)
	t3.set_parallel(true)
	t3.tween_property(_play_button, "modulate", Color.WHITE, 0.6)
	t3.tween_property(_play_button, "scale", Vector2.ONE, 1.0)

	# 4. Decoraciones aparecen una por una
	for i: int in _decorations.size():
		var td: Tween = create_tween()
		td.tween_interval(1.0 + i * 0.15)
		td.tween_property(_decorations[i], "modulate", Color.WHITE, 0.4)

	# 5. Nubes empiezan a moverse
	_start_cloud_animation()

	# 6. Pulso suave en el botón
	var pulse: Tween = create_tween()
	pulse.tween_interval(2.0)
	pulse.tween_callback(_start_button_pulse)


func _start_cloud_animation() -> void:
	## Mueve las nubes continuamente.
	for cloud: ColorRect in _clouds:
		var tween: Tween = create_tween()
		tween.set_loops()
		var speed: float = randf_range(40.0, 80.0)
		var viewport_w: float = get_viewport_rect().size.x
		tween.tween_property(cloud, "position:x", viewport_w + 200, speed)
		tween.tween_callback(func() -> void: cloud.position.x = -220.0)


func _start_button_pulse() -> void:
	## Pulso continuo de atención en el botón.
	if not _play_button:
		return
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(_play_button, "scale", Vector2(1.05, 1.05), 0.8)
	tween.tween_property(_play_button, "scale", Vector2.ONE, 0.8)


func _on_auto_advance() -> void:
	## Auto-avanza al selector de juegos cuando se agota el tiempo.
	if _auto_advance_triggered:
		return
	_auto_advance_triggered = true
	print(LOGP, "Auto-avance a GameSelector (5s)")
	var bootstrap: Node = get_node_or_null("/root/UiBootstrap")
	if bootstrap and bootstrap.has_method("fade_to_scene"):
		bootstrap.fade_to_scene("res://scenes/main/GameSelector.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main/GameSelector.tscn")


func _on_play_pressed() -> void:
	if _auto_advance_triggered:
		return
	_auto_advance_triggered = true
	print(LOGP, "JUGAR presionado")
	AudioManager.play_button_press()

	# Animación de salida
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	tween.tween_property(_title_label, "modulate:a", 0.0, 0.3)
	tween.tween_property(_subtitle_label, "modulate:a", 0.0, 0.2)
	tween.tween_property(_play_button, "scale", Vector2(1.3, 1.3), 0.2)
	tween.tween_property(_play_button, "modulate:a", 0.0, 0.3)
	for deco: Label in _decorations:
		tween.tween_property(deco, "modulate:a", 0.0, 0.2)

	tween.chain().tween_callback(func() -> void:
		var bootstrap: Node = get_node_or_null("/root/UiBootstrap")
		if bootstrap and bootstrap.has_method("fade_to_scene"):
			bootstrap.fade_to_scene("res://scenes/main/GameSelector.tscn")
		else:
			get_tree().call_deferred("change_scene_to_file", "res://scenes/main/GameSelector.tscn")
	)
