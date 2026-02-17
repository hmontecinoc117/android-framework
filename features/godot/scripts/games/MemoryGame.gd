## Juego de memoria (memorice) con temáticas variadas.
## Permite elegir diferentes temas y niveles de dificultad.
## Soporta temas: animals, fruits, colors, numbers, shapes, vehicles.
extends Control

# --- Señales ---
signal game_completed(stars: int, time: float)

# --- Constantes ---
const LOGP := "[MemoryGame] "

const THEMES: Dictionary = {
	"animals": ["perro", "gato", "león", "elefante", "jirafa", "mono", "oso", "panda"],
	"fruits": ["manzana", "plátano", "uva", "fresa", "sandía", "piña", "naranja", "pera"],
	"colors": ["rojo", "azul", "verde", "amarillo", "morado", "naranja", "rosa", "café"],
	"numbers": ["1", "2", "3", "4", "5", "6", "7", "8"],
	"shapes": ["círculo", "cuadrado", "triángulo", "estrella", "corazón", "rombo", "hexágono", "óvalo"],
	"vehicles": ["carro", "avión", "barco", "bicicleta", "tren", "bus", "moto", "camión"]
}

const ANIMAL_IMAGE_MAP: Dictionary = {
	"perro": "res://assets/images/animals/perro.png",
	"gato": "res://assets/images/animals/gato.png",
	"león": "res://assets/images/animals/leon.png",
	"elefante": "res://assets/images/animals/elephant.png",
	"jirafa": "res://assets/images/animals/giraffe.png",
	"mono": "res://assets/images/animals/mono.png",
	"oso": "res://assets/images/animals/bear.png",
	"panda": "res://assets/images/animals/panda.png",
	"vaca": "res://assets/images/animals/vaca.png",
	"oveja": "res://assets/images/animals/oveja.png",
	"zorro": "res://assets/images/animals/zorro.png"
}

# --- Variables Exportadas ---
@export var grid_size: Vector2i = Vector2i(4, 2)  ## 4x2 = 8 cartas (4 parejas) - reducido para mejor UX
@export var game_theme: String = "animals"  ## animals, fruits, colors, numbers, shapes, vehicles

# --- Variables Miembro ---
# Nodos (obtenidos en _ready)
var cards_container: Node
var attempts_label: Label
var timer_label: Label
var theme_selector: Node
var back_button: Button
var background_node: Node
var decorations_layer: Control
var _bg_tween: Tween
var _bg_color_idx: int = 0
var _bg_colors: Array = []
var timer_bar: Range

# Estado del juego
var cards: Array = []
var flipped_cards: Array = []
var matched_pairs: int = 0
var total_pairs: int = 0
var attempts: int = 0
var start_time: float = 0.0
var can_flip: bool = true
var card_size_px: float = 120.0
var failed_attempts_on_pair: int = 0
var _last_tap_time: float = 0.0


# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	print(LOGP, "🎮 MemoryGame._ready() INICIADO - VERSION MINIMAL")
	
	# TEST: Crear un label simple para verificar que el script funciona
	var test_label = Label.new()
	test_label.text = "MEMORIA GAME CARGADO ✅"
	test_label.add_theme_font_size_override("font_size", 80)
	test_label.add_theme_color_override("font_color", Color.WHITE)
	test_label.set_anchors_preset(Control.PRESET_CENTER)
	test_label.offset_left = -400
	test_label.offset_right = 400
	test_label.offset_top = -100
	test_label.offset_bottom = 100
	test_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	test_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(test_label)
	
	# Obtener nodos básicos
	back_button = get_node_or_null("UI/TopBar/BackButton")
	
	if back_button:
		print(LOGP, "✅ BackButton encontrado, conectando señal")
		back_button.pressed.connect(_on_back_pressed)
	else:
		print(LOGP, "❌ BackButton NO encontrado")
	
	print(LOGP, "✅ MemoryGame._ready() COMPLETO - VERSION MINIMAL")


func _process(_delta: float) -> void:
	# DESACTIVADO temporalmente para debug
	pass


# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func change_theme(new_theme: String) -> void:
	if THEMES.has(new_theme):
		game_theme = new_theme
		reset_game()


func change_difficulty(new_grid_size: Vector2i) -> void:
	grid_size = new_grid_size
	reset_game()


func reset_game() -> void:
	matched_pairs = 0
	attempts = 0
	flipped_cards.clear()
	can_flip = true
	start_time = Time.get_ticks_msec() / 1000.0
	_setup_game()
	_update_attempts_label()


# ──────────────────────────────────────────────
#  Funciones Privadas — Setup
# ──────────────────────────────────────────────

func _setup_game() -> void:
	total_pairs = (grid_size.x * grid_size.y) / 2

	# Configurar contenedor de cartas
	if cards_container:
		_setup_grid_container()

	# Generar y colocar cartas
	_generate_cards()
	print(LOGP, "setup_game: grid=", grid_size, " total_pairs=", total_pairs, " cartas=", cards.size())


func _setup_grid_container() -> void:
	# Configurar GridContainer
	if cards_container is GridContainer:
		cards_container.columns = grid_size.x
		cards_container.add_theme_constant_override("h_separation", 24)
		cards_container.add_theme_constant_override("v_separation", 24)

		# Calcular tamaño de cartas según pantalla (landscape 1920x1080)
		var viewport_size = get_viewport_rect().size
		var available_width = viewport_size.x * 0.75   # Aumentado de 0.7 a 0.75
		var available_height = (viewport_size.y - 150) * 0.90  # Aumentado de 0.85 a 0.90

		var card_width = available_width / grid_size.x
		var card_height = available_height / grid_size.y

		# Cuadrado, usar el menor
		var card_size = min(card_width, card_height) - 20  # Reducido de 24 a 20
		card_size_px = clamp(card_size, 160.0, 280.0)  # Aumentado de 120-220 a 160-280
		print(LOGP, "card_size_px=", card_size_px, " viewport=", viewport_size)

		# Asegurar que CenterContainer llena el viewport
		var center_node = cards_container.get_parent()
		if center_node is CenterContainer:
			center_node.anchor_left = 0.0
			center_node.anchor_top = 0.0
			center_node.anchor_right = 1.0
			center_node.anchor_bottom = 1.0
			center_node.offset_top = 140.0
			center_node.offset_left = 0.0
			center_node.offset_right = 0.0
			center_node.offset_bottom = 0.0

		# Ajustar tamaño mínimo del grid
		var hsep = cards_container.get_theme_constant("h_separation")
		var vsep = cards_container.get_theme_constant("v_separation")
		var grid_w = card_size_px * grid_size.x + hsep * (grid_size.x - 1)
		var grid_h = card_size_px * grid_size.y + vsep * (grid_size.y - 1)
		if cards_container is Control:
			cards_container.custom_minimum_size = Vector2(grid_w, grid_h)
			cards_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			cards_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER


func _setup_animated_background() -> void:
	## Animación de gradiente pastel entre 3 colores de fondo (optimizada).
	if not background_node or not (background_node is ColorRect):
		return
	_bg_colors = [Color(0.35, 0.55, 0.85), Color(0.40, 0.70, 0.55), Color(0.85, 0.55, 0.40)]
	_bg_color_idx = 0
	_cycle_bg_color()


func _cycle_bg_color() -> void:
	## Cicla al siguiente color de fondo con transición suave (MÁS LENTA).
	if not background_node or not is_instance_valid(background_node):
		return
	var next_color: Color = _bg_colors[_bg_color_idx % _bg_colors.size()]
	if _bg_tween:
		_bg_tween.kill()
	_bg_tween = create_tween()
	_bg_tween.set_trans(Tween.TRANS_SINE)
	_bg_tween.set_ease(Tween.EASE_IN_OUT)
	_bg_tween.tween_property(background_node, "color", next_color, 45.0)  # Antes: 15.0
	_bg_tween.finished.connect(func() -> void:
		_bg_color_idx += 1
		_cycle_bg_color()
	)


