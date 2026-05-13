## Juego de memoria (memorice) con temáticas variadas.
## Permite elegir diferentes temas y niveles de dificultad.
## Soporta temas: animals, fruits, colors, numbers, shapes, vehicles.

extends Control

# --- Señales ---
signal game_completed(stars: int, time: float)

# --- Enums ---

# --- Constantes ---
const LOGP := "[MemoryGame] "

const THEMES: Dictionary = {
	"animals":  ["perro", "gato", "león", "elefante", "jirafa", "mono", "oso", "panda"],
	"fruits":   ["manzana", "plátano", "uva", "fresa", "sandía", "piña", "naranja", "pera"],
	"colors":   ["rojo", "azul", "verde", "amarillo", "morado", "naranja", "rosa", "café"],
	"numbers":  ["1", "2", "3", "4", "5", "6", "7", "8"],
	"shapes":   ["círculo", "cuadrado", "triángulo", "estrella", "corazón", "rombo", "hexágono", "óvalo"],
	"vehicles": ["carro", "avión", "barco", "bicicleta", "tren", "bus", "moto", "camión"],
}

const ANIMAL_IMAGE_MAP: Dictionary = {
	"perro":    "res://assets/images/animals/perro.png",
	"gato":     "res://assets/images/animals/gato.png",
	"león":     "res://assets/images/animals/leon.png",
	"elefante": "res://assets/images/animals/elephant.png",
	"jirafa":   "res://assets/images/animals/giraffe.png",
	"mono":     "res://assets/images/animals/mono.png",
	"oso":      "res://assets/images/animals/bear.png",
	"panda":    "res://assets/images/animals/panda.png",
}

# --- @export ---
@export var grid_size:  Vector2i = Vector2i(4, 2)
@export var game_theme: String   = "animals"

# --- Variables ---
var cards_container:    Node
var attempts_label:     Label
var timer_label:        Label
var back_button:        Button
var background_node:    Node
var decorations_layer:  Control
var _bg_tween:          Tween
var _bg_color_idx:      int = 0
var _bg_colors:         Array = []
var timer_bar:          Range

# Estado del juego
var cards:                 Array    = []
var flipped_cards:         Array    = []
var matched_pairs:         int      = 0
var total_pairs:           int      = 0
var attempts:              int      = 0
var start_time:            float    = 0.0
var can_flip:              bool     = true
var card_size_px:          float    = 120.0
var failed_attempts_on_pair: int    = 0
var _last_tap_time:        float    = 0.0

# --- @onready ---


# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	print(LOGP, "🎮 MemoryGame._ready()")

	# Fondo animado de 3 capas
	BackgroundBuilder.build(self)

	# Obtener nodos de la escena
	back_button      = get_node_or_null("UI/TopBar/BackButton")
	cards_container  = get_node_or_null("UI/CardsArea/CenterContainer/CardsGrid")
	background_node  = get_node_or_null("Background")
	attempts_label   = get_node_or_null("UI/TopBar/AttemptsLabel")
	timer_label      = get_node_or_null("UI/TopBar/TimerLabel")

	# Ocultar contadores (perfil ≤3 años — sin información numérica)
	if attempts_label:
		attempts_label.visible = false
	if timer_label:
		timer_label.visible = false

	# Rediseñar TopBar
	_setup_topbar()

	# Decoraciones
	_add_decorations()

	# Iniciar juego si el contenedor de cartas está disponible
	if cards_container:
		_setup_game()
		_animate_game_entry()
	else:
		print(LOGP, "⚠️  cards_container no encontrado — modo minimal")
		_show_minimal_label()

	print(LOGP, "✅ _ready() completo")


func _process(_delta: float) -> void:
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
	attempts      = 0
	flipped_cards.clear()
	can_flip   = true
	start_time = Time.get_ticks_msec() / 1000.0
	_setup_game()
	_update_attempts_label()


# ──────────────────────────────────────────────
#  Funciones Privadas — Setup UI
# ──────────────────────────────────────────────

