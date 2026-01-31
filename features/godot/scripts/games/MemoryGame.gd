# MemoryGame.gd
# Juego de memoria (memorice) con temáticas variadas
extends Node2D

signal game_completed(stars: int, time: float)
const LOGP := "[MemoryGame] "

# Configuración del juego
@export var grid_size: Vector2i = Vector2i(4, 3)  # 4x3 = 12 cartas (6 parejas)
@export var theme: String = "animals"  # animals, fruits, colors, numbers, shapes, vehicles

# Nodos
var cards_container
var attempts_label
var timer_label
var theme_selector
var back_button
var background_node

# Variables del juego
var cards: Array = []
var flipped_cards: Array = []
var matched_pairs: int = 0
var total_pairs: int = 0
var attempts: int = 0
var start_time: float = 0.0
var can_flip: bool = true
var card_size_px: float = 120.0
var failed_attempts_on_pair: int = 0

# Temáticas disponibles
const THEMES = {
	"animals": ["perro", "gato", "león", "elefante", "jirafa", "mono", "oso", "tigre"],
	"fruits": ["manzana", "plátano", "uva", "fresa", "sandía", "piña", "naranja", "pera"],
	"colors": ["rojo", "azul", "verde", "amarillo", "morado", "naranja", "rosa", "café"],
	"numbers": ["1", "2", "3", "4", "5", "6", "7", "8"],
	"shapes": ["círculo", "cuadrado", "triángulo", "estrella", "corazón", "rombo", "hexágono", "óvalo"],
	"vehicles": ["carro", "avión", "barco", "bicicleta", "tren", "bus", "moto", "camión"]
}

# Mapeo de nombre (es) -> imagen de animal
const ANIMAL_IMAGE_MAP := {
	"perro": "res://assets/images/animals/perro.png",
	"gato": "res://assets/images/animals/gato.png",
	"león": "res://assets/images/animals/leon.png",
	"elefante": "res://assets/images/animals/elephant.png",
	"jirafa": "res://assets/images/animals/giraffe.png",
	"mono": "res://assets/images/animals/mono.png",
	"oso": "res://assets/images/animals/bear.png",
	"tigre": "res://assets/images/animals/tiger.png", # puede no existir; se usa placeholder si falta
	"vaca": "res://assets/images/animals/vaca.png",
	"oveja": "res://assets/images/animals/oveja.png",
	"zorro": "res://assets/images/animals/zorro.png"
}

func _ready():
	# Obtener nodos
	cards_container = get_node_or_null("CardsContainer")
	attempts_label = get_node_or_null("UI/TopBar/AttemptsLabel")
	timer_label = get_node_or_null("UI/TopBar/TimerLabel")
	theme_selector = get_node_or_null("UI/TopBar/ThemeSelector")
	back_button = get_node_or_null("UI/TopBar/BackButton")
	background_node = get_node_or_null("Background")

	apply_ui_assets()
	print(LOGP, "_ready: theme=", theme, " grid=", grid_size)

	# Ajustar dificultad por edad (muy fácil para <= 3 años)
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.current_player_profile and gm.current_player_profile.age <= 3:
		print(LOGP, "perfil edad<=3: ajustando grid a 2x2 y ocultando intentos/timer")
		grid_size = Vector2i(2, 2)
		# Ocultar contador de intentos y timer para evitar presión
		if attempts_label:
			attempts_label.visible = false
		if timer_label:
			timer_label.visible = false

	setup_game()
	setup_safe_exit()
	await get_tree().process_frame
	print(LOGP, "setup_game completado: total_pairs=", total_pairs, " cartas=", cards.size())
	animate_game_entry()
	start_time = Time.get_ticks_msec() / 1000.0
	
	# Reproducir instrucción
	VoiceInstructions.play_instruction("memory_game")
	print(LOGP, "instrucción reproducida para memory_game")
	
	# Iniciar timer
	set_process(true)

func _process(_delta):
	# Actualizar timer
	if timer_label and matched_pairs < total_pairs:
		var elapsed = (Time.get_ticks_msec() / 1000.0) - start_time
		timer_label.text = "Tiempo: %02d:%02d" % [int(elapsed / 60), int(elapsed) % 60]