func _ensure_decorations_layer() -> Node:
	if decorations_layer and is_instance_valid(decorations_layer):
		return decorations_layer
	decorations_layer = Control.new()
	decorations_layer.name = "Decorations"
	add_child(decorations_layer)
	return decorations_layer


func _add_decorations() -> void:
	## Decoraciones flotantes para niños: estrellas (REDUCIDAS Y OPTIMIZADAS).
	var layer = _ensure_decorations_layer()
	var vp = get_viewport_rect().size
	# Solo 3 estrellas tintineantes, más sutiles
	var star_chars = ["⭐", "✨", "🌟"]
	for i in range(3):  # Antes: 6
		var star = Label.new()
		star.text = star_chars[i % star_chars.size()]
		star.add_theme_font_size_override("font_size", 40 + (randi() % 20))
		star.modulate = Color(1, 1, 1, 0.4)  # Antes: 0.7 (más transparente)
		var x = 30 + (randi() % int(vp.x - 60))
		var y = 130 + (randi() % int(vp.y - 200))
		star.position = Vector2(x, y)
		star.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(star)
		var t = create_tween()
		t.set_loops()
		t.tween_property(star, "modulate:a", 0.2, 2.0 + randf() * 1.0)  # Más lento
		t.tween_property(star, "modulate:a", 0.5, 2.0 + randf() * 1.0)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _setup_clouds_overlay() -> void:
	# Nubes suaves flotando en el fondo (emojis, bajo costo)
	var layer = _ensure_decorations_layer()
	for i in range(3):
		var label := Label.new()
		label.text = "☁"
		label.add_theme_font_size_override("font_size", 110)
		label.modulate = Color(1,1,1,0.55)
		label.position = Vector2(randi()%int(get_viewport_rect().size.x), 60 + i*120)
		layer.add_child(label)
		var t := create_tween()
		t.set_loops()
		t.set_trans(Tween.TRANS_SINE)
		t.set_ease(Tween.EASE_IN_OUT)
		# Movimiento horizontal lento (ping-pong)
		t.tween_property(label, "position:x", label.position.x + 80, 8.0)
		t.tween_property(label, "position:x", label.position.x, 8.0)


func _spawn_floating_stars(count: int = 8) -> void:
	var layer = _ensure_decorations_layer()
	var vp = get_viewport_rect().size
	for i in range(count):
		var star := Label.new()
		star.text = "★"
		star.add_theme_font_size_override("font_size", 60 + (randi()%40))
		star.modulate = Color(1,1,1,0.8)
		var x = 80 + (randi()%int(vp.x - 160))
		var y = 220 + (randi()%int(vp.y - 440))
		star.position = Vector2(x, y)
		layer.add_child(star)
		# Flotación suave
		var tf := create_tween()
		tf.set_loops()
		tf.set_trans(Tween.TRANS_SINE)
		tf.set_ease(Tween.EASE_IN_OUT)
		tf.tween_property(star, "position:y", y - 16, 2.6)
		tf.tween_property(star, "position:y", y, 2.6)
		# Twinkle (parpadeo sutil)
		var tt := create_tween()
		tt.set_loops()
		tt.tween_property(star, "modulate:a", 0.5, 1.2)
		tt.tween_property(star, "modulate:a", 0.9, 1.2)


func _spawn_corner_characters() -> void:
	var layer = _ensure_decorations_layer()
	# Sol sonriente (arriba izquierda)
	var sun := Label.new()
	sun.text = "☀"
	sun.add_theme_font_size_override("font_size", 140)
	sun.modulate = Color(1,1,1,0.9)
	sun.position = Vector2(24, 24)
	layer.add_child(sun)
	# Nube feliz (arriba derecha)
	var cloud := Label.new()
	cloud.text = "☁"
	cloud.add_theme_font_size_override("font_size", 140)
	cloud.modulate = Color(1,1,1,0.9)
	cloud.position = Vector2(get_viewport_rect().size.x - 160, 40)
	layer.add_child(cloud)
	# Animaciones idle (blink/scale)
	var ts := create_tween()
	ts.set_loops()
	ts.set_trans(Tween.TRANS_SINE)
	ts.tween_property(sun, "scale", Vector2.ONE * 1.03, 4.0)
	ts.tween_property(sun, "scale", Vector2.ONE, 4.0)
	var tc := create_tween()
	tc.set_loops()
	tc.set_trans(Tween.TRANS_SINE)
	tc.tween_property(cloud, "modulate:a", 0.7, 4.0)
	tc.tween_property(cloud, "modulate:a", 0.9, 4.0)