func _setup_topbar() -> void:
	## Rediseña la TopBar: fondo naranja, solo botón Atrás, sin contadores.
	var top_bar: Node = get_node_or_null("UI/TopBar")
	if not top_bar:
		return

	# Fondo naranja con esquinas redondeadas solo abajo
	if top_bar is Panel:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("#FF6B35")
		sb.corner_radius_top_left     = 0
		sb.corner_radius_top_right    = 0
		sb.corner_radius_bottom_left  = 24
		sb.corner_radius_bottom_right = 24
		sb.shadow_color  = Color(0, 0, 0, 0.25)
		sb.shadow_size   = 8
		sb.shadow_offset = Vector2(0, 4)
		top_bar.add_theme_stylebox_override("panel", sb)

	# Botón Atrás — grande, icono flecha en Fredoka One
	if back_button:
		back_button.text = "←"
		back_button.custom_minimum_size = Vector2(88, 88)
		back_button.focus_mode = Control.FOCUS_NONE

		var font_size := ScreenSizeAdapter.get_adaptive_font_size(48)
		back_button.add_theme_font_size_override("font_size", font_size)
		var font_path := "res://assets/fonts/FredokaOne-Regular.ttf"
		if ResourceLoader.exists(font_path):
			back_button.add_theme_font_override("font", load(font_path))

		var sb_n := _make_back_btn_style(Color("#E55A24"))
		var sb_h := _make_back_btn_style(Color("#FF6B35"))
		var sb_p := _make_back_btn_style(Color("#CC4A1A"))
		back_button.add_theme_stylebox_override("normal",  sb_n)
		back_button.add_theme_stylebox_override("hover",   sb_h)
		back_button.add_theme_stylebox_override("pressed", sb_p)
		back_button.add_theme_color_override("font_color",         Color.WHITE)
		back_button.add_theme_color_override("font_hover_color",   Color.WHITE)
		back_button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 0.85))

		if not back_button.is_connected("pressed", _on_back_pressed):
			back_button.pressed.connect(_on_back_pressed)