func setup_game():
	total_pairs = (grid_size.x * grid_size.y) / 2
	
	# Configurar contenedor de cartas
	if cards_container:
		setup_grid_container()
	
	# Generar y colocar cartas
	generate_cards()
	# Controles táctiles amigables
	setup_touch_friendly_controls()
	# Animación de respiración sutil en cartas no volteadas
	for c in cards:
		add_card_breathing_animation(c)
	print(LOGP, "setup_game: grid=", grid_size, " total_pairs=", total_pairs, " cartas=", cards.size())

func setup_grid_container():
	# Configurar GridContainer
	if cards_container is GridContainer:
		cards_container.columns = grid_size.x
		# Separación para evitar superposición
		cards_container.add_theme_constant_override("h_separation", 24)
		cards_container.add_theme_constant_override("v_separation", 24)
		
		# Calcular tamaño de cartas según pantalla
		var viewport_size = get_viewport_rect().size
		var available_width = viewport_size.x * 0.9
		var available_height = viewport_size.y * 0.7
		
		var card_width = available_width / grid_size.x
		var card_height = available_height / grid_size.y
		
		# Usar el menor para mantener aspecto cuadrado
		var card_size = min(card_width, card_height) - 20  # 20px de margen
		card_size_px = clamp(card_size, 120.0, 320.0)

		# Centrar el contenedor y ajustar tamaño mínimo para que quede centrado
		var hsep = cards_container.get_theme_constant("h_separation")
		var vsep = cards_container.get_theme_constant("v_separation")
		var grid_w = card_size_px * grid_size.x + hsep * (grid_size.x - 1)
		var grid_h = card_size_px * grid_size.y + vsep * (grid_size.y - 1)
		if cards_container is Control:
			cards_container.set_anchors_preset(Control.PRESET_CENTER)
			cards_container.custom_minimum_size = Vector2(grid_w, grid_h)
			cards_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			cards_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER

func apply_ui_assets():
	# Fondo con textura si existe
	var bg_path = "res://assets/backgrounds/panel_grid_paper.png"
	if background_node and ResourceLoader.exists(bg_path):
		# Sustituir ColorRect por TextureRect manteniendo anclajes
		var tex := load(bg_path)
		var tex_rect := TextureRect.new()
		tex_rect.texture = tex
		tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
		tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(tex_rect)
		if background_node:
			background_node.queue_free()

	# Estilo del botón Atrás
	if back_button:
		var normal_tex_path = "res://assets/images/ui/button_grey.png"
		var pressed_tex_path = "res://assets/images/ui/button_red_close.png"
		if ResourceLoader.exists(normal_tex_path):
			var sb_normal := StyleBoxTexture.new()
			sb_normal.texture = load(normal_tex_path)
			sb_normal.expand_margin_left = 20
			sb_normal.expand_margin_right = 20
			sb_normal.expand_margin_top = 20
			sb_normal.expand_margin_bottom = 20
			back_button.add_theme_stylebox_override("normal", sb_normal)
			var sb_hover := sb_normal.duplicate()
			back_button.add_theme_stylebox_override("hover", sb_hover)
			if ResourceLoader.exists(pressed_tex_path):
				var sb_pressed := StyleBoxTexture.new()
				sb_pressed.texture = load(pressed_tex_path)
				sb_pressed.expand_margin_left = 20
				sb_pressed.expand_margin_right = 20
				sb_pressed.expand_margin_top = 20
				sb_pressed.expand_margin_bottom = 20
				back_button.add_theme_stylebox_override("pressed", sb_pressed)
		back_button.custom_minimum_size = Vector2(260, 140)
		back_button.add_theme_font_size_override("font_size", 80)
		if not back_button.is_connected("pressed", _on_back_pressed):
			back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed():
	show_exit_confirmation()

func generate_cards():
	# Limpiar cartas existentes
	for child in cards_container.get_children():
		child.queue_free()
	cards.clear()
	
	# Obtener valores de cartas según tema
	var theme_values = THEMES.get(theme, THEMES["animals"])
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
		var card = create_card(i, card_values[i])
		cards_container.add_child(card)
		cards.append(card)
	print(LOGP, "generate_cards: creadas ", cards.size(), " cartas con valores únicos=", selected_values)

