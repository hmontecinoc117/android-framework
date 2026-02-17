## Juego de unir objetos con su pareja mediante líneas.
## Conecta elementos de la columna izquierda con su par correcto en la derecha.

extends Node2D


# ──────────────────────────────────────────────
#  Señales
# ──────────────────────────────────────────────

signal game_completed(stars: int, time: float)


# ──────────────────────────────────────────────
#  Constantes
# ──────────────────────────────────────────────

const LOGP := "[MatchingGame] "

const MATCHING_THEMES: Dictionary = {
	"animal_food": {
		"instruction": "Une cada animal con su comida",
		"pairs": [
			{"left": "🐶 Perro", "right": "🦴 Hueso", "id": "dog_bone"},
			{"left": "🐱 Gato", "right": "🐟 Pescado", "id": "cat_fish"},
			{"left": "🐰 Conejo", "right": "🥕 Zanahoria", "id": "rabbit_carrot"},
			{"left": "🐼 Oso", "right": "🎋 Bambú", "id": "panda_bamboo"},
			{"left": "🐝 Abeja", "right": "🌸 Flor", "id": "bee_flower"}
		]
	},
	"animal_habitat": {
		"instruction": "Une cada animal con su hogar",
		"pairs": [
			{"left": "🐟 Pez", "right": "💧 Agua", "id": "fish_water"},
			{"left": "🐦 Pájaro", "right": "🌳 Árbol", "id": "bird_tree"},
			{"left": "🐻 Oso", "right": "🏔️ Montaña", "id": "bear_mountain"},
			{"left": "🐪 Camello", "right": "🏜️ Desierto", "id": "camel_desert"},
			{"left": "🐧 Pingüino", "right": "❄️ Hielo", "id": "penguin_ice"}
		]
	},
	"object_shadow": {
		"instruction": "Une cada objeto con su sombra",
		"pairs": [
			{"left": "⭐ Estrella", "right": "★", "id": "star_shadow"},
			{"left": "❤️ Corazón", "right": "♥", "id": "heart_shadow"},
			{"left": "🌙 Luna", "right": "☽", "id": "moon_shadow"},
			{"left": "☀️ Sol", "right": "☼", "id": "sun_shadow"},
			{"left": "🔔 Campana", "right": "🔕", "id": "bell_shadow"}
		]
	},
	"number_quantity": {
		"instruction": "Une el número con la cantidad",
		"pairs": [
			{"left": "1", "right": "⭐", "id": "one_one"},
			{"left": "2", "right": "⭐⭐", "id": "two_two"},
			{"left": "3", "right": "⭐⭐⭐", "id": "three_three"},
			{"left": "4", "right": "⭐⭐⭐⭐", "id": "four_four"},
			{"left": "5", "right": "⭐⭐⭐⭐⭐", "id": "five_five"}
		]
	},
	"letter_word": {
		"instruction": "Une la letra con la palabra que empieza así",
		"pairs": [
			{"left": "A", "right": "🍎 Manzana", "id": "a_apple"},
			{"left": "B", "right": "🎈 Globo", "id": "b_balloon"},
			{"left": "C", "right": "🏠 Casa", "id": "c_house"},
			{"left": "D", "right": "🦷 Diente", "id": "d_tooth"},
			{"left": "E", "right": "🐘 Elefante", "id": "e_elephant"}
		]
	}
}


# ──────────────────────────────────────────────
#  Variables Exportadas
# ──────────────────────────────────────────────

@export var matching_theme: String = "animal_food"


# ──────────────────────────────────────────────
#  Variables Miembro
# ──────────────────────────────────────────────

# --- Nodos ---
var left_container: Node = null
var right_container: Node = null
var lines_layer: Node = null
var instruction_label: Label = null
var score_label: Label = null

# --- Estado del juego ---
var current_line_start: Control = null
var drawing_line: bool = false
var line_drawer: Line2D = null
var matched_pairs: int = 0
var total_pairs: int = 0
var attempts: int = 0
var start_time: float = 0.0
var permanent_lines: Array[Line2D] = []
var left_items: Array = []
var right_items: Array = []


# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	# Obtener nodos
	left_container = get_node_or_null("MatchingArea/LeftContainer")
	right_container = get_node_or_null("MatchingArea/RightContainer")
	lines_layer = get_node_or_null("LinesLayer")
	instruction_label = get_node_or_null("UI/TopBar/InstructionLabel")
	score_label = get_node_or_null("UI/TopBar/ScoreLabel")

	_apply_ui_assets()
	_setup_game()
	start_time = Time.get_ticks_msec() / 1000.0
	VoiceInstructions.play_instruction("matching_game")

	# Crear line drawer temporal
	line_drawer = Line2D.new()
	line_drawer.width = 8.0
	line_drawer.default_color = Color.YELLOW
	line_drawer.visible = false
	lines_layer.add_child(line_drawer)
	print(LOGP, "_ready completado")


func _process(_delta: float) -> void:
	if drawing_line and line_drawer and current_line_start:
		# Actualizar línea temporal siguiendo el mouse/touch
		var mouse_pos := get_global_mouse_position()

		if line_drawer.get_point_count() > 1:
			line_drawer.set_point_position(1, mouse_pos)
		else:
			line_drawer.add_point(mouse_pos)


# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func change_theme(new_theme: String) -> void:
	if MATCHING_THEMES.has(new_theme):
		matching_theme = new_theme
		reset_game()


func reset_game() -> void:
	matched_pairs = 0
	attempts = 0

	# Limpiar líneas permanentes
	for line in permanent_lines:
		line.queue_free()
	permanent_lines.clear()

	start_time = Time.get_ticks_msec() / 1000.0
	_setup_game()


# ──────────────────────────────────────────────
#  Funciones Privadas — Setup
# ──────────────────────────────────────────────

func _apply_ui_assets() -> void:
	# Fondo
	var bg_path := "res://assets/backgrounds/panel_grid_paper.png"
	var background_node := get_node_or_null("Background")
	if background_node and ResourceLoader.exists(bg_path):
		var tex := load(bg_path)
		var tex_rect := TextureRect.new()
		tex_rect.texture = tex
		tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
		tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(tex_rect)
		background_node.queue_free()

	# Botón atrás
	var back_button := get_node_or_null("UI/TopBar/BackButton")
	if back_button:
		DesignSystem.apply_button_style(back_button, "error")
		back_button.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	AudioManager.play_back()
	var bootstrap: Node = get_node_or_null("/root/UiBootstrap")
	if bootstrap and bootstrap.has_method("fade_to_scene"):
		bootstrap.fade_to_scene("res://scenes/main/GameSelector.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main/GameSelector.tscn")


func _setup_game() -> void:
	var theme_data := MATCHING_THEMES.get(matching_theme, MATCHING_THEMES["animal_food"])

	if instruction_label:
		instruction_label.text = theme_data["instruction"]

	var pairs: Array = theme_data["pairs"]
	total_pairs = pairs.size()

	# Crear items
	_create_matching_items(pairs)
	_update_score_label()


func _create_matching_items(pairs: Array) -> void:
	# Limpiar contenedores
	for child in left_container.get_children():
		child.queue_free()
	for child in right_container.get_children():
		child.queue_free()

	left_items.clear()
	right_items.clear()

	# Mezclar orden del lado derecho
	var right_data := pairs.duplicate()
	right_data.shuffle()

	# Crear items izquierdos
	for i in pairs.size():
		var left_item := _create_item(pairs[i]["left"], pairs[i]["id"], true)
		left_container.add_child(left_item)
		left_items.append(left_item)

	# Crear items derechos
	for i in right_data.size():
		var right_item := _create_item(right_data[i]["right"], right_data[i]["id"], false)
		right_container.add_child(right_item)
		right_items.append(right_item)


