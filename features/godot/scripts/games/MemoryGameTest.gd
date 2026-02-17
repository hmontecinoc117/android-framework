extends Control

const LOGP := "[MemoryGame] "

# Emojis de animales
const ANIMALS := ["🐕", "🐈", "🦁", "🐘", "🦒", "🐵", "🐻", "🐼"]

var cards: Array = []
var flipped_cards: Array = []
var matched_pairs: int = 0
var can_flip: bool = true

func _ready():
	print(LOGP, "Iniciando Memory Game...")
	
	# Background colorido
	var bg = ColorRect.new()
	bg.color = Color(0.7, 0.9, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Título
	var title = Label.new()
	title.text = "🧠 MEMORIA 🧠"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 60)
	title.position = Vector2(540, 50)
	title.size = Vector2(800, 100)
	add_child(title)
	
	# Crear grid de cartas
	var grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 20)
	grid.set_anchors_preset(Control.PRESET_CENTER)
	grid.offset_left = -600
	grid.offset_right = 600
	grid.offset_top = -200
	grid.offset_bottom = 400
	add_child(grid)
	
	# Crear 8 cartas (4 pares)
	var values = [ANIMALS[0], ANIMALS[0], ANIMALS[1], ANIMALS[1], 
	              ANIMALS[2], ANIMALS[2], ANIMALS[3], ANIMALS[3]]
	values.shuffle()
	
	for i in 8:
		var card = create_card(i, values[i])
		grid.add_child(card)
		cards.append(card)
	
	# Botón de volver
	var back_btn = Button.new()
	back_btn.text = "🏠"
	back_btn.custom_minimum_size = Vector2(120, 120)
	back_btn.add_theme_font_size_override("font_size", 70)
	back_btn.set_anchors_preset(Control.PRESET_TOP_LEFT)
	back_btn.offset_left = 50
	back_btn.offset_top = 50
	back_btn.offset_right = 170
	back_btn.offset_bottom = 170
	back_btn.pressed.connect(go_back)
	add_child(back_btn)
	
	print(LOGP, "✅ Juego creado con", cards.size(), "cartas")


func create_card(id: int, emoji: String) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(280, 280)
	btn.add_theme_font_size_override("font_size", 140)
	btn.text = "❓"
	btn.focus_mode = Control.FOCUS_NONE
	
	# Estilo colorido
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.5, 0.7, 1)
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	btn.add_theme_stylebox_override("normal", style)
	
	# Metadata
	btn.set_meta("id", id)
	btn.set_meta("emoji", emoji)
	btn.set_meta("revealed", false)
	
	btn.pressed.connect(func(): on_card_pressed(btn))
	
	return btn


func on_card_pressed(card: Button):
	if not can_flip:
		return
	if card.get_meta("revealed"):
		return
	if flipped_cards.size() >= 2:
		return
	
	# Revelar carta
	card.text = card.get_meta("emoji")
	card.set_meta("revealed", true)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 0.8)
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	card.add_theme_stylebox_override("normal", style)
	
	flipped_cards.append(card)
	print(LOGP, "Carta volteada:", card.get_meta("emoji"))
	
	# Verificar si hay 2 cartas
	if flipped_cards.size() == 2:
		can_flip = false
		await get_tree().create_timer(0.8).timeout
		check_match()


func check_match():
	var card1 = flipped_cards[0]
	var card2 = flipped_cards[1]
	
	if card1.get_meta("emoji") == card2.get_meta("emoji"):
		print(LOGP, "✅ MATCH!")
		# Hacer desaparecer
		for card in [card1, card2]:
			var tween = create_tween()
			tween.tween_property(card, "modulate:a", 0.0, 0.4)
			card.disabled = true
		
		matched_pairs += 1
		
		# Verificar si ganó
		if matched_pairs == 4:
			await get_tree().create_timer(1.0).timeout
			show_victory()
	else:
		print(LOGP, "❌ No match")
		# Voltear de vuelta
		for card in [card1, card2]:
			card.text = "❓"
			card.set_meta("revealed", false)
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.5, 0.7, 1)
			style.corner_radius_top_left = 20
			style.corner_radius_top_right = 20
			style.corner_radius_bottom_left = 20
			style.corner_radius_bottom_right = 20
			card.add_theme_stylebox_override("normal", style)
	
	flipped_cards.clear()
	can_flip = true


func show_victory():
	var label = Label.new()
	label.text = "¡GANASTE! 🎉"
	label.add_theme_font_size_override("font_size", 120)
	label.add_theme_color_override("font_color", Color(1, 1, 0))
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.offset_left = -400
	label.offset_right = 400
	label.offset_top = -100
	label.offset_bottom = 100
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	
	await get_tree().create_timer(2.0).timeout
	go_back()


func go_back():
	print(LOGP, "Volviendo al selector...")
	var bootstrap = get_node_or_null("/root/UiBootstrap")
	if bootstrap and bootstrap.has_method("fade_to_scene"):
		bootstrap.fade_to_scene("res://scenes/main/GameSelector.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main/GameSelector.tscn")