func _apply_ui_assets() -> void:
	## Configura fondo vibrante y estilo del botón Atrás.
	if background_node and background_node is ColorRect:
		background_node.color = Color(0.28, 0.48, 0.82)

	# Título del juego
	var title_label = Label.new()
	title_label.text = "🧠 ¡Memorice!"
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	if ResourceLoader.exists("res://assets/fonts/NotoSans-Bold.ttf"):
		title_label.add_theme_font_override("font", load("res://assets/fonts/NotoSans-Bold.ttf"))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Estilo del botón Atrás — colorido y grande
	if back_button:
		back_button.text = "🏠"
		back_button.custom_minimum_size = Vector2(140, 100)
		back_button.add_theme_font_size_override("font_size", 56)
		back_button.focus_mode = Control.FOCUS_NONE

		var normal = StyleBoxFlat.new()
		normal.bg_color = Color(0.95, 0.50, 0.18, 0.95)
		normal.corner_radius_top_left = 24
		normal.corner_radius_top_right = 24
		normal.corner_radius_bottom_left = 24
		normal.corner_radius_bottom_right = 24
		normal.content_margin_left = 12
		normal.content_margin_right = 12
		normal.content_margin_top = 8
		normal.content_margin_bottom = 8
		normal.shadow_color = Color(0, 0, 0, 0.2)
		normal.shadow_size = 4
		var hovered = normal.duplicate()
		hovered.bg_color = Color(1.0, 0.55, 0.22, 1.0)
		var pressed_sb = normal.duplicate()
		pressed_sb.bg_color = Color(0.85, 0.42, 0.12, 1.0)
		back_button.add_theme_stylebox_override("normal", normal)
		back_button.add_theme_stylebox_override("hover", hovered)
		back_button.add_theme_stylebox_override("pressed", pressed_sb)
		back_button.add_theme_color_override("font_color", Color.WHITE)
		back_button.add_theme_color_override("font_hover_color", Color.WHITE)
		back_button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 0.85))

		if not back_button.is_connected("pressed", _on_back_pressed):
			back_button.pressed.connect(_on_back_pressed)

	# Insertar título en TopBar después del botón
	var top_bar = get_node_or_null("UI/TopBar")
	if top_bar and title_label:
		top_bar.add_child(title_label)
		top_bar.move_child(title_label, 1)


func _setup_safe_exit() -> void:
	if back_button and not back_button.is_connected("pressed", _on_back_pressed):
		back_button.pressed.connect(_on_back_pressed)


func _setup_touch_friendly_controls() -> void:
	pass  # Input es manejado directamente por gui_input en cada carta


# ──────────────────────────────────────────────
#  Funciones Privadas — Cartas
# ──────────────────────────────────────────────

func _generate_cards() -> void:
	# Limpiar cartas existentes
	for child in cards_container.get_children():
		child.queue_free()
	cards.clear()

	# Obtener valores de cartas según tema
	var theme_values = THEMES.get(game_theme, THEMES["animals"])
	var needed_pairs = total_pairs
	var selected_values = []

	# Seleccionar valores aleatorios
	for i in needed_pairs:
		if i < theme_values.size():
			selected_values.append(theme_values[i])
		else:
			selected_values.append(theme_values[i % theme_values.size()])

	# Duplicar para crear pares
	var card_values = []
	for value in selected_values:
		card_values.append(value)
		card_values.append(value)

	# Mezclar
	card_values.shuffle()

	# Crear cartas visuales
	for i in card_values.size():
		var card = _create_card(i, card_values[i])
		cards_container.add_child(card)
		# Forzar inicialización visual después de entrar al árbol
		if card.has_method("force_init"):
			card.force_init()
		cards.append(card)
	print(LOGP, "generate_cards: creadas ", cards.size(), " cartas con valores únicos=", selected_values)


