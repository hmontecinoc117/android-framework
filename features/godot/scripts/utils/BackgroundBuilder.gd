## BackgroundBuilder — Autoload que genera el fondo animado de 3 capas.
## Capa 0: gradiente cielo estático.
## Capa 1: nubes blancas redondeadas que se deslizan horizontalmente.
## Capa 2: estrellas pequeñas parpadeantes.
## Uso: BackgroundBuilder.build(parent_node)

extends Node

const LOGP := "[BackgroundBuilder] "

# Colores del cielo
const SKY_TOP    := Color("#87CEEB")
const SKY_BOTTOM := Color("#E0F4FF")

# Nubes
const CLOUD_COUNT    := 6
const CLOUD_OPACITY  := 0.85
const CLOUD_SPEED_PX := 40.0   # Píxeles por segundo

# Estrellas
const STAR_COUNT := 8


# ──────────────────────────────────────────────
#  API Pública
# ──────────────────────────────────────────────

## Construye el fondo completo y lo inserta como primer hijo del nodo dado.
## Retorna el nodo raíz del fondo para referencia.
func build(parent: Node) -> Node:
	print(LOGP, "build() — creando fondo de 3 capas")
	var root := Control.new()
	root.name = "AnimatedBackground"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.z_index = -10  # Detrás de todo

	_build_sky_layer(root)
	_build_cloud_layer(root, parent)
	_build_star_layer(root)

	# Insertar como primer hijo para que quede detrás
	parent.add_child(root)
	parent.move_child(root, 0)
	return root


# ──────────────────────────────────────────────
#  Capa 0 — Cielo estático con gradiente simulado
# ──────────────────────────────────────────────

func _build_sky_layer(root: Node) -> void:
	# Rect inferior (color más claro)
	var sky_base := ColorRect.new()
	sky_base.name = "SkyBase"
	sky_base.color = SKY_TOP
	sky_base.set_anchors_preset(Control.PRESET_FULL_RECT)
	sky_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(sky_base)

	# Rect superior superpuesto con gradiente hacia SKY_BOTTOM
	var sky_grad := ColorRect.new()
	sky_grad.name = "SkyGradient"
	sky_grad.color = SKY_BOTTOM
	sky_grad.set_anchors_preset(Control.PRESET_TOP_WIDE)
	sky_grad.anchor_bottom = 0.55
	sky_grad.modulate = Color(1, 1, 1, 0.55)
	sky_grad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(sky_grad)


# ──────────────────────────────────────────────
#  Capa 1 — Nubes que se deslizan (motion_scale 0.1)
# ──────────────────────────────────────────────

func _build_cloud_layer(root: Node, scene_parent: Node) -> void:
	var layer := Control.new()
	layer.name = "CloudLayer"
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(layer)

	var vp_size := _get_viewport_size(scene_parent)

	# Posiciones Y distribuidas en el tercio superior
	var y_positions: Array[float] = [60.0, 130.0, 55.0, 110.0, 75.0, 140.0]
	var x_starts:    Array[float] = [
		vp_size.x * 0.05,
		vp_size.x * 0.25,
		vp_size.x * 0.50,
		vp_size.x * 0.70,
		vp_size.x * 0.85,
		-200.0,
	]
	var widths:  Array[float] = [220.0, 180.0, 250.0, 190.0, 160.0, 210.0]
	var heights: Array[float] = [ 70.0,  55.0,  80.0,  60.0,  50.0,  65.0]

	for i: int in CLOUD_COUNT:
		var cloud := _make_cloud(
			Vector2(x_starts[i], y_positions[i]),
			Vector2(widths[i], heights[i])
		)
		layer.add_child(cloud)
		_animate_cloud(cloud, vp_size.x, scene_parent)


func _make_cloud(pos: Vector2, size: Vector2) -> Panel:
	var cloud := Panel.new()
	cloud.position = pos
	cloud.custom_minimum_size = size
	cloud.size = size
	cloud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cloud.modulate = Color(1, 1, 1, CLOUD_OPACITY)

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color.WHITE
	sb.corner_radius_top_left     = 40
	sb.corner_radius_top_right    = 40
	sb.corner_radius_bottom_left  = 40
	sb.corner_radius_bottom_right = 40
	sb.shadow_color = Color(0.7, 0.85, 1.0, 0.3)
	sb.shadow_size  = 6
	cloud.add_theme_stylebox_override("panel", sb)
	return cloud


func _animate_cloud(cloud: Panel, viewport_width: float, scene_parent: Node) -> void:
	# Duración calculada para mantener velocidad constante de CLOUD_SPEED_PX px/s
	var travel := viewport_width + 300.0
	var duration := travel / CLOUD_SPEED_PX

	var tween: Tween = scene_parent.create_tween() if scene_parent.has_method("create_tween") else cloud.create_tween()
	tween.set_loops()
	tween.tween_property(cloud, "position:x", viewport_width + 250.0, duration)
	tween.tween_callback(func() -> void: cloud.position.x = -270.0)


# ──────────────────────────────────────────────
#  Capa 2 — Estrellas parpadeantes (motion_scale 0.3)
# ──────────────────────────────────────────────

func _build_star_layer(root: Node) -> void:
	var layer := Control.new()
	layer.name = "StarLayer"
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(layer)

	# Posiciones distribuidas en la pantalla, evitando el centro (área de juego)
	var positions: Array[Vector2] = [
		Vector2(80,  80),  Vector2(350, 55),  Vector2(620, 90),
		Vector2(900, 60),  Vector2(40, 220),  Vector2(1200, 50),
		Vector2(1550, 85), Vector2(1800, 120),
	]

	for i: int in STAR_COUNT:
		var star := _make_star(positions[i])
		layer.add_child(star)
		_animate_star(star, i)


func _make_star(pos: Vector2) -> Panel:
	var star := Panel.new()
	star.position = pos
	star.custom_minimum_size = Vector2(18, 18)
	star.size = Vector2(18, 18)
	star.mouse_filter = Control.MOUSE_FILTER_IGNORE
	star.modulate = Color(1, 1, 1, 0.7)
	star.pivot_offset = Vector2(9, 9)

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#FFD700")
	sb.corner_radius_top_left     = 9
	sb.corner_radius_top_right    = 9
	sb.corner_radius_bottom_left  = 9
	sb.corner_radius_bottom_right = 9
	star.add_theme_stylebox_override("panel", sb)
	return star


func _animate_star(star: Panel, index: int) -> void:
	# Parpadeo: escala 0.8 → 1.2 con duración aleatoria ~1.5s
	var duration := 1.2 + (index % 4) * 0.15
	var tween := star.create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(star, "scale", Vector2(1.2, 1.2), duration * 0.5)
	tween.tween_property(star, "scale", Vector2(0.8, 0.8), duration * 0.5)


# ──────────────────────────────────────────────
#  Helper
# ──────────────────────────────────────────────

func _get_viewport_size(node: Node) -> Vector2:
	if node.has_method("get_viewport_rect"):
		return node.get_viewport_rect().size
	return Vector2(1920, 1080)
