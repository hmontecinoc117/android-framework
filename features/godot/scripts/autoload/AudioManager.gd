## Gestor global de audio: música, efectos de sonido y voces.
## Administra buses de audio, reproductores y volúmenes para
## música de fondo, efectos de sonido y narración por voz.

extends Node

# --- Constantes ---
const LOGP := "[AudioManager] "
const SFX_POOL_SIZE: int = 10
const BUS_MUSIC: String = "Music"
const BUS_SFX: String = "SFX"
const BUS_VOICE: String = "Voice"

# --- Variables Miembro ---
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var voice_volume: float = 1.0
var music_enabled: bool = true
var sfx_enabled: bool = true
var voice_enabled: bool = true
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var voice_player: AudioStreamPlayer


# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	_setup_audio_buses()
	_setup_players()


# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func update_volumes() -> void:
	var music_idx: int = AudioServer.get_bus_index(BUS_MUSIC)
	var sfx_idx: int = AudioServer.get_bus_index(BUS_SFX)
	var voice_idx: int = AudioServer.get_bus_index(BUS_VOICE)
	AudioServer.set_bus_volume_db(music_idx, linear_to_db(music_volume) if music_enabled else -80)
	AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(sfx_volume) if sfx_enabled else -80)
	AudioServer.set_bus_volume_db(voice_idx, linear_to_db(voice_volume) if voice_enabled else -80)


func play_music(track_name: String, fade_in: float = 1.0) -> void:
	if not music_enabled:
		return

	var track_path: String = "res://assets/sounds/music/%s.ogg" % track_name

	if not ResourceLoader.exists(track_path):
		push_warning(LOGP + "Música no encontrada: " + track_path)
		return

	var track: Resource = ResourceLoader.load(track_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if not track:
		push_warning(LOGP + "No se pudo cargar la música: " + track_path)
		return

	# Fade out de la música actual
	if music_player.playing:
		var tween: Tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, 0.5)
		tween.tween_callback(func() -> void:
			music_player.stream = track
			music_player.play()
			_fade_in_music(fade_in)
		)
	else:
		music_player.stream = track
		music_player.volume_db = -80
		music_player.play()
		_fade_in_music(fade_in)


func stop_music(fade_out: float = 1.0) -> void:
	if music_player.playing:
		var tween: Tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, fade_out)
		tween.tween_callback(music_player.stop)


func play_sfx(sfx_name: String, pitch_scale: float = 1.0) -> void:
	if not sfx_enabled:
		return

	# Buscar en ambas carpetas (sfx y effects)
	var sfx_path: String = "res://assets/sounds/sfx/%s.ogg" % sfx_name
	if not ResourceLoader.exists(sfx_path):
		sfx_path = "res://assets/sounds/effects/%s.ogg" % sfx_name

	if not ResourceLoader.exists(sfx_path):
		return  # No mostrar warning — muchos sonidos son opcionales

	var available_player: AudioStreamPlayer = get_available_sfx_player()
	if available_player:
		var sfx: Resource = load(sfx_path)
		available_player.stream = sfx
		available_player.volume_db = linear_to_db(sfx_volume)
		available_player.pitch_scale = pitch_scale
		available_player.play()


func get_available_sfx_player() -> AudioStreamPlayer:
	for player: AudioStreamPlayer in sfx_players:
		if not player.playing:
			return player
	# Si todos están ocupados, usar el primero (se cortará el sonido anterior)
	return sfx_players[0]


func play_voice(voice_name: String) -> void:
	if not voice_enabled:
		return

	var voice_path: String = "res://assets/sounds/voice/instructions_es/%s.ogg" % voice_name

	if not ResourceLoader.exists(voice_path):
		push_warning(LOGP + "Audio de voz no encontrado: " + voice_path)
		return

	# Detener voz anterior
	if voice_player.playing:
		voice_player.stop()

	var voice: Resource = load(voice_path)
	voice_player.stream = voice
	voice_player.volume_db = linear_to_db(voice_volume)
	voice_player.play()


func stop_voice() -> void:
	if voice_player.playing:
		voice_player.stop()


func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	update_volumes()


func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	update_volumes()


func set_voice_volume(volume: float) -> void:
	voice_volume = clamp(volume, 0.0, 1.0)
	update_volumes()


func toggle_music(enabled: bool) -> void:
	music_enabled = enabled
	update_volumes()
	if not enabled and music_player.playing:
		music_player.stop()


func toggle_sfx(enabled: bool) -> void:
	sfx_enabled = enabled
	update_volumes()


func toggle_voice(enabled: bool) -> void:
	voice_enabled = enabled
	update_volumes()
	if not enabled and voice_player.playing:
		voice_player.stop()


## Efectos de sonido comunes — mapeados a archivos reales en sfx/
func play_button_press() -> void:
	play_sfx("click_001", randf_range(0.95, 1.05))


func play_success() -> void:
	play_sfx("confirmation_001", randf_range(0.95, 1.05))


func play_error() -> void:
	play_sfx("error_001", randf_range(0.95, 1.05))


func play_star_earned() -> void:
	play_sfx("pluck_001", randf_range(1.0, 1.3))


func play_game_complete() -> void:
	play_sfx("confirmation_004", 1.0)


func play_pickup() -> void:
	play_sfx("select_001", randf_range(0.9, 1.1))


func play_drop() -> void:
	play_sfx("drop_001", randf_range(0.9, 1.1))


func play_navigate() -> void:
	play_sfx("switch_001")


func play_back() -> void:
	play_sfx("back_001")


func play_toggle() -> void:
	play_sfx("toggle_001")


# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _setup_audio_buses() -> void:
	## Crear buses de audio si no existen
	var master_idx: int = AudioServer.get_bus_index("Master")

	# Bus de música
	if AudioServer.get_bus_index(BUS_MUSIC) == -1:
		AudioServer.add_bus()
		var music_idx: int = AudioServer.bus_count - 1
		AudioServer.set_bus_name(music_idx, BUS_MUSIC)
		AudioServer.set_bus_send(music_idx, "Master")

	# Bus de efectos
	if AudioServer.get_bus_index(BUS_SFX) == -1:
		AudioServer.add_bus()
		var sfx_idx: int = AudioServer.bus_count - 1
		AudioServer.set_bus_name(sfx_idx, BUS_SFX)
		AudioServer.set_bus_send(sfx_idx, "Master")

	# Bus de voz
	if AudioServer.get_bus_index(BUS_VOICE) == -1:
		AudioServer.add_bus()
		var voice_idx: int = AudioServer.bus_count - 1
		AudioServer.set_bus_name(voice_idx, BUS_VOICE)
		AudioServer.set_bus_send(voice_idx, "Master")


func _setup_players() -> void:
	## Crear reproductores de audio y pool de SFX
	# Reproductor de música
	music_player = AudioStreamPlayer.new()
	music_player.bus = BUS_MUSIC
	music_player.autoplay = false
	add_child(music_player)

	# Pool de reproductores de SFX
	for i: int in SFX_POOL_SIZE:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = BUS_SFX
		add_child(player)
		sfx_players.append(player)

	# Reproductor de voz
	voice_player = AudioStreamPlayer.new()
	voice_player.bus = BUS_VOICE
	add_child(voice_player)

	# Aplicar volúmenes iniciales
	update_volumes()


func _fade_in_music(duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(music_player, "volume_db", linear_to_db(music_volume), duration)
