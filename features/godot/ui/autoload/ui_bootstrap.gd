extends Node
class_name UiBootstrap

func _ready():
	var ui := UiGlobals
	var theme := ThemeBuilder.build(ui)
	get_tree().root.theme = theme
