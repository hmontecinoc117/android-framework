# Guía de Estructura de Clases — Godot 4.5 Stable

> Referencia interna del proyecto. Todo script `.gd` nuevo debe seguir esta estructura.
> Copilot: al generar código GDScript, **sigue siempre este archivo**.

---

## 1. Orden Oficial de Elementos en un Script

| #  | Sección                         | Ejemplo                                        |
|----|----------------------------------|-------------------------------------------------|
| 1  | Comentario de documentación      | `## Descripción del script`                     |
| 2  | `@tool` (si aplica)              | `@tool`                                         |
| 3  | `class_name` (opcional)          | `class_name Player`                             |
| 4  | `extends`                        | `extends CharacterBody2D`                       |
| 5  | Señales (`signal`)               | `signal health_changed(new_health: int)`        |
| 6  | Enums (`enum`)                   | `enum State { IDLE, WALK, RUN }`                |
| 7  | Constantes (`const`)             | `const SPEED: float = 300.0`                    |
| 8  | Variables `@export`              | `@export var max_health: int = 100`             |
| 9  | Variables miembro                | `var current_health: int`                       |
| 10 | Variables `@onready`             | `@onready var sprite: Sprite2D = $Sprite2D`     |
| 11 | Callbacks virtuales del engine   | `_ready()`, `_process()`, `_physics_process()`  |
| 12 | Funciones públicas               | `func take_damage(amount: int) -> void:`        |
| 13 | Funciones privadas (prefijo `_`) | `func _apply_gravity(delta: float) -> void:`    |

---

## 2. Convenciones de Nomenclatura

| Elemento             | Estilo                         | Ejemplo                          |
|----------------------|--------------------------------|----------------------------------|
| Clases / class_name  | `PascalCase`                   | `PlayerCharacter`, `MemoryGame`  |
| Variables            | `snake_case`                   | `current_health`, `card_size_px` |
| Funciones públicas   | `snake_case`                   | `take_damage()`, `heal()`        |
| Funciones privadas   | `_snake_case` (prefijo `_`)    | `_handle_movement()`, `_die()`   |
| Constantes           | `UPPER_SNAKE_CASE`             | `MAX_SPEED`, `GRAVITY`           |
| Señales              | `snake_case`                   | `game_completed`, `hit_detected` |
| Enums                | `PascalCase` → `UPPER_SNAKE`   | `enum State { IDLE, WALK }`      |
| Nodos exportados     | `snake_case`                   | `@export var spawn_point: Node2D`|
| Prefijo de log       | `LOGP` (constante del proyecto)| `const LOGP := "[ClassName] "`   |

---

## 3. Tipado Estático (Obligatorio en este proyecto)

```gdscript
# Variables — siempre declarar tipo
var velocity: Vector2 = Vector2.ZERO
var player_name: String = "Player"
var is_active: bool = true

# Funciones — siempre declarar tipos de parámetros y retorno
func calculate_damage(base: float, multiplier: float) -> float:
    return base * multiplier

func get_health() -> int:
    return current_health

# Señales — declarar tipos de los parámetros
signal health_changed(new_health: int)
signal game_completed(stars: int, time: float)
```

---

## 4. Anotaciones de Exportación

```gdscript
# Tipos básicos
@export var speed: float = 200.0
@export var max_health: int = 100
@export var player_name: String = "Jugador"
@export var is_enabled: bool = true

# Rangos
@export_range(0, 100, 1) var percentage: int = 50
@export_range(0.0, 1.0, 0.01) var friction: float = 0.1

# Recursos y archivos
@export var texture: Texture2D
@export var scene: PackedScene
@export_file("*.json") var config_path: String
@export_dir var assets_path: String

# Texto multilínea
@export_multiline var description: String

# Colores
@export var main_color: Color = Color.WHITE
@export_color_no_alpha var team_color: Color

# Enums exportados
@export var difficulty: Difficulty = Difficulty.EASY

# Grupos y categorías
@export_group("Movimiento")
@export var walk_speed: float = 100.0
@export var run_speed: float = 250.0

@export_group("Combate")
@export var attack_damage: int = 10
@export var defense: int = 5

@export_subgroup("Armas")
@export var weapon_range: float = 50.0
```

---

## 5. Plantilla Completa de Clase

```gdscript
## Descripción breve del script.
## Explicación adicional si es necesario.

class_name MiClase
extends Node2D

# --- Señales ---
signal action_completed(result: int)
signal state_changed(new_state: int)

# --- Enums ---
enum State {
    IDLE,
    ACTIVE,
    PAUSED,
    FINISHED
}

# --- Constantes ---
const LOGP := "[MiClase] "
const MAX_ITEMS: int = 10
const DEFAULT_DURATION: float = 1.0

# --- Variables Exportadas ---
@export var speed: float = 200.0
@export var max_health: int = 100

@export_group("Configuración Visual")
@export var main_color: Color = Color.WHITE
@export var animation_duration: float = 0.3

# --- Variables Miembro ---
var current_state: State = State.IDLE
var current_health: int
var _internal_counter: int = 0

# --- Variables Onready ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape2D = $CollisionShape2D

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
    current_health = max_health
    _setup_initial_state()
    print(LOGP, "_ready completado")

func _process(delta: float) -> void:
    if current_state == State.ACTIVE:
        _update_logic(delta)

func _physics_process(delta: float) -> void:
    _handle_physics(delta)

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        _handle_touch(event)

# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func start() -> void:
    current_state = State.ACTIVE
    state_changed.emit(State.ACTIVE)

func stop() -> void:
    current_state = State.PAUSED
    state_changed.emit(State.PAUSED)

func take_damage(amount: int) -> void:
    current_health = max(0, current_health - amount)
    if current_health <= 0:
        _on_defeated()

func reset() -> void:
    current_health = max_health
    current_state = State.IDLE
    _internal_counter = 0

# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _setup_initial_state() -> void:
    pass

func _update_logic(_delta: float) -> void:
    pass

func _handle_physics(_delta: float) -> void:
    pass

func _handle_touch(event: InputEventScreenTouch) -> void:
    if event.pressed:
        print(LOGP, "Touch en: ", event.position)

func _on_defeated() -> void:
    current_state = State.FINISHED
    action_completed.emit(0)
    queue_free()
```