func _make_back_btn_style(bg: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color     = bg
	s.corner_radius_top_left     = 20
	s.corner_radius_top_right    = 20
	s.corner_radius_bottom_left  = 20
	s.corner_radius_bottom_right = 20
	s.content_margin_left   = 10
	s.content_margin_right  = 10
	s.content_margin_top    = 10
	s.content_margin_bottom = 10
	return s


func _show_minimal_label() -> void:
	var lbl := Label.new()
	lbl.text = "🧠 ¡Memorice!"
	lbl.add_theme_font_size_override("font_size", 80)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.set_anchors_preset(Control.PRESET_CENTER)
	lbl.offset_left   = -300
	lbl.offset_right  = 300
	lbl.offset_top    = -60
	lbl.offset_bottom = 60
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	add_child(lbl)


# ──────────────────────────────────────────────
#  Funciones Privadas — Setup de Juego
# ──────────────────────────────────────────────

func _setup_game() -> void:
	total_pairs = (grid_size.x * grid_size.y) / 2
	if cards_container:
		_setup_grid_container()
	_generate_cards()
	print(LOGP, "setup_game grid=", grid_size, " pares=", total_pairs)


func _setup_grid_container() -> void:
	if cards_container is GridContainer:
		cards_container.columns = grid_size.x
		cards_container.add_theme_constant_override("h_separation", 24)
		cards_container.add_theme_constant_override("v_separation", 24)

		var viewport_size: Vector2 = get_viewport_rect().size
		var available_width  := viewport_size.x * 0.75
		var available_height := (viewport_size.y - 150) * 0.90
		var card_width  := available_width  / grid_size.x
		var card_height := available_height / grid_size.y
		var card_size   := min(card_width, card_height) - 20
		card_size_px = clamp(card_size, 160.0, 280.0)
		print(LOGP, "card_size_px=", card_size_px)

		var center_node := cards_container.get_parent()
		if center_node is CenterContainer:
			center_node.anchor_left   = 0.0
			center_node.anchor_top    = 0.0
			center_node.anchor_right  = 1.0
			center_node.anchor_bottom = 1.0
			center_node.offset_top    = 140.0
			center_node.offset_left   = 0.0
			center_node.offset_right  = 0.0
			center_node.offset_bottom = 0.0

		var hsep: int = cards_container.get_theme_constant("h_separation")
		var vsep: int = cards_container.get_theme_constant("v_separation")
		var grid_w := card_size_px * grid_size.x + hsep * (grid_size.x - 1)
		var grid_h := card_size_px * grid_size.y + vsep * (grid_size.y - 1)
		if cards_container is Control:
			cards_container.custom_minimum_size    = Vector2(grid_w, grid_h)
			cards_container.size_flags_horizontal  = Control.SIZE_SHRINK_CENTER
			cards_container.size_flags_vertical    = Control.SIZE_SHRINK_CENTER


# ──────────────────────────────────────────────
#  Funciones Privadas — Cartas
# ──────────────────────────────────────────────

func _generate_cards() -> void:
	for child: Node in cards_container.get_children():
		child.queue_free()
	cards.clear()

	var theme_values: Array = THEMES.get(game_theme, THEMES["animals"])
	var selected_values: Array = []
	for i: int in total_pairs:
		selected_values.append(theme_values[i % theme_values.size()])

	var card_values: Array = []
	for value: String in selected_values:
		card_values.append(value)
		card_values.append(value)
	card_values.shuffle()

	for i: int in card_values.size():
		var card := _create_card(i, card_values[i])
		cards_container.add_child(card)
		if card.has_method("force_init"):
			card.force_init()
		cards.append(card)

	print(LOGP, "generate_cards: ", cards.size(), " cartas")


func _create_card(id: int, value: String) -> Control:
	var tile_scene: PackedScene = load("res://ui/components/MemoryTile.tscn")
	var card: Control           = tile_scene.instantiate()
	card.custom_minimum_size    = Vector2(card_size_px, card_size_px)
	card.set_meta("card_id",    id)
	card.set_meta("card_value", value)
	card.set_meta("is_flipped", false)
	card.set_meta("is_matched", false)
	card.pivot_offset = Vector2(card_size_px / 2.0, card_size_px / 2.0)

	var theme_values: Array = THEMES.get(game_theme, THEMES["animals"])
	var val_idx: int = theme_values.find(value)
	if val_idx < 0:
		val_idx = id % 8
	card.color_index = val_idx % 8

	# Contenido frontal según tema
	var front_text: String     = _get_front_text(value)
	var front_icon: Texture2D  = null
	card.set_front_content(front_text, front_icon)
	card.set_meta("front_text", front_text)

	card.pressed.connect(_on_card_pressed.bind(card))
	return card


func _get_front_text(value: String) -> String:
	match game_theme:
		"animals":
			var animal_emojis := {
				"perro": "🐕", "gato": "🐈", "león": "🦁", "elefante": "🐘",
				"jirafa": "🦒", "mono": "🐵", "oso": "🐻", "panda": "🐼",
			}
			return animal_emojis.get(value, "🐾")
		"colors":
			var color_emojis := {
				"rojo": "🔴", "azul": "🔵", "verde": "🟢", "amarillo": "🟡",
				"morado": "🟣", "naranja": "🟠", "rosa": "💗", "café": "🟤",
			}
			return color_emojis.get(value, value.to_upper())
		"numbers":
			var number_emojis := {
				"1": "1️⃣", "2": "2️⃣", "3": "3️⃣", "4": "4️⃣",
				"5": "5️⃣", "6": "6️⃣", "7": "7️⃣", "8": "8️⃣",
			}
			return number_emojis.get(value, value)
		_:
			return value.to_upper()


# ──────────────────────────────────────────────
#  Funciones Privadas — Lógica de Juego
# ──────────────────────────────────────────────

func _handle_card_tap(card: Control) -> void:
	if not can_flip:
		return
	if card.get_meta("is_flipped") or card.get_meta("is_matched"):
		return
	if flipped_cards.size() >= 2:
		return

	print(LOGP, "voltear carta id=", card.get_meta("card_id"))
	_animate_card_flip(card, true)
	card.set_meta("is_flipped", true)
	flipped_cards.append(card)

	if flipped_cards.size() == 2:
		can_flip = false
		attempts += 1
		_update_attempts_label()
		await get_tree().create_timer(0.8).timeout
		_check_match()


func _check_match() -> void:
	if flipped_cards.size() != 2:
		return

	var card1: Control = flipped_cards[0]
	var card2: Control = flipped_cards[1]
	var value1: String = card1.get_meta("card_value")
	var value2: String = card2.get_meta("card_value")

	if value1 == value2:
		print(LOGP, "MATCH: ", value1)
		_on_match_found(card1, card2)
	else:
		print(LOGP, "NO MATCH: ", value1, " vs ", value2)
		_on_match_failed(card1, card2)


func _on_match_found(card1: Control, card2: Control) -> void:
	card1.set_meta("is_matched", true)
	card2.set_meta("is_matched", true)
	if card1.has_method("set_matched"):
		card1.set_matched(true)
	if card2.has_method("set_matched"):
		card2.set_matched(true)

	matched_pairs += 1
	AnimationHelper.success_effect(card1)
	AnimationHelper.success_effect(card2)
	AnimationHelper.create_sparkle_effect(self, card1.global_position + card1.size / 2, 15)
	AnimationHelper.create_sparkle_effect(self, card2.global_position + card2.size / 2, 15)
	_animate_match_disappear(card1, card2)

	AudioManager.play_success()
	if matched_pairs % 2 == 0:
		VoiceInstructions.play_feedback(true, false)

	flipped_cards.clear()
	can_flip = true
	failed_attempts_on_pair = 0

	if matched_pairs >= total_pairs:
		await get_tree().create_timer(1.0).timeout
		_complete_game()


func _on_match_failed(card1: Control, card2: Control) -> void:
	failed_attempts_on_pair += 1
	_animate_no_match(card1, card2)
	await get_tree().create_timer(0.3).timeout
	_animate_card_flip(card1, false)
	_animate_card_flip(card2, false)
	card1.set_meta("is_flipped", false)
	card2.set_meta("is_flipped", false)

	AudioManager.play_error()
	flipped_cards.clear()
	can_flip = true

	# Pista suave para niños ≤3 años tras varios intentos fallidos
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm and gm.current_player_profile and gm.current_player_profile.age <= 3:
		if failed_attempts_on_pair >= 3:
			_show_gentle_hint()


func _complete_game() -> void:
	var elapsed_time: float = (Time.get_ticks_msec() / 1000.0) - start_time
	var stars: int          = _calculate_stars(attempts, grid_size.x * grid_size.y)
	_celebrate_completion()
	_animate_game_complete()
	GameManager.complete_game("MemoryGame", stars, elapsed_time)
	game_completed.emit(stars, elapsed_time)


func _calculate_stars(num_attempts: int, total_cards: int) -> int:
	var min_attempts: int = total_cards / 2
	if num_attempts <= min_attempts + 3:
		return 3
	elif num_attempts <= min_attempts + 8:
		return 2
	return 1


func _celebrate_completion() -> void:
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 80)
	AudioManager.play_game_complete()
	VoiceInstructions.play_feedback(true)
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(300)


