## Plantilla para juegos del proyecto.
## [Descripción del juego y mecánica principal].

extends Node2D

signal game_completed(stars: int, time: float)

const LOGP := "[GameName] "

# --- Configuración ---
@export var grid_size: Vector2i = Vector2i(4, 3)
@export var theme: String = "default"

# --- Nodos ---
var cards_container: Node
var timer_label: Label
var score_label: Label
var back_button: Button

# --- Estado del Juego ---
var score: int = 0
var attempts: int = 0
var start_time: float = 0.0
var is_playing: bool = false

# --- Datos ---
const THEMES: Dictionary = {}

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	_get_nodes()
	_setup_ui()
	_start_game()
	print(LOGP, "_ready: theme=", theme)

func _process(_delta: float) -> void:
	if is_playing:
		_update_timer()

# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func restart() -> void:
	score = 0
	attempts = 0
	is_playing = false
	_cleanup()
	_start_game()

# ──────────────────────────────────────────────
#  Funciones Privadas — Setup
# ──────────────────────────────────────────────

func _get_nodes() -> void:
	cards_container = get_node_or_null("CardsContainer")
	timer_label = get_node_or_null("UI/TopBar/TimerLabel")
	score_label = get_node_or_null("UI/TopBar/ScoreLabel")
	back_button = get_node_or_null("UI/TopBar/BackButton")

func _setup_ui() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _start_game() -> void:
	start_time = Time.get_ticks_msec() / 1000.0
	is_playing = true

# ──────────────────────────────────────────────
#  Funciones Privadas — Lógica
# ──────────────────────────────────────────────

func _update_timer() -> void:
	var elapsed := Time.get_ticks_msec() / 1000.0 - start_time
	if timer_label:
		timer_label.text = "%02d:%02d" % [int(elapsed) / 60, int(elapsed) % 60]

func _calculate_stars() -> int:
	if attempts <= 5:
		return 3
	elif attempts <= 10:
		return 2
	else:
		return 1

func _complete_game() -> void:
	is_playing = false
	var elapsed := Time.get_ticks_msec() / 1000.0 - start_time
	var stars := _calculate_stars()
	game_completed.emit(stars, elapsed)
	print(LOGP, "Completado: estrellas=", stars, " tiempo=", elapsed)

func _cleanup() -> void:
	pass

# ──────────────────────────────────────────────
#  Callbacks de UI
# ──────────────────────────────────────────────

func _on_back_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.go_back()