func _create_item(text: String, match_id: String, is_left: bool) -> Control:
	var item := Panel.new()

	item.custom_minimum_size = DesignSystem.BTN_MEDIUM

	item.set_meta("match_id", match_id)
	item.set_meta("is_left", is_left)
	item.set_meta("is_matched", false)

	# Label
	var label := Label.new()
	label.text = text
	DesignSystem.setup_label(label, DesignSystem.FONT_MEDIUM, Color.WHITE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	item.add_child(label)

	# Conectar input
	item.gui_input.connect(_on_item_input.bind(item))

	return item


# ──────────────────────────────────────────────
#  Funciones Privadas — Interacción
# ──────────────────────────────────────────────

func _on_item_input(event: InputEvent, item: Control) -> void:
	if not event is InputEventMouseButton and not event is InputEventScreenTouch:
		return

	if item.get_meta("is_matched"):
		return

	if event.pressed:
		if item.get_meta("is_left"):
			_start_line(item)
	else:
		if drawing_line:
			_end_line(item)


func _start_line(item: Control) -> void:
	current_line_start = item
	drawing_line = true
	line_drawer.clear_points()
	line_drawer.add_point(item.global_position + item.size / 2)
	line_drawer.visible = true
	AudioManager.play_pickup()


func _end_line(target_item: Control) -> void:
	if not drawing_line or not current_line_start:
		return

	drawing_line = false
	line_drawer.visible = false

	# Verificar si el target es un item derecho
	if not target_item.get_meta("is_left"):
		attempts += 1

		if _check_match(current_line_start, target_item):
			_on_match_success(current_line_start, target_item)
		else:
			_on_match_failed()
	else:
		AudioManager.play_error()

	current_line_start = null


func _check_match(left_item: Control, right_item: Control) -> bool:
	var left_id := left_item.get_meta("match_id")
	var right_id := right_item.get_meta("match_id")
	return left_id == right_id


# ──────────────────────────────────────────────
#  Funciones Privadas — Resultado
# ──────────────────────────────────────────────

func _on_match_success(left_item: Control, right_item: Control) -> void:
	# Marcar como emparejados
	left_item.set_meta("is_matched", true)
	right_item.set_meta("is_matched", true)

	matched_pairs += 1

	# Crear línea permanente
	_create_permanent_line(left_item, right_item, DesignSystem.get_color("success"))

	# Efectos visuales
	AnimationHelper.success_effect(left_item)
	AnimationHelper.success_effect(right_item)
	AnimationHelper.create_sparkle_effect(self, left_item.global_position + left_item.size / 2, 15)
	AnimationHelper.create_sparkle_effect(self, right_item.global_position + right_item.size / 2, 15)

	# Cambiar color de fondo
	if left_item is Panel:
		var stylebox := StyleBoxFlat.new()
		stylebox.bg_color = Color(0.5, 1, 0.5, 0.3)
		left_item.add_theme_stylebox_override("panel", stylebox)

	if right_item is Panel:
		var stylebox := StyleBoxFlat.new()
		stylebox.bg_color = Color(0.5, 1, 0.5, 0.3)
		right_item.add_theme_stylebox_override("panel", stylebox)

	# Sonido y feedback
	AudioManager.play_success()

	if matched_pairs % 2 == 0:
		VoiceInstructions.play_feedback(true, false)

	_update_score_label()

	# Verificar si completó
	if matched_pairs >= total_pairs:
		await get_tree().create_timer(1.0).timeout
		_complete_game()


func _on_match_failed() -> void:
	# Efecto de error suave
	_flash_line_error()
	AudioManager.play_error()


func _create_permanent_line(from_item: Control, to_item: Control, color: Color) -> void:
	var line := Line2D.new()
	line.width = 6.0
	line.default_color = color

	var start_pos := from_item.global_position + from_item.size / 2
	var end_pos := to_item.global_position + to_item.size / 2

	line.add_point(start_pos)
	line.add_point(end_pos)

	lines_layer.add_child(line)
	permanent_lines.append(line)


func _flash_line_error() -> void:
	var error_line := Line2D.new()
	error_line.width = 8.0
	error_line.default_color = DesignSystem.get_color("error")

	if current_line_start:
		error_line.add_point(current_line_start.global_position + current_line_start.size / 2)
		error_line.add_point(get_global_mouse_position())
		lines_layer.add_child(error_line)

		# Animación de desvanecimiento
		var tween := create_tween()
		tween.tween_property(error_line, "modulate:a", 0.0, 0.5)
		await tween.finished
		error_line.queue_free()


func _complete_game() -> void:
	var elapsed_time := (Time.get_ticks_msec() / 1000.0) - start_time
	var stars := _calculate_stars(attempts, total_pairs)

	_celebrate_completion()
	GameManager.complete_game("MatchingGame", stars, elapsed_time)
	game_completed.emit(stars, elapsed_time)
	print(LOGP, "completado: estrellas=", stars, " tiempo=", elapsed_time)


func _calculate_stars(num_attempts: int, pairs_count: int) -> int:
	# Intentos perfectos = número de pares (una línea por par)
	if num_attempts <= pairs_count:
		return 3
	elif num_attempts <= pairs_count + 3:
		return 2
	else:
		return 1


func _celebrate_completion() -> void:
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 80)
	AudioManager.play_game_complete()
	VoiceInstructions.play_feedback(true)

	if OS.has_feature("mobile"):
		Input.vibrate_handheld(300)


func _update_score_label() -> void:
	if score_label:
		score_label.text = "Parejas: %d / %d" % [matched_pairs, total_pairs]
