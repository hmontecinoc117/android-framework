## Script de herramienta que configura los ajustes iniciales del proyecto
## Godot (nombre, resolución, orientación) y guarda ProjectSettings.

extends SceneTree

func _initialize() -> void:
	# Ajustes de proyecto útiles para tu caso (Godot 4)
	ProjectSettings.set_setting("application/config/name", "GustaNuno Gaming")
	ProjectSettings.set_setting("application/config/version", "0.1")
	ProjectSettings.set_setting("application/run/main_scene", "res://assets/scenes/menu.tscn")

	# Ventana y orientación
	ProjectSettings.set_setting("display/window/size/width", 1920)
	ProjectSettings.set_setting("display/window/size/height", 1080)
	ProjectSettings.set_setting("display/window/stretch/mode", "viewport")
	ProjectSettings.set_setting("display/window/stretch/aspect", "keep")
	ProjectSettings.set_setting("display/window/handheld/orientation", "landscape")

	# Emular toque desde mouse para pruebas en PC
	ProjectSettings.set_setting("input_devices/pointing/emulate_touch_from_mouse", true)

	# Guardar cambios
	var ok := ProjectSettings.save()
	if ok != OK:
		push_error("No se pudieron guardar ProjectSettings (codigo %s)" % ok)
	quit()
