# GameManager.gd
# Gestor global del progreso y estado de los juegos educativos
extends Node

signal game_completed(game_name: String, stars: int)
signal level_unlocked(game_name: String, level: int)
signal profile_changed(profile: PlayerProfile)

# Colores primarios brillantes pero no saturados
const COLOR_PRIMARY_BLUE = Color("#4A90E2")
const COLOR_PRIMARY_GREEN = Color("#7ED321")
const COLOR_PRIMARY_YELLOW = Color("#F5A623")
const COLOR_PRIMARY_RED = Color("#E85D75")

# Colores secundarios pasteles
const COLOR_BG_SKY = Color("#E8F4F8")
const COLOR_BG_GRASS = Color("#F0F8E8")
const COLOR_BG_SUNSET = Color("#FFF4E6")

# Colores de feedback
const COLOR_SUCCESS = Color("#52C41A")
const COLOR_ERROR = Color("#FF6B6B")
const COLOR_NEUTRAL = Color("#8C8C8C")

# Clase para almacenar perfil del jugador
class PlayerProfile:
	var name: String = ""
	var age: int = 5
	var avatar_id: int = 0
	var total_stars: int = 0
	var games_completed: int = 0
	var play_time_seconds: int = 0
	var created_date: String = ""
	
	func _init(_name: String = "", _age: int = 5, _avatar: int = 0):
		name = _name
		age = _age
		avatar_id = _avatar
		created_date = Time.get_datetime_string_from_system()

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

func _ready():
	# Crear perfil por defecto si no existe
	if not current_player_profile:
		current_player_profile = PlayerProfile.new("Jugador", 5, 0)
	
	# Inicializar progreso de juegos
	initialize_game_progress()

func initialize_game_progress():
	for game_name in available_games:
		if not game_progress.has(game_name):
			game_progress[game_name] = {
				"completed": false,
				"unlocked": true,  # Todos los juegos desbloqueados
				"best_stars": 0,
				"best_time": 999999.0,
				"times_played": 0,
				"current_level": 1,
				"max_level_unlocked": 1
			}

func complete_game(game_name: String, stars: int, time_seconds: float, level: int = 1):
	if not game_progress.has(game_name):
		initialize_game_progress()
	
	var game_data = game_progress[game_name]
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
		unlock_next_game(game_name)
	
	# Desbloquear siguiente nivel
	if level >= game_data.max_level_unlocked and stars >= 2:
		game_data.max_level_unlocked = min(level + 1, 5)
		level_unlocked.emit(game_name, level + 1)
	
	current_player_profile.total_stars += stars
	game_completed.emit(game_name, stars)
	var save_manager = get_node_or_null("/root/SaveManager")
	if save_manager:
		save_manager.save_game_progress()

func unlock_next_game(completed_game: String):
	var current_index = available_games.find(completed_game)
	if current_index >= 0 and current_index < available_games.size() - 1:
		var next_game = available_games[current_index + 1]
		if game_progress.has(next_game):
			game_progress[next_game].unlocked = true
			print("Juego desbloqueado: ", next_game)

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
	var profile = PlayerProfile.new(player_name, age, avatar)
	current_player_profile = profile
	initialize_game_progress()
	profile_changed.emit(profile)
	var save_manager = get_node_or_null("/root/SaveManager")
	if save_manager:
		save_manager.save_game_progress()
	return profile

func load_profile(profile: PlayerProfile):
	current_player_profile = profile
	profile_changed.emit(profile)

func get_play_time_formatted() -> String:
	var seconds = current_player_profile.play_time_seconds
	var hours = seconds / 3600
	var minutes = (seconds % 3600) / 60
	var secs = seconds % 60
	
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, secs]
	else:
		return "%02d:%02d" % [minutes, secs]

func add_play_time(seconds: int):
	current_player_profile.play_time_seconds += seconds
