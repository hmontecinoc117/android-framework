# MainMenu.gd
extends Control

func _ready():
	# Redirigir inmediatamente al selector de juegos
	print("MainMenu: redirigiendo a GameSelector...")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main/GameSelector.tscn")
	return

func _on_button_input(event):
	print("🖱️ Input recibido:", event)
	if event is InputEventScreenTouch:
		print("   Touch en:", event.position, "presionado:", event.pressed)
		# Tratar el release como click en móviles
		if not event.pressed:
			print("✅ Detectado toque de botón (release). Disparando acción...")
			_on_play_pressed()

func _on_mouse_entered():
	print("🖱️ Mouse entró al botón")

func _on_mouse_exited():
	print("🖱️ Mouse salió del botón")

func _on_play_pressed():
	print("========================================")
	print("🎮 BOTÓN PLAY PRESIONADO!!!")
	print("Cambiando a GameSelector...")
	print("========================================")
	# Cambio diferido para evitar !is_inside_tree() al alternar rápido
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main/GameSelector.tscn")

func _input(event):
	if event is InputEventScreenTouch:
		print("🌍 Input global - Touch en:", event.position, "presionado:", event.pressed)