func _update_attempts_label() -> void:
	# Sin contador visible para perfil ≤3 años
	pass


func _get_unmatched_cards() -> Array:
	var res: Array = []
	for c: Control in cards:
		if not c.get_meta("is_matched"):
			res.append(c)
	return res


func _show_gentle_hint() -> void:
	var unmatched := _get_unmatched_cards()
	if unmatched.size() < 2:
		return
	var first: Control = unmatched[0]
	var target_val: String = first.get_meta("card_value")
	var pair: Control = null
	for c: Control in unmatched:
		if c != first and c.get_meta("card_value") == target_val:
			pair = c
			break
	if pair == null:
		return
	print(LOGP, "hint: par '", target_val, "' resaltado")
	for c: Control in [first, pair]:
		var tw := create_tween()
		tw.set_loops(3)
		tw.tween_property(c, "modulate", Color(1.3, 1.3, 1.3, 1.0), 0.25)
		tw.tween_property(c, "modulate", Color.WHITE,                 0.25)


# ──────────────────────────────────────────────
#  Funciones Privadas — Animaciones
# ──────────────────────────────────────────────

func _animate_game_entry() -> void:
	for i: int in cards.size():
		var card: Control = cards[i]
		card.modulate.a = 0.0
		card.scale      = Vector2(0.5, 0.5)
		card.pivot_offset = Vector2(card_size_px / 2.0, card_size_px / 2.0)

		var delay: float = 0.04 * i
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(card, "modulate:a", 1.0, 0.20).set_delay(delay)
		tween.tween_property(card, "scale", Vector2.ONE, 0.25).set_delay(delay)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _animate_card_flip(card: Control, show_front: bool) -> void:
	print(LOGP, "_animate_card_flip show_front=", show_front)
	AudioManager.play_button_press()
	if card.has_method("set_revealed"):
		card.set_revealed(show_front)
	else:
		# Fallback si no es MemoryTile
		if show_front:
			card.text = card.get_meta("front_text", "?")
		else:
			card.text = "?"