func create_card(id: int, value: String) -> Control:
	var card = Panel.new()
	card.custom_minimum_size = Vector2(card_size_px, card_size_px)
	card.set_meta("card_id", id)
	card.set_meta("card_value", value)
	card.set_meta("is_flipped", false)
	card.set_meta("is_matched", false)

	# Borde y estilo para mejorar visibilidad
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 1)
	sb.border_color = Color(0.1, 0.4, 0.8, 1)
	sb.border_width_top = 4
	sb.border_width_bottom = 4
	sb.border_width_left = 4
	sb.border_width_right = 4
	sb.corner_radius_top_left = 18
	sb.corner_radius_top_right = 18
	sb.corner_radius_bottom_left = 18
	sb.corner_radius_bottom_right = 18
	card.add_theme_stylebox_override("panel", sb)
	
	# Contenedor para front/back
	var container = Control.new()
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	card.add_child(container)
	
	# Cara trasera (inicialmente visible) con textura de fondo
	var back = ColorRect.new()
	back.color = GameManager.COLOR_PRIMARY_BLUE
	back.set_anchors_preset(Control.PRESET_FULL_RECT)
	back.name = "Back"
	container.add_child(back)
	var back_tex_path = "res://assets/images/card_back.png"
	if ResourceLoader.exists(back_tex_path):
		var back_tex := TextureRect.new()
		back_tex.texture = load(back_tex_path)
		back_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		back_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
		back.add_child(back_tex)
	
	# Patrón en la parte trasera
	var back_label = Label.new()
	back_label.text = "?"
	back_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	back_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	back_label.add_theme_font_size_override("font_size", 96)
	back_label.add_theme_color_override("font_color", Color.WHITE)
	back_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	back.add_child(back_label)
	
	# Cara frontal (inicialmente oculta)
	var front = ColorRect.new()
	front.color = Color.WHITE
	front.set_anchors_preset(Control.PRESET_FULL_RECT)
	front.name = "Front"
	front.visible = false
	container.add_child(front)
	
	# Contenido de la carta (texto o imagen)
	if theme == "animals":
		var tex_rect = TextureRect.new()
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		tex_rect.texture = get_animal_texture(value)
		front.add_child(tex_rect)
	else:
		var content_label = Label.new()
		content_label.text = value.to_upper()
		content_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		content_label.add_theme_font_size_override("font_size", 48)
		content_label.add_theme_color_override("font_color", Color.BLACK)
		content_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		front.add_child(content_label)
	
	# Conectar input
	card.gui_input.connect(_on_card_gui_input.bind(card))
	card.gui_input.connect(_on_card_clicked.bind(card))
	
	return card

func get_animal_texture(value: String) -> Texture2D:
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

func _on_card_clicked(event: InputEvent, card: Control):
	# Aceptar pulsación (mouse o touch) y derivar a manejador común
	if not event is InputEventMouseButton and not event is InputEventScreenTouch:
		return
	if event is InputEventMouseButton and not event.pressed:
		return
	if event is InputEventScreenTouch and not event.pressed:
		return
	_handle_card_tap(card)

func _handle_card_tap(card: Control) -> void:
	if not can_flip:
		return
	# Verificar si ya está volteada o emparejada
	if card.get_meta("is_flipped") or card.get_meta("is_matched"):
		return
	# Verificar límite de cartas volteadas
	if flipped_cards.size() >= 2:
		return
	# Voltear carta
	await animate_card_flip(card, true)
	print(LOGP, "tap carta: id=", card.get_meta("card_id"), " valor=", card.get_meta("card_value"))
	flipped_cards.append(card)
	# Si hay 2 cartas volteadas, verificar coincidencia
	if flipped_cards.size() == 2:
		can_flip = false
		attempts += 1
		update_attempts_label()
		await get_tree().create_timer(0.5).timeout
		print(LOGP, "verificando match: valores=", flipped_cards[0].get_meta("card_value"), " & ", flipped_cards[1].get_meta("card_value"))
		check_match()

func animate_card_flip(card: Control, show_front: bool) -> void:
	# Mejor animación de volteo con bloqueo temporal
	card.set_meta("is_flipped", show_front)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var container: Control = card.get_child(0)
	var back = container.get_node("Back")
	var front = container.get_node("Front")

	# Sonido de flip
	AudioManager.play_button_press()
	print(LOGP, "flip: id=", card.get_meta("card_id"), " show_front=", show_front)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Primera mitad: escala X a 0
	tween.tween_property(container, "scale:x", 0.0, 0.2).from(1.0)
	# Cambiar visibilidad en el punto medio con pequeño flash
	tween.tween_callback(func():
		back.visible = not show_front
		front.visible = show_front
		if show_front:
			var flash = ColorRect.new()
			flash.color = Color(1, 1, 1, 0.6)
			flash.set_anchors_preset(Control.PRESET_FULL_RECT)
			card.add_child(flash)
			var ft = create_tween()
			ft.tween_property(flash, "modulate:a", 0.0, 0.15)
			ft.finished.connect(func(): flash.queue_free())
	)
	# Segunda mitad: escala X a 1 con ligero overshoot
	tween.tween_property(container, "scale:x", 1.1, 0.18).from(0.0)
	tween.tween_property(container, "scale:x", 1.0, 0.08)

	# Salto sutil al revelar
	if show_front:
		var ty = create_tween()
		ty.set_parallel(true)
		ty.tween_property(card, "position:y", card.position.y - 16, 0.12)
		ty.tween_property(card, "position:y", card.position.y, 0.12).set_delay(0.12)

	await tween.finished
	card.mouse_filter = Control.MOUSE_FILTER_STOP