func _create_card(id: int, value: String) -> Control:
	## Crea una carta visual instanciando la escena MemoryTile.
	var tile_scene = load("res://ui/components/MemoryTile.tscn")
	var card = tile_scene.instantiate()
	card.custom_minimum_size = Vector2(card_size_px, card_size_px)
	card.set_meta("card_id", id)
	card.set_meta("card_value", value)
	card.set_meta("is_flipped", false)
	card.set_meta("is_matched", false)
	card.pivot_offset = Vector2(card_size_px / 2.0, card_size_px / 2.0)

	# Asignar color según el valor del par (mismo color para la pareja)
	var theme_values = THEMES.get(game_theme, THEMES["animals"])
	var val_idx = theme_values.find(value)
	if val_idx < 0:
		val_idx = id % 8
	card.color_index = val_idx % 8

	# Determinar contenido frontal según tema
	var front_text: String = ""
	var front_icon: Texture2D = null

	if game_theme == "animals":
		# Temporalmente usar emojis para debug
		var animal_emojis: Dictionary = {
			"perro": "🐕", "gato": "🐈", "león": "🦁", "elefante": "🐘",
			"jirafa": "🦒", "mono": "🐵", "oso": "🐻", "panda": "🐼"
		}
		front_text = animal_emojis.get(value, "🐾")
	elif game_theme == "colors":
		var color_emojis: Dictionary = {
			"rojo": "🔴", "azul": "🔵", "verde": "🟢", "amarillo": "🟡",
			"morado": "🟣", "naranja": "🟠", "rosa": "💗", "café": "🟤"
		}
		front_text = color_emojis.get(value, value.to_upper())
	elif game_theme == "numbers":
		var number_emojis: Dictionary = {
			"1": "1️⃣", "2": "2️⃣", "3": "3️⃣", "4": "4️⃣",
			"5": "5️⃣", "6": "6️⃣", "7": "7️⃣", "8": "8️⃣"
		}
		front_text = number_emojis.get(value, value)
	else:
		front_text = value.to_upper()

	# Establecer contenido frontal (se mostrará al revelar)
	card.set_front_content(front_text, front_icon)
	# Guardar como metadata para fallback
	card.set_meta("front_text", front_text)

	# Conectar señal pressed para manejo de taps (funciona en Android)
	card.pressed.connect(_on_card_pressed.bind(card))

	return card


func _get_animal_texture(value: String) -> Texture2D:
	var path = ANIMAL_IMAGE_MAP.get(value, "")
	if path != "" and ResourceLoader.exists(path):
		return load(path)
	# Fallback: elegir cualquier imagen disponible del directorio
	var dir := DirAccess.open("res://assets/images/animals")
	if dir:
		var files := []
		dir.list_dir_begin()
		var f = dir.get_next()
		while f != "":
			if not dir.current_is_dir() and f.ends_with(".png"):
				files.append(f)
			f = dir.get_next()
		dir.list_dir_end()
		if files.size() > 0:
			var pick = files[randi() % files.size()]
			var picked_path = "res://assets/images/animals/" + pick
			if ResourceLoader.exists(picked_path):
				return load(picked_path)
	# Último recurso: placeholder
	return load("res://assets/images/placeholder_card.png")


# ──────────────────────────────────────────────
#  Funciones Privadas — Lógica de Juego
# ──────────────────────────────────────────────