func _animate_match_disappear(card1: Control, card2: Control) -> void:
	for c: Control in [card1, card2]:
		var t := create_tween()
		t.set_ease(Tween.EASE_IN_OUT)
		t.set_trans(Tween.TRANS_BACK)
		# Pulso rápido
		t.tween_property(c, "scale", Vector2(1.2, 1.2), 0.15)
		t.tween_property(c, "scale", Vector2.ONE,        0.10)
		# Fade out
		t.tween_property(c, "modulate:a", 0.0, 0.30)
		# Deshabilitar al terminar
		t.tween_callback(func() -> void:
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if c.has_method("set") and c.get("disabled") != null:
				c.disabled = true
		)
	print(LOGP, "animate_match_disappear: cartas desapareciendo")


func _animate_no_match(card1: Control, card2: Control) -> void:
	for c: Control in [card1, card2]:
		var tween_err := create_tween()
		tween_err.tween_property(c, "modulate", Color(1.0, 0.6, 0.6), 0.12)
		tween_err.tween_property(c, "modulate", Color.WHITE,           0.12)
	await get_tree().create_timer(0.25).timeout
	print(LOGP, "animate_no_match completo")


func _animate_game_complete() -> void:
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 80)
	VoiceInstructions.play_feedback(true)
	print(LOGP, "animate_game_complete: celebración")


func _add_decorations() -> void:
	var layer := _ensure_decorations_layer()
	var vp := get_viewport_rect().size
	# 3 estrellas sutiles parpadeantes
	var star_chars: Array[String] = ["⭐", "✨", "🌟"]
	for i: int in 3:
		var star := Label.new()
		star.text = star_chars[i]
		star.add_theme_font_size_override("font_size", 44)
		star.modulate = Color(1, 1, 1, 0.45)
		star.position = Vector2(30 + (randi() % int(vp.x - 60)), 140 + (randi() % int(vp.y - 200)))
		star.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(star)
		var t := create_tween()
		t.set_loops()
		t.tween_property(star, "modulate:a", 0.20, 2.0 + randf())
		t.tween_property(star, "modulate:a", 0.55, 2.0 + randf())
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ensure_decorations_layer() -> Control:
	if decorations_layer and is_instance_valid(decorations_layer):
		return decorations_layer
	decorations_layer = Control.new()
	decorations_layer.name = "Decorations"
	add_child(decorations_layer)
	return decorations_layer


# ──────────────────────────────────────────────
#  Funciones Privadas — Input y Navegación
# ──────────────────────────────────────────────

func _on_back_pressed() -> void:
	print(LOGP, "🏠 _on_back_pressed")
	AudioManager.play_back()
	var bootstrap: Node = get_node_or_null("/root/UiBootstrap")
	if bootstrap and bootstrap.has_method("fade_to_scene"):
		bootstrap.fade_to_scene("res://scenes/main/GameSelector.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main/GameSelector.tscn")


func _on_card_pressed(card: Control) -> void:
	print(LOGP, "🎯 card_pressed id=", card.get_meta("card_id", -1))
	var now: float = Time.get_ticks_msec() / 1000.0
	if now - _last_tap_time < 0.30:
		return
	_last_tap_time = now
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(30)
	_handle_card_tap(card)
