## Gestor de guardado y carga de progreso del jugador.
## Maneja la persistencia de perfiles, progreso de juegos
## y configuraciones de audio en formato JSON.

extends Node

# --- Constantes ---
const LOGP := "[SaveManager] "
const SAVE_FILE_PATH: String = "user://save_data.json"
const SETTINGS_FILE_PATH: String = "user://settings.json"

# --- Variables Miembro ---
var save_data: Dictionary = {
	"profiles": [],
	"current_profile_index": 0,
	"version": "1.0.0"
}

var settings_data: Dictionary = {
	"music_volume": 0.7,
	"sfx_volume": 0.8,
	"voice_volume": 1.0,
	"music_enabled": true,
	"sfx_enabled": true,
	"voice_enabled": true,
	"language": "es"
}


# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	# Esperar a que GameManager esté listo
	await get_tree().process_frame
	load_settings()
	load_game_data()


# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func save_game_progress() -> void:
	## Guarda el progreso actual del jugador en disco.
	var game_manager: Node = get_node_or_null("/root/GameManager")
	if not game_manager or not is_instance_valid(game_manager):
		push_warning(LOGP + "GameManager no está disponible")
		return

	if not game_manager.current_player_profile:
		push_warning(LOGP + "No hay perfil de jugador activo")
		return

	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)

	if not file:
		push_error(LOGP + "No se pudo abrir el archivo de guardado para escritura")
		return

	# Serializar perfil actual
	save_data["profiles"] = []

	if game_manager.current_player_profile:
		var profile_data: Dictionary = {
			"name": game_manager.current_player_profile.name,
			"age": game_manager.current_player_profile.age,
			"avatar_id": game_manager.current_player_profile.avatar_id,
			"total_stars": game_manager.current_player_profile.total_stars,
			"games_completed": game_manager.current_player_profile.games_completed,
			"play_time_seconds": game_manager.current_player_profile.play_time_seconds,
			"created_date": game_manager.current_player_profile.created_date,
			"game_progress": game_manager.game_progress
		}
		save_data["profiles"].append(profile_data)

	save_data["version"] = "1.0.0"

	var json_string: String = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()

	print(LOGP, "Progreso guardado exitosamente")


func load_game_data() -> void:
	## Carga los datos del juego desde disco.
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print(LOGP, "No existe archivo de guardado previo")
		return

	var game_manager: Node = get_node_or_null("/root/GameManager")
	if not game_manager:
		push_warning(LOGP + "GameManager no disponible para cargar datos")
		return

	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)

	if not file:
		push_error(LOGP + "No se pudo abrir el archivo de guardado para lectura")
		return

	var json_string: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: int = json.parse(json_string)

	if parse_result == OK:
		save_data = json.data

		# Cargar perfil
		if save_data.has("profiles") and save_data["profiles"].size() > 0:
			var profile_index: int = save_data.get("current_profile_index", 0)
			var profile_data: Dictionary = save_data["profiles"][profile_index]

			# Recrear perfil
			var profile: RefCounted = game_manager.PlayerProfile.new(
				profile_data.get("name", "Jugador"),
				profile_data.get("age", 5),
				profile_data.get("avatar_id", 0)
			)
			profile.total_stars = profile_data.get("total_stars", 0)
			profile.games_completed = profile_data.get("games_completed", 0)
			profile.play_time_seconds = profile_data.get("play_time_seconds", 0)
			profile.created_date = profile_data.get("created_date", "")

			game_manager.current_player_profile = profile
			game_manager.game_progress = profile_data.get("game_progress", {})

			print(LOGP, "Datos del juego cargados exitosamente")
		else:
			print(LOGP, "No hay perfiles guardados")
	else:
		push_error(LOGP + "Error al parsear archivo de guardado: " + json.get_error_message())


func save_settings() -> void:
	## Guarda la configuración de audio en disco.
	var file: FileAccess = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)

	if not file:
		push_error(LOGP + "No se pudo guardar la configuración")
		return

	# Actualizar datos desde AudioManager
	var audio_manager: Node = get_node_or_null("/root/AudioManager")
	if audio_manager:
		settings_data["music_volume"] = audio_manager.music_volume
		settings_data["sfx_volume"] = audio_manager.sfx_volume
		settings_data["voice_volume"] = audio_manager.voice_volume
		settings_data["music_enabled"] = audio_manager.music_enabled
		settings_data["sfx_enabled"] = audio_manager.sfx_enabled
		settings_data["voice_enabled"] = audio_manager.voice_enabled

	var json_string: String = JSON.stringify(settings_data, "\t")
	file.store_string(json_string)
	file.close()

	print(LOGP, "Configuración guardada")


func load_settings() -> void:
	## Carga la configuración desde disco y la aplica a AudioManager.
	if not FileAccess.file_exists(SETTINGS_FILE_PATH):
		print(LOGP, "No existe archivo de configuración, usando valores por defecto")
		save_settings()
		return

	var file: FileAccess = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)

	if not file:
		push_error(LOGP + "No se pudo cargar la configuración")
		return

	var json_string: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: int = json.parse(json_string)

	if parse_result == OK:
		settings_data = json.data

		# Aplicar configuración a AudioManager
		var audio_manager: Node = get_node_or_null("/root/AudioManager")
		if audio_manager:
			audio_manager.music_volume = settings_data.get("music_volume", 0.7)
			audio_manager.sfx_volume = settings_data.get("sfx_volume", 0.8)
			audio_manager.voice_volume = settings_data.get("voice_volume", 1.0)
			audio_manager.music_enabled = settings_data.get("music_enabled", true)
			audio_manager.sfx_enabled = settings_data.get("sfx_enabled", true)
			audio_manager.voice_enabled = settings_data.get("voice_enabled", true)
			audio_manager.update_volumes()

		print(LOGP, "Configuración cargada")
	else:
		push_error(LOGP + "Error al parsear configuración")


func delete_save_data() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)
		print(LOGP, "Datos de guardado eliminados")


func export_save_data() -> String:
	return JSON.stringify(save_data, "\t")


func get_save_file_path() -> String:
	return SAVE_FILE_PATH
