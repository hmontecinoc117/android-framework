## Menú de ajustes de accesibilidad.
## Permite configurar escala de fuente y modo de contraste.

extends Control

const LOGP := "[AjustesMenu] "

# --- Variables Onready ---
@onready var _font_slider: HSlider = $Margin/VBox/Accesibilidad/FontScale
@onready var _contrast_selector: OptionButton = $Margin/VBox/Accesibilidad/ContrastMode

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	_font_slider.value = UiGlobals.font_scale
	_font_slider.connect("value_changed", _on_font_scale_changed)

	_contrast_selector.clear()
	_contrast_selector.add_item("Normal", 0)
	_contrast_selector.add_item("Alto", 1)
	_contrast_selector.select(1 if UiGlobals.contrast_mode == "high" else 0)
	_contrast_selector.connect("item_selected", _on_contrast_selected)

	print(LOGP, "_ready")

# ──────────────────────────────────────────────
#  Funciones Privadas — Callbacks de UI
# ──────────────────────────────────────────────

func _on_font_scale_changed(value: float) -> void:
	UiGlobals.set_font_scale(value)
	UiBootstrap.rebuild_theme()

func _on_contrast_selected(index: int) -> void:
	var mode: String = "high" if index == 1 else "normal"
	UiGlobals.set_contrast_mode(mode)
	UiBootstrap.rebuild_theme()
