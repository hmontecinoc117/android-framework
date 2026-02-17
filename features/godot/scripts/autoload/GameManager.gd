## Gestor global del progreso y estado de los juegos educativos.
## Maneja perfiles de jugador, progreso de juegos, estrellas
## y desbloqueo de niveles.

extends Node

# --- Señales ---
signal game_completed(game_name: String, stars: int)
signal level_unlocked(game_name: String, level: int)
signal profile_changed(profile: PlayerProfile)

# --- Constantes ---
const LOGP := "[GameManager] "

const COLOR_PRIMARY_BLUE: Color = Color("#4A90E2")
const COLOR_PRIMARY_GREEN: Color = Color("#7ED321")
const COLOR_PRIMARY_YELLOW: Color = Color("#F5A623")
const COLOR_PRIMARY_RED: Color = Color("#E85D75")

const COLOR_BG_SKY: Color = Color("#E8F4F8")
const COLOR_BG_GRASS: Color = Color("#F0F8E8")
const COLOR_BG_SUNSET: Color = Color("#FFF4E6")

const COLOR_SUCCESS: Color = Color("#52C41A")
const COLOR_ERROR: Color = Color("#FF6B6B")
const COLOR_NEUTRAL: Color = Color("#8C8C8C")

# --- Clase PlayerProfile ---
class PlayerProfile:
	var name: String = ""
	var age: int = 5
	var avatar_id: int = 0
	var total_stars: int = 0
	var games_completed: int = 0
	var play_time_seconds: int = 0
	var created_date: String = ""

	func _init(_name: String = "", _age: int = 5, _avatar: int = 0) -> void:
		name = _name
		age = _age
		avatar_id = _avatar
		created_date = Time.get_datetime_string_from_system()

# --- Variables Miembro ---
var current_player_profile: PlayerProfile
var game_progress: Dictionary = {}
var available_games: Array[String] = [
	"TraceGame",
	"ShapeTraceGame",
	"MemoryGame",
	"PuzzleGame",
	"MatchingGame",
	"CountingGame",
	"ColorByNumberGame",
	"PatternGame",
	"MazeGame",
	"SoundRecognitionGame"
]


# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	# Crear perfil por defecto si no existe
	if not current_player_profile:
		current_player_profile = PlayerProfile.new("Jugador", 5, 0)

	# Inicializar progreso de juegos
	_initialize_game_progress()


# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func complete_game(game_name: String, stars: int, time_seconds: float, level: int = 1) -> void:
	if not game_progress.has(game_name):
		_initialize_game_progress()

	var game_data: Dictionary = game_progress[game_name]
	game_data.times_played += 1

	# Actualizar mejor puntuación
	if stars > game_data.best_stars:
		game_data.best_stars = stars

	# Actualizar mejor tiempo
	if time_seconds < game_data.best_time:
		game_data.best_time = time_seconds

	# Marcar como completado si obtuvo al menos 1 estrella
	if not game_data.completed and stars >= 1:
		game_data.completed = true
		current_player_profile.games_completed += 1
		_unlock_next_game(game_name)

	# Desbloquear siguiente nivel
	if level >= game_data.max_level_unlocked and stars >= 2:
		game_data.max_level_unlocked = min(level + 1, 5)
		level_unlocked.emit(game_name, level + 1)

	current_player_profile.total_stars += stars
	game_completed.emit(game_name, stars)
	var save_manager: Node = get_node_or_null("/root/SaveManager")
	if save_manager:
		save_manager.save_game_progress()


func is_game_unlocked(game_name: String) -> bool:
	if game_progress.has(game_name):
		return game_progress[game_name].unlocked
	return false


func get_game_stars(game_name: String) -> int:
	if game_progress.has(game_name):
		return game_progress[game_name].best_stars
	return 0


func get_total_stars() -> int:
	return current_player_profile.total_stars


func get_completed_games_count() -> int:
	return current_player_profile.games_completed


func create_new_profile(player_name: String, age: int, avatar: int) -> PlayerProfile:
	var profile: PlayerProfile = PlayerProfile.new(player_name, age, avatar)
	current_player_profile = profile
	_initialize_game_progress()
	profile_changed.emit(profile)
	var save_manager: Node = get_node_or_null("/root/SaveManager")
	if save_manager:
		save_manager.save_game_progress()
	return profile


func load_profile(profile: PlayerProfile) -> void:
	current_player_profile = profile
	profile_changed.emit(profile)


func get_play_time_formatted() -> String:
	var seconds: int = current_player_profile.play_time_seconds
	var hours: int = seconds / 3600
	var minutes: int = (seconds % 3600) / 60
	var secs: int = seconds % 60

	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, secs]
	else:
		return "%02d:%02d" % [minutes, secs]


func add_play_time(seconds: int) -> void:
	current_player_profile.play_time_seconds += seconds


# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _initialize_game_progress() -> void:
	for game_name: String in available_games:
		if not game_progress.has(game_name):
			game_progress[game_name] = {
				"completed": false,
				"unlocked": true,
				"best_stars": 0,
				"best_time": 999999.0,
				"times_played": 0,
				"current_level": 1,
				"max_level_unlocked": 1
			}


func _unlock_next_game(completed_game: String) -> void:
	var current_index: int = available_games.find(completed_game)
	if current_index >= 0 and current_index < available_games.size() - 1:
		var next_game: String = available_games[current_index + 1]
		if game_progress.has(next_game):
			game_progress[next_game].unlocked = true
			print(LOGP, "Juego desbloqueado: ", next_game)
