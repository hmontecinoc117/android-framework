## Arranque visual del framework: aplica el theme global,
## gestiona transiciones fade entre escenas y sirve de puente
## para cambios de escena con efectos visuales.

# NO usar class_name aquí para evitar conflicto con autoload
extends Node

# --- Constantes ---
const LOGP := "[UiBootstrap] "

const GAME_SELECTOR_PATH := "res://scenes/main/GameSelector.tscn"
const MAIN_MENU_PATH := "res://scenes/main/MainMenu.tscn"

# --- Variables Miembro ---
var _fade_layer: CanvasLayer
var _fade_rect: ColorRect
var _transitioning: bool = false

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	var ui := UiGlobals
	var theme := ThemeBuilder.build(ui)
	get_tree().root.theme = theme

	# Desactivar el quit automático del botón Back de Android
	get_tree().auto_accept_quit = false

	# Capa de transición fade (layer 100 para estar encima de todo)
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100
	get_tree().root.add_child(_fade_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.anchor_right = 1.0
	_fade_rect.anchor_bottom = 1.0
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_layer.add_child(_fade_rect)

	# Permite seleccionar escena inicial desde Android pasando "--startup-scene <ruta>"
	var args := OS.get_cmdline_args()
	var idx := args.find("--startup-scene")
	if idx != -1 and idx + 1 < args.size():
		var scene_path := args[idx + 1]
		call_deferred("_switch_to_startup_scene", scene_path)
	print(LOGP, "_ready completado")


func _notification(what: int) -> void:
	# NOTIFICATION_WM_GO_BACK no existe en Godot 4.x, usar MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT
	# Por ahora comentado hasta implementar correctamente
	# if what == NOTIFICATION_WM_GO_BACK:
	# 	_handle_android_back()
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()


# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func rebuild_theme() -> void:
	var theme := ThemeBuilder.build(UiGlobals)
	get_tree().root.theme = theme


func fade_to_scene(path: String, duration: float = 0.35) -> void:
	## Transición con fade a negro hacia otra escena.
	if _transitioning:
		return
	_transitioning = true
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP  # Bloquear input
	var t := create_tween()
	t.tween_property(_fade_rect, "color", Color(0, 0, 0, 1), duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.tween_callback(func() -> void:
		get_tree().change_scene_to_file(path)
	)
	t.tween_property(_fade_rect, "color", Color(0, 0, 0, 0), duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_callback(func() -> void:
		_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_transitioning = false
	)


# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _switch_to_startup_scene(scene_path: String) -> void:
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_warning("No se pudo cargar escena inicial: %s" % scene_path)


func _handle_android_back() -> void:
	## Maneja el botón Back de Android según la escena actual.
	if _transitioning:
		return

	var current_scene: Node = get_tree().current_scene
	if not current_scene:
		return

	var scene_file: String = current_scene.scene_file_path
	print(LOGP, "Android Back en escena: ", scene_file)

	if scene_file == MAIN_MENU_PATH or scene_file == "":
		# En MainMenu: salir de la app
		get_tree().quit()
	elif scene_file == GAME_SELECTOR_PATH:
		# En GameSelector: volver a MainMenu
		AudioManager.play_back()
		fade_to_scene(MAIN_MENU_PATH)
	else:
		# En cualquier juego: volver al GameSelector
		AudioManager.play_back()
		fade_to_scene(GAME_SELECTOR_PATH)