func _handle_card_tap(card: Control) -> void:
	print(LOGP, "🎯 _handle_card_tap INICIO - can_flip=", can_flip)
	if not can_flip:
		print(LOGP, "  ❌ can_flip es false, abortando")
		return
	# Verificar si ya está volteada o emparejada
	if card.get_meta("is_flipped") or card.get_meta("is_matched"):
		print(LOGP, "  ❌ carta ya volteada/emparejada, abortando")
		return
	# Verificar límite de cartas volteadas
	if flipped_cards.size() >= 2:
		print(LOGP, "  ❌ ya hay 2 cartas volteadas, abortando")
		return
	
	print(LOGP, "  ✅ volteando carta id=", card.get_meta("card_id"))
	# Voltear carta
	_animate_card_flip(card, true)
	card.set_meta("is_flipped", true)
	flipped_cards.append(card)
	print(LOGP, "  📊 cartas volteadas: ", flipped_cards.size())
	
	# Si hay 2 cartas volteadas, verificar coincidencia
	if flipped_cards.size() == 2:
		can_flip = false
		attempts += 1
		_update_attempts_label()
		await get_tree().create_timer(0.8).timeout
		print(LOGP, "verificando match: valores=", flipped_cards[0].get_meta("card_value"), " & ", flipped_cards[1].get_meta("card_value"))
		_check_match()


func _check_match() -> void:
	print(LOGP, "⚖️  _check_match INICIO - flipped_cards.size()=", flipped_cards.size())
	if flipped_cards.size() != 2:
		print(LOGP, "  ❌ no hay exactamente 2 cartas")
		return

	var card1 = flipped_cards[0]
	var card2 = flipped_cards[1]

	var value1 = card1.get_meta("card_value")
	var value2 = card2.get_meta("card_value")

	print(LOGP, "  comparando: '", value1, "' vs '", value2, "'")
	
	if value1 == value2:
		# ¡Coinciden!
		print(LOGP, "  ✅ MATCH! ", value1, " == ", value2)
		_on_match_found(card1, card2)
	else:
		# No coinciden
		print(LOGP, "  ❌ NO MATCH: ", value1, " != ", value2)
		_on_match_failed(card1, card2)


func _on_match_found(card1: Control, card2: Control) -> void:
	# Marcar como emparejadas
	card1.set_meta("is_matched", true)
	card2.set_meta("is_matched", true)
	if card1.has_method("set_matched"):
		card1.call("set_matched", true)
	if card2.has_method("set_matched"):
		card2.call("set_matched", true)

	matched_pairs += 1

	# Efectos visuales
	AnimationHelper.success_effect(card1)
	AnimationHelper.success_effect(card2)
	AnimationHelper.create_sparkle_effect(self, card1.global_position + card1.size / 2, 15)
	AnimationHelper.create_sparkle_effect(self, card2.global_position + card2.size / 2, 15)
	
	# Animar y hacer desaparecer las cartas emparejadas
	_animate_match_disappear(card1, card2)
	print(LOGP, "match_found: pares=", matched_pairs, " de ", total_pairs)

	# Sonido
	AudioManager.play_success()

	# Feedback de voz
	if matched_pairs % 2 == 0:  # Cada 2 pares
		VoiceInstructions.play_feedback(true, false)

	# Limpiar cartas volteadas
	flipped_cards.clear()
	can_flip = true
	failed_attempts_on_pair = 0

	# Verificar si completó el juego
	if matched_pairs >= total_pairs:
		await get_tree().create_timer(1.0).timeout
		_complete_game()


func _on_match_failed(card1: Control, card2: Control) -> void:
	# Animación suave de intento fallido y volteo atrás
	failed_attempts_on_pair += 1
	print(LOGP, "match_failed: volteando cartas de vuelta")
	_animate_no_match(card1, card2)
	await get_tree().create_timer(0.3).timeout
	
	# Voltear de vuelta
	_animate_card_flip(card1, false)
	_animate_card_flip(card2, false)
	card1.set_meta("is_flipped", false)
	card2.set_meta("is_flipped", false)

	# Sonido suave de error
	AudioManager.play_error()

	# Limpiar cartas volteadas
	flipped_cards.clear()
	can_flip = true
	print(LOGP, "  ✅ cartas volteadas de vuelta, can_flip=true")

	# Sistema de ayuda: mostrar hint tras varios intentos fallidos
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.current_player_profile and gm.current_player_profile.age <= 3:
		if failed_attempts_on_pair >= 3:
			_show_gentle_hint()


