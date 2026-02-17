extends Control

const LOGP := "[MatchingGame] "

# Pares de emojis relacionados
const PAIRS := [
	["🐕", "🦴"],  # Perro - Hueso
	["🐈", "🐟"],  # Gato - Pescado
	["🐝", "🌸"],  # Abeja - Flor
	["🐻", "🍯"]   # Oso - Miel
]

var left_items: Array = []
var right_items: Array = []
var selected_left: Button = null
var selected_right: Button = null
var matched_pairs: int = 0

func _ready():
	print(LOGP, "Iniciando Matching Game...")
	
	# Título
	var title = Label.new()
	title.text = "Une las parejas 🔗"
	title.add_theme_font_size_override("font_size", 80)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 20
	title.offset_bottom = 120
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	
	# Contenedor principal
	var main_container = HBoxContainer.new()
	main_container.add_theme_constant_override("separation", 200)
	main_container.set_anchors_preset(Control.PRESET_CENTER)
	main_container.offset_left = -700
	main_container.offset_right = 700
	main_container.offset_top = -300
	main_container.offset_bottom = 300
	main_container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(main_container)
	
	# Columna izquierda
	var left_column = VBoxContainer.new()
	left_column.add_theme_constant_override("separation", 30)
	main_container.add_child(left_column)
	
	# Columna derecha  
	var right_column = VBoxContainer.new()
	right_column.add_theme_constant_override("separation", 30)
	main_container.add_child(right_column)
	
	# Mezclar pares
	var shuffled_pairs = PAIRS.duplicate()
	shuffled_pairs.shuffle()
	var right_emojis = []
	for pair in shuffled_pairs:
		right_emojis.append(pair[1])
	right_emojis.shuffle()
	
	# Crear botones
	for i in PAIRS.size():
		# Izquierda
		var left_btn = create_button(shuffled_pairs[i][0], i, true)
		left_column.add_child(left_btn)
		left_items.append(left_btn)
		
		# Derecha
		var right_btn = create_button(right_emojis[i], i, false)
		right_column.add_child(right_btn)
		right_items.append(right_btn)
	
	# Botón volver
	var back_btn = Button.new()
	back_btn.text = "🏠"
	back_btn.custom_minimum_size = Vector2(100, 100)
	back_btn.add_theme_font_size_override("font_size", 60)
	back_btn.set_anchors_preset(Control.PRESET_TOP_LEFT)
	back_btn.offset_left = 20
	back_btn.offset_top = 20
	back_btn.offset_right = 120
	back_btn.offset_bottom = 120
	back_btn.pressed.connect(go_back)
	add_child(back_btn)
	
	print(LOGP, "✅ Juego creado con", PAIRS.size(), "pares")


func create_button(emoji: String, pair_id: int, is_left: bool) -> Button:
	var btn = Button.new()
	btn.text = emoji
	btn.custom_minimum_size = Vector2(250, 140)
	btn.add_theme_font_size_override("font_size", 100)
	btn.focus_mode = Control.FOCUS_NONE
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.4, 0.6, 0.9) if is_left else Color(0.9, 0.6, 0.4)
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	btn.add_theme_stylebox_override("normal", style)
	
	btn.set_meta("emoji", emoji)
	btn.set_meta("pair_id", pair_id)
	btn.set_meta("is_left", is_left)
	btn.set_meta("matched", false)
	
	btn.pressed.connect(func(): on_button_pressed(btn))
	
	return btn


func on_button_pressed(btn: Button):
	if btn.get_meta("matched"):
		return
	
	if btn.get_meta("is_left"):
		# Deseleccionar anterior
		if selected_left:
			reset_button_style(selected_left)
		selected_left = btn
		highlight_button(btn)
	else:
		# Deseleccionar anterior
		if selected_right:
			reset_button_style(selected_right)
		selected_right = btn
		highlight_button(btn)
	
	# Verificar match
	if selected_left and selected_right:
		check_match()


func highlight_button(btn: Button):
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 0)  # Amarillo
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	style.border_width_left = 5
	style.border_width_right = 5
	style.border_width_top = 5
	style.border_width_bottom = 5
	style.border_color = Color(1, 0.5, 0)
	btn.add_theme_stylebox_override("normal", style)


func reset_button_style(btn: Button):
	if btn.get_meta("matched"):
		return
	var is_left = btn.get_meta("is_left")
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.4, 0.6, 0.9) if is_left else Color(0.9, 0.6, 0.4)
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	btn.add_theme_stylebox_override("normal", style)


func check_match():
	var left_emoji = selected_left.get_meta("emoji")
	var right_emoji = selected_right.get_meta("emoji")
	
	# Buscar si es un par válido
	var is_match = false
	for pair in PAIRS:
		if pair[0] == left_emoji and pair[1] == right_emoji:
			is_match = true
			break
	
	if is_match:
		print(LOGP, "✅ MATCH:", left_emoji, "+", right_emoji)
		# Marcar como emparejados
		for btn in [selected_left, selected_right]:
			btn.set_meta("matched", true)
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0, 1, 0, 0.3)  # Verde transparente
			style.corner_radius_top_left = 20
			style.corner_radius_top_right = 20
			style.corner_radius_bottom_left = 20
			style.corner_radius_bottom_right = 20
			btn.add_theme_stylebox_override("normal", style)
			btn.disabled = true
		
		matched_pairs += 1
		
		# Verificar victoria
		if matched_pairs == PAIRS.size():
			await get_tree().create_timer(1.0).timeout
			show_victory()
	else:
		print(LOGP, "❌ No match")
		# Resetear selección
		reset_button_style(selected_left)
		reset_button_style(selected_right)
	
	selected_left = null
	selected_right = null


func show_victory():
	var label = Label.new()
	label.text = "¡COMPLETADO! 🎉"
	label.add_theme_font_size_override("font_size", 120)
	label.add_theme_color_override("font_color", Color(1, 1, 0))
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.offset_left = -500
	label.offset_right = 500
	label.offset_top = -100
	label.offset_bottom = 100
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	
	await get_tree().create_timer(2.0).timeout
	go_back()


func go_back():
	get_tree().change_scene_to_file("res://scenes/main/GameSelector.tscn")