func check_match():
	if flipped_cards.size() != 2:
		return
	
	var card1 = flipped_cards[0]
	var card2 = flipped_cards[1]
	
	var value1 = card1.get_meta("card_value")
	var value2 = card2.get_meta("card_value")
	
	if value1 == value2:
		# ¡Coinciden!
		on_match_found(card1, card2)
	else:
		# No coinciden
		on_match_failed(card1, card2)
	print(LOGP, "resultado match: ", value1, " vs ", value2, " => ", value1 == value2)

func on_match_found(card1: Control, card2: Control):
	# Marcar como emparejadas
	card1.set_meta("is_matched", true)
	card2.set_meta("is_matched", true)
	
	matched_pairs += 1
	
	# Efectos visuales
	AnimationHelper.success_effect(card1)
	AnimationHelper.success_effect(card2)
	AnimationHelper.create_sparkle_effect(self, card1.global_position + card1.size / 2, 15)
	AnimationHelper.create_sparkle_effect(self, card2.global_position + card2.size / 2, 15)
	animate_match_success(card1, card2)
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
		complete_game()

func on_match_failed(card1: Control, card2: Control):
	# Animación suave de intento fallido y volteo atrás
	failed_attempts_on_pair += 1
	print(LOGP, "match_failed: failed_attempts_on_pair=", failed_attempts_on_pair)
	await animate_no_match(card1, card2)
	await animate_card_flip(card1, false)
	await animate_card_flip(card2, false)
	
	# Sonido suave de error
	AudioManager.play_error()
	
	# Limpiar cartas volteadas
	flipped_cards.clear()
	can_flip = true

	# Sistema de ayuda: mostrar hint tras varios intentos fallidos
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.current_player_profile and gm.current_player_profile.age <= 3:
		if failed_attempts_on_pair >= 3:
			show_gentle_hint()

func complete_game():
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - start_time
	
	# Calcular estrellas según intentos
	var stars = calculate_stars(attempts, grid_size.x * grid_size.y)
	
	# Efectos de celebración
	celebrate_completion()
	animate_game_complete()
	
	# Registrar progreso
	GameManager.complete_game("MemoryGame", stars, elapsed_time)
	
	# Emitir señal
	game_completed.emit(stars, elapsed_time)

func calculate_stars(num_attempts: int, total_cards: int) -> int:
	# Calcular intentos mínimos posibles (número de pares)
	var min_attempts = total_cards / 2
	
	if num_attempts <= min_attempts + 3:
		return 3  # Excelente
	elif num_attempts <= min_attempts + 8:
		return 2  # Bueno
	else:
		return 1  # Completado

func celebrate_completion():
	# Confeti
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 80)
	
	# Sonido
	AudioManager.play_game_complete()
	
	# Feedback
	VoiceInstructions.play_feedback(true)
	
	# Vibración
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(300)

func update_attempts_label():
	if attempts_label:
		attempts_label.text = "Intentos: %d" % attempts

func change_theme(new_theme: String):
	if THEMES.has(new_theme):
		theme = new_theme
		reset_game()

func change_difficulty(new_grid_size: Vector2i):
	grid_size = new_grid_size
	reset_game()

func reset_game():
	matched_pairs = 0
	attempts = 0
	flipped_cards.clear()
	can_flip = true
	start_time = Time.get_ticks_msec() / 1000.0
	setup_game()
	update_attempts_label()

# =====================
# Animaciones y Usabilidad
# =====================