---

## 6. Plantilla para Juego (patrón del proyecto)

```gdscript
## Descripción del juego.
## Explica la mecánica principal.

extends Node2D

signal game_completed(stars: int, time: float)

const LOGP := "[NombreJuego] "

# --- Configuración ---
@export var grid_size: Vector2i = Vector2i(4, 3)
@export var theme: String = "default"
@export var time_limit: float = 60.0

# --- Nodos (obtenidos en _ready) ---
var cards_container: Node
var ui_layer: CanvasLayer
var timer_label: Label
var score_label: Label
var back_button: Button

# --- Estado del juego ---
var score: int = 0
var attempts: int = 0
var start_time: float = 0.0
var is_playing: bool = false

# --- Datos ---
const THEMES: Dictionary = {
    "default": ["item1", "item2", "item3", "item4"],
}

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
    _get_nodes()
    _setup_ui()
    _start_game()
    print(LOGP, "_ready: theme=", theme)

func _process(delta: float) -> void:
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
    ui_layer = get_node_or_null("UI")
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
    print(LOGP, "Juego completado: estrellas=", stars, " tiempo=", elapsed)

func _cleanup() -> void:
    pass

# ──────────────────────────────────────────────
#  Callbacks de UI
# ──────────────────────────────────────────────

func _on_back_pressed() -> void:
    var gm = get_node_or_null("/root/GameManager")
    if gm:
        gm.go_back()
```

---

## 7. Plantilla para Componente UI

```gdscript
## Componente reutilizable de UI.
## Descripción de su función.

@tool
extends Control  # o Button, Panel, etc.

# --- Señales ---
signal value_changed(new_value: Variant)

# --- Variables Exportadas ---
@export var label_text: String = "":
    set(value):
        label_text = value
        _update_display()

@export var animation_duration: float = 0.2
@export var enable_sound: bool = true

# --- Variables Miembro ---
var original_scale: Vector2 = Vector2.ONE
var _tween: Tween

# --- Variables Onready ---
@onready var label: Label = $Label
@onready var icon: TextureRect = $Icon

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
    original_scale = scale
    _setup_connections()
    _update_display()

# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

func set_value(new_value: Variant) -> void:
    value_changed.emit(new_value)
    _update_display()

# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _setup_connections() -> void:
    pass

func _update_display() -> void:
    if label:
        label.text = label_text

func _animate_scale(target: Vector2) -> void:
    if _tween and _tween.is_running():
        _tween.kill()
    _tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
    _tween.tween_property(self, "scale", target, animation_duration)
```

---

## 8. Plantilla para Autoload / Singleton

```gdscript
## Singleton global para [función].
## Se registra como Autoload en Project Settings.

extends Node

# --- Señales ---
signal settings_changed

# --- Constantes ---
const LOGP := "[ManagerName] "
const SAVE_PATH := "user://settings.cfg"

# --- Variables ---
var _config: ConfigFile
var _is_initialized: bool = false

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
    _config = ConfigFile.new()
    _load_settings()
    _is_initialized = true
    print(LOGP, "Inicializado")

# ──────────────────────────────────────────────
#  API Pública
# ──────────────────────────────────────────────

func get_setting(key: String, default: Variant = null) -> Variant:
    return _config.get_value("settings", key, default)

func set_setting(key: String, value: Variant) -> void:
    _config.set_value("settings", key, value)
    _save_settings()
    settings_changed.emit()

# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────

func _load_settings() -> void:
    var err := _config.load(SAVE_PATH)
    if err != OK:
        print(LOGP, "No se encontró archivo de configuración, usando defaults")

func _save_settings() -> void:
    _config.save(SAVE_PATH)
```

---

## 9. Reglas de Formato

- **Indentación:** 1 tab (configuración por defecto de Godot).
- **Líneas en blanco:** 1 línea entre funciones, 2 líneas entre secciones.
- **Largo máximo de línea:** ~100 caracteres (preferido).
- **Comentarios de sección:** Usar `# ---` o bloques `# ────` para separar secciones.
- **Parámetros no usados:** Prefijar con `_` → `func _process(_delta: float)`.
- **Strings:** Usar `"comillas dobles"` siempre.
- **Log del proyecto:** Usar `const LOGP := "[NombreClase] "` + `print(LOGP, ...)`.
- **Obtener nodos:** Preferir `get_node_or_null()` sobre `$` cuando el nodo puede no existir.

---

## 10. Checklist Rápido para Nuevos Scripts

- [ ] ¿Tiene comentario de documentación (`##`) al inicio?
- [ ] ¿Sigue el orden oficial de secciones?
- [ ] ¿Todas las variables tienen tipo declarado?
- [ ] ¿Todas las funciones tienen tipos de parámetros y retorno?
- [ ] ¿Las funciones privadas empiezan con `_`?
- [ ] ¿Tiene `const LOGP` para logging?
- [ ] ¿Las señales tienen tipos en sus parámetros?
- [ ] ¿Los nodos opcionales se obtienen con `get_node_or_null()`?
- [ ] ¿Usa `@export_group` para agrupar propiedades relacionadas?