func _complete_game() -> void:
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - start_time

	# Calcular estrellas según intentos
	var stars = _calculate_stars(attempts, grid_size.x * grid_size.y)

	# Efectos de celebración
	_celebrate_completion()
	_animate_game_complete()

	# Registrar progreso
	GameManager.complete_game("MemoryGame", stars, elapsed_time)

	# Emitir señal
	game_completed.emit(stars, elapsed_time)


func _calculate_stars(num_attempts: int, total_cards: int) -> int:
	# Calcular intentos mínimos posibles (número de pares)
	var min_attempts = total_cards / 2

	if num_attempts <= min_attempts + 3:
		return 3  # Excelente
	elif num_attempts <= min_attempts + 8:
		return 2  # Bueno
	else:
		return 1  # Completado


func _celebrate_completion() -> void:
	# Confeti
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 80)

	# Sonido
	AudioManager.play_game_complete()

	# Feedback
	VoiceInstructions.play_feedback(true)

	# Vibración
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(300)


func _update_attempts_label() -> void:
	if attempts_label:
		attempts_label.text = "Intentos: %d" % attempts


func _get_unmatched_cards() -> Array:
	var res: Array = []
	for c in cards:
		if not c.get_meta("is_matched"):
			res.append(c)
	return res


func _show_gentle_hint() -> void:
	# Pista visual sutil en una pareja no descubierta
	var unmatched = _get_unmatched_cards()
	if unmatched.size() < 2:
		return
	print(LOGP, "show_gentle_hint: candidatos=", unmatched.size())
	var first = unmatched[0]
	var target_val = first.get_meta("card_value")
	var pair = null
	for c in unmatched:
		if c != first and c.get_meta("card_value") == target_val:
			pair = c
			break
	if pair == null:
		return
	print(LOGP, "hint: par de ", target_val, " resaltado")
	for c in [first, pair]:
		var tw = create_tween()
		tw.set_loops(3)
		tw.tween_property(c, "modulate", Color(1.3, 1.3, 1.3, 1.0), 0.3)
		tw.tween_property(c, "modulate", Color.WHITE, 0.3)


# ──────────────────────────────────────────────
#  Funciones Privadas — Animaciones
# ──────────────────────────────────────────────

func _animate_game_entry() -> void:
	# Entrada: cartas aparecen con animación escalonada
	print(LOGP, "animate_game_entry: iniciando con ", cards.size(), " cartas")
	for i in cards.size():
		var card = cards[i]
		card.modulate.a = 0.0
		card.scale = Vector2(0.5, 0.5)
		card.pivot_offset = Vector2(card_size_px / 2.0, card_size_px / 2.0)

	for i in cards.size():
		var card = cards[i]
		var delay_time: float = 0.05 * i
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(card, "modulate:a", 1.0, 0.25).set_delay(delay_time)
		tween.tween_property(card, "scale", Vector2.ONE, 0.3).set_delay(delay_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	print(LOGP, "animate_game_entry: finalizado")


func _animate_card_flip(card: Control, show_front: bool) -> void:
	# Flip usando MemoryTile y su animación interna
	print(LOGP, "_animate_card_flip: show_front=", show_front)
	AudioManager.play_button_press()
	if card.has_method("set_revealed"):
		print(LOGP, "  → llamando set_revealed(", show_front, ")")
		card.set_revealed(show_front)
	else:
		print(LOGP, "  ⚠️  card NO tiene método set_revealed!")
		# Fallback: cambiar texto directamente
		if show_front:
			var txt = card.get_meta("front_text", "TEST")
			card.text = txt
			print(LOGP, "  → fallback: mostrando texto '", txt, "'")


func _animate_match_success(card1: Control, card2: Control) -> void:
	# DEPRECADO - usar _animate_match_disappear en su lugar
	pass


func _animate_match_disappear(card1: Control, card2: Control) -> void:
	## Hace desaparecer las cartas emparejadas con una animación de éxito
	for c in [card1, card2]:
		var t = create_tween()
		t.set_ease(Tween.EASE_IN_OUT)
		t.set_trans(Tween.TRANS_BACK)
		# Pulso rápido
		t.tween_property(c, "scale", Vector2(1.2, 1.2), 0.15)
		t.tween_property(c, "scale", Vector2.ONE, 0.1)
		# Desaparecer con fade
		t.tween_property(c, "modulate:a", 0.0, 0.4)
		# Deshabilitar input al final
		t.tween_callback(func():
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
			c.disabled = true
		)
	print(LOGP, "animate_match_disappear: cartas desapareciendo")
		# Efecto de pulso al emparejar
		t.tween_property(c, "scale", Vector2(1.15, 1.15), 0.2)
		t.tween_property(c, "scale", Vector2.ONE, 0.2)
		# Reducir opacidad ligeramente para indicar completado
		t.tween_property(c, "modulate:a", 0.9, 0.3)
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	print(LOGP, "animate_match_success: cartas emparejadas marcadas")


func _animate_no_match(card1: Control, card2: Control) -> void:
	# Modulate rojo breve para indicar error, sin mover posición
	for c in [card1, card2]:
		var tween_err = create_tween()
		tween_err.tween_property(c, "modulate", Color(1.0, 0.6, 0.6), 0.15)
		tween_err.tween_property(c, "modulate", Color.WHITE, 0.15)
	await get_tree().create_timer(0.3).timeout
	print(LOGP, "animate_no_match: feedback visual completado")


func _animate_game_complete() -> void:
	# Confeti + pequeño panel de resultado opcional
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 80)
	# Reproducir feedback de voz
	VoiceInstructions.play_feedback(true)
	print(LOGP, "animate_game_complete: celebración enviada")


