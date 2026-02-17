## Tutorial inicial para primeros usuarios
## Se muestra solo la primera vez y explica controles básicos

extends Control

signal tutorial_completed()

# ──────────────────────────────────────────────
#  Constantes
# ──────────────────────────────────────────────

const LOGP := "[Tutorial] "

# ──────────────────────────────────────────────
#  Variables Miembro
# ──────────────────────────────────────────────

var current_step: int = 0
var total_steps: int = 4

# ──────────────────────────────────────────────
#  Nodos
# ──────────────────────────────────────────────

@onready var step_container: VBoxContainer = $StepContainer
@onready var mascot: Label = $StepContainer/Mascot
@onready var instruction_label: Label = $StepContainer/Instruction
@onready var continue_button: Button = $StepContainer/ContinueButton
@onready var skip_button: Button = $StepContainer/SkipButton
@onready var step_indicator: Label = $StepContainer/StepIndicator
@onready var hand_pointer: Label = $HandPointer

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	# Aplicar design system
	DesignSystem.setup_label(mascot, DesignSystem.FONT_HUGE, Color.WHITE)
	DesignSystem.setup_label(instruction_label, DesignSystem.FONT_MEDIUM, Color.WHITE)
	DesignSystem.setup_label(step_indicator, DesignSystem.FONT_SMALL, Color(1, 1, 1, 0.7))
	
	DesignSystem.apply_button_style(continue_button, "success")
	continue_button.custom_minimum_size = DesignSystem.BTN_LARGE
	continue_button.add_theme_font_size_override("font_size", DesignSystem.FONT_MEDIUM)
	continue_button.pressed.connect(_on_continue_pressed)
	
	DesignSystem.apply_button_style(skip_button, "text_light")
	skip_button.custom_minimum_size = DesignSystem.BTN_SMALL
	skip_button.add_theme_font_size_override("font_size", DesignSystem.FONT_SMALL)
	skip_button.pressed.connect(_on_skip_pressed)
	
	# Ocultar puntero al inicio
	if hand_pointer:
		hand_pointer.visible = false
	
	_show_step(0)
	
	# Reproducir instrucción
	VoiceInstructions.play_instruction("tutorial")
	print(LOGP, "Tutorial iniciado")

# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _show_step(step: int) -> void:
	current_step = step
	
	# Actualizar indicador
	if step_indicator:
		step_indicator.text = "Paso %d de %d" % [step + 1, total_steps]
	
	match step:
		0:
			_step_welcome()
		1:
			_step_tap()
		2:
			_step_drag()
		3:
			_step_games()
		_:
			_complete_tutorial()

func _step_welcome() -> void:
	mascot.text = "👋"
	instruction_label.text = "¡Hola! Soy tu guía.\n\n¡Vamos a jugar juntos!"
	continue_button.text = "¡Empezar!"
	AudioManager.play_button_press()
	DesignSystem.bounce_animation(mascot, 1.3, 0.4)

func _step_tap() -> void:
	mascot.text = "👆"
	instruction_label.text = "Toca la pantalla con tu dedo\npara seleccionar cosas"
	continue_button.text = "¡Entendido!"
	
	# Mostrar animación de dedo
	if hand_pointer:
		hand_pointer.visible = true
		hand_pointer.text = "☝️"
		hand_pointer.add_theme_font_size_override("font_size", 80)
		hand_pointer.position = continue_button.global_position + Vector2(-100, 50)
		DesignSystem.pulse_animation(hand_pointer)

func _step_drag() -> void:
	mascot.text = "✋"
	instruction_label.text = "Arrastra con tu dedo\npara mover cosas"
	continue_button.text = "¡Lo haré!"
	
	# Actualizar animación de dedo
	if hand_pointer:
		hand_pointer.text = "👉"
		var tween := create_tween()
		tween.set_loops()
		tween.tween_property(hand_pointer, "position:x", hand_pointer.position.x + 100, 1.0)
		tween.tween_property(hand_pointer, "position:x", hand_pointer.position.x, 1.0)

func _step_games() -> void:
	mascot.text = "🎮"
	instruction_label.text = "¡Ahora elige un juego\ny diviértete aprendiendo!"
	continue_button.text = "¡A jugar! 🚀"
	
	if hand_pointer:
		hand_pointer.visible = false

func _complete_tutorial() -> void:
	print(LOGP, "Tutorial completado")
	
	# Marcar como completado en SaveManager
	SaveManager.save_data["tutorial_completed"] = true
	SaveManager.save_game()
	
	# Celebración final
	AudioManager.play_game_complete()
	AnimationHelper.create_confetti_at_position(self, get_viewport_rect().size / 2, 100)
	
	await get_tree().create_timer(1.5).timeout
	tutorial_completed.emit()
	_close_tutorial()

func _close_tutorial() -> void:
	# Transición suave
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	queue_free()

# ──────────────────────────────────────────────
#  Callbacks de Botones
# ──────────────────────────────────────────────

func _on_continue_pressed() -> void:
	AudioManager.play_button_press()
	DesignSystem.bounce_animation(continue_button)
	await get_tree().create_timer(0.2).timeout
	_show_step(current_step + 1)

func _on_skip_pressed() -> void:
	AudioManager.play_back()
	_complete_tutorial()

# ──────────────────────────────────────────────
#  API Pública
# ──────────────────────────────────────────────

static func should_show_tutorial() -> bool:
	"""Verifica si debe mostrarse el tutorial"""
	return not SaveManager.save_data.get("tutorial_completed", false)

static func show_tutorial(parent: Node) -> void:
	"""Muestra el tutorial en el nodo padre"""
	if not should_show_tutorial():
		return
	
	var tutorial_scene := load("res://scenes/Tutorial.tscn")
	if tutorial_scene:
		var tutorial := tutorial_scene.instantiate()
		parent.add_child(tutorial)
	else:
		push_warning("[Tutorial] Escena no encontrada")
