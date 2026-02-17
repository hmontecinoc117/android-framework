# Guía de Migración: Eliminando Input Manual

Los botones ahora usan el sistema nativo de Godot con el helper ButtonHelper.

## Uso Rápido

```gdscript
func _ready():
    # Configurar todos los botones automáticamente
    ButtonHelper.setup_all_buttons_in(self)
```

Ver ejemplos completos en el repositorio.