func _add_card_breathing_animation(_card: Control) -> void:
	pass  # Desactivado: conflicto con animación de flip en scale


# ──────────────────────────────────────────────
#  Funciones Privadas — UI e Input
# ──────────────────────────────────────────────

func _on_back_pressed() -> void:
	print(LOGP, "🏠 _on_back_pressed LLAMADO!")
	AudioManager.play_back()
	var bootstrap: Node = get_node_or_null("/root/UiBootstrap")
	if bootstrap and bootstrap.has_method("fade_to_scene"):
		bootstrap.fade_to_scene("res://scenes/main/GameSelector.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main/GameSelector.tscn")


func _show_exit_confirmation() -> void:
	# Confirmación de salida visual y simple
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(700, 500)
	panel.position = get_viewport_rect().size / 2 - panel.custom_minimum_size / 2
	overlay.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 60)
	panel.add_child(vbox)

	var question = Label.new()
	question.text = "❓"
	question.add_theme_font_size_override("font_size", 160)
	question.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(question)

	var buttons = HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 60)
	vbox.add_child(buttons)

	var no_btn = Button.new()
	no_btn.text = "🎮\nSeguir"
	no_btn.custom_minimum_size = Vector2(280, 280)
	no_btn.add_theme_font_size_override("font_size", 70)
	buttons.add_child(no_btn)

	var yes_btn = Button.new()
	yes_btn.text = "🏠\nSalir"
	yes_btn.custom_minimum_size = Vector2(220, 220)
	yes_btn.add_theme_font_size_override("font_size", 60)
	buttons.add_child(yes_btn)

	no_btn.pressed.connect(func(): overlay.queue_free())
	yes_btn.pressed.connect(func() -> void:
		AudioManager.play_back()
		var bootstrap: Node = get_node_or_null("/root/UiBootstrap")
		if bootstrap and bootstrap.has_method("fade_to_scene"):
			bootstrap.fade_to_scene("res://scenes/main/GameSelector.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/main/GameSelector.tscn")
	)

	VoiceInstructions.play_feedback(true, false)


func _on_card_pressed(card: Control) -> void:
	# Handler directo del signal pressed del botón
	print(LOGP, "🎯 _on_card_pressed LLAMADO! card_id=", card.get_meta("card_id", -1))
	var now = Time.get_ticks_msec() / 1000.0
	if now - _last_tap_time < 0.3:
		print(LOGP, "  ⏭️  tap demasiado rápido, ignorando")
		return
	_last_tap_time = now
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(30)
	print(LOGP, "  ✅ procesando tap...")
	_handle_card_tap(card)