func animate_game_entry() -> void:
	# Entrada amigable: fondo y cartas apareciendo en cascada
	if background_node:
		AnimationHelper.fade_in(background_node, 0.4)
	print(LOGP, "animate_game_entry: iniciando")
	await get_tree().create_timer(0.2).timeout
	for i in cards.size():
		var card = cards[i]
		card.modulate.a = 0.0
		card.scale = Vector2(0.3, 0.3)
		await get_tree().create_timer(i * 0.06).timeout
		AnimationHelper.fade_in(card, 0.2)
		AnimationHelper.pop_in(card, 0.25)
		AudioManager.play_pickup()
	print(LOGP, "animate_game_entry: finalizado")

func animate_match_success(card1: Control, card2: Control) -> void:
	# Resaltado y desaparición suave
	for c in [card1, card2]:
		var t = create_tween()
		t.set_parallel(true)
		t.set_ease(Tween.EASE_IN)
		t.tween_property(c, "modulate:a", 0.0, 0.6)
		t.tween_property(c, "scale", c.scale * 1.2, 0.6)
		t.tween_property(c, "position:y", c.position.y - 32, 0.6)
		t.finished.connect(func():
			c.visible = false
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		)
	print(LOGP, "animate_match_success: ocultando cartas emparejadas")

func animate_no_match(card1: Control, card2: Control) -> void:
	# Shake horizontal suave y pequeña pausa
	for c in [card1, card2]:
		var original_pos = c.position
		var tween_shake = create_tween()
		tween_shake.set_loops(3)
		tween_shake.tween_property(c, "position:x", original_pos.x + 8, 0.05)
		tween_shake.tween_property(c, "position:x", original_pos.x - 8, 0.05)
		tween_shake.finished.connect(func(): c.position = original_pos)
	await get_tree().create_timer(0.3).timeout
	print(LOGP, "animate_no_match: shake y pausa completados")

func animate_game_complete() -> void:
	# Confeti + pequeño panel de resultado opcional
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 80)
	# Reproducir feedback de voz
	VoiceInstructions.play_feedback(true)
	print(LOGP, "animate_game_complete: celebración enviada")

func show_gentle_hint() -> void:
	# Pista visual sutil en una pareja no descubierta
	var unmatched = get_unmatched_cards()
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

func get_unmatched_cards() -> Array:
	var res: Array = []
	for c in cards:
		if not c.get_meta("is_matched"):
			res.append(c)
	return res

func setup_touch_friendly_controls() -> void:
	# Amplía el área táctil y previene taps rápidos
	for c in cards:
		var touch_area = Control.new()
		touch_area.custom_minimum_size = c.size * 1.2
		touch_area.mouse_filter = Control.MOUSE_FILTER_STOP
		touch_area.position = -c.size * 0.1
		c.add_child(touch_area)
		touch_area.gui_input.connect(_on_card_touch.bind(c))
	print(LOGP, "setup_touch_friendly_controls: áreas añadidas a ", cards.size(), " cartas")

func add_card_breathing_animation(card: Control) -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(card, "scale", Vector2.ONE * 1.01, 2.0)
	tween.tween_property(card, "scale", Vector2.ONE, 2.0)

var _last_tap_time: float = 0.0
func _on_card_touch(event: InputEvent, card: Control) -> void:
	# Procesar toque en la liberación (levantar dedo) con anti-doubletap
	if event is InputEventScreenTouch and not event.pressed:
		var now = Time.get_ticks_msec() / 1000.0
		if now - _last_tap_time < 0.3:
			return
		_last_tap_time = now
		if OS.has_feature("mobile"):
			Input.vibrate_handheld(30)
		_handle_card_tap(card)
		print(LOGP, "_on_card_touch: tap procesado id=", card.get_meta("card_id"))

func _on_card_gui_input(event: InputEvent, card: Control) -> void:
	# Microanimaciones de presionado/soltado
	if event is InputEventScreenTouch:
		if event.pressed:
			var t = create_tween()
			t.set_ease(Tween.EASE_OUT)
			t.set_trans(Tween.TRANS_CUBIC)
			t.tween_property(card, "scale", card.scale * 0.95, 0.1)
		else:
			var t2 = create_tween()
			t2.set_ease(Tween.EASE_OUT)
			t2.set_trans(Tween.TRANS_BACK)
			t2.tween_property(card, "scale", Vector2.ONE, 0.2)

func setup_safe_exit() -> void:
	if back_button and not back_button.is_connected("pressed", _on_back_pressed):
		back_button.pressed.connect(_on_back_pressed)

func show_exit_confirmation():
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
	yes_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/GameSelector.tscn"))
	
	VoiceInstructions.play_feedback(true, false)
