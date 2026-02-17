## Plantilla base para scripts GDScript (Godot 4.5 Stable).
## [Descripción del script].

class_name ClassName
extends Node2D

# --- Señales ---

# --- Enums ---

# --- Constantes ---
const LOGP := "[ClassName] "

# --- Variables Exportadas ---

# --- Variables Miembro ---

# --- Variables Onready ---

# ──────────────────────────────────────────────
#  Callbacks del Engine
# ──────────────────────────────────────────────

func _ready() -> void:
	print(LOGP, "_ready")

# ──────────────────────────────────────────────
#  Funciones Públicas
# ──────────────────────────────────────────────

# ──────────────────────────────────────────────
#  Funciones Privadas
# ──────────────────────────────────────────────
