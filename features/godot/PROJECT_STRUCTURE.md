# Estructura del Proyecto - Kids Educational Games

## 📁 Estructura Actual (Limpia)

```
features/godot/
├── android/                    # Android build template
│   ├── build/                  # Archivos de compilación
│   └── plugins/                # Plugins de Godot para Android
│
├── assets/                     # Assets del juego
│   ├── sounds/                 # Audio (música, efectos, voces)
│   │   ├── animals/
│   │   ├── instruments/
│   │   ├── vehicles/
│   │   ├── nature/
│   │   ├── music/
│   │   └── sfx/
│   ├── icons/                  # Iconos de UI y juegos
│   ├── sprites/                # Sprites de personajes/objetos
│   ├── backgrounds/            # Fondos de escenas
│   └── fonts/                  # Fuentes personalizadas
│
├── scenes/                     # Escenas de Godot (.tscn)
│   ├── main/
│   │   ├── MainMenu.tscn       # Menú principal
│   │   └── GameSelector.tscn   # Selector de juegos
│   └── games/
│       ├── TraceGame.tscn      # Trazado de letras/números
│       ├── MemoryGame.tscn     # Juego de memoria
│       ├── PuzzleGame.tscn     # Rompecabezas
│       ├── CountingGame.tscn   # Contar objetos
│       ├── ShapeTraceGame.tscn # Trazado de formas
│       ├── MatchingGame.tscn   # Unir parejas
│       ├── PatternGame.tscn    # Secuencias/patrones
│       ├── MazeGame.tscn       # Laberinto
│       ├── ColorByNumberGame.tscn  # Colorear por números
│       └── SoundRecognitionGame.tscn # Reconocimiento sonidos
│
├── scripts/                    # Scripts de GDScript
│   ├── autoload/               # Singletons globales
│   │   ├── GameManager.gd      # Gestión de juegos/progreso
│   │   ├── AudioManager.gd     # Sistema de audio
│   │   ├── SaveManager.gd      # Guardado/carga
│   │   ├── ThemeManager.gd     # Temas visuales
│   │   └── VoiceInstructions.gd # Instrucciones por voz
│   ├── components/             # Componentes reutilizables
│   │   ├── AnimatedButton.gd   # Botón con animaciones
│   │   ├── DraggableObject.gd  # Objeto arrastrable
│   │   └── StarRating.gd       # Sistema de estrellas
│   ├── utils/                  # Utilidades
│   │   ├── TouchInputHandler.gd # Gestos táctiles
│   │   ├── AnimationHelper.gd   # Ayudantes de animación
│   │   └── ScreenSizeAdapter.gd # Adaptación de pantalla
│   ├── main/                   # Scripts de pantallas principales
│   │   ├── MainMenu.gd
│   │   └── GameSelector.gd
│   └── games/                  # Scripts de los 10 juegos
│       ├── TraceGame.gd
│       ├── MemoryGame.gd
│       ├── PuzzleGame.gd
│       ├── CountingGame.gd
│       ├── ShapeTraceGame.gd
│       ├── MatchingGame.gd
│       ├── PatternGame.gd
│       ├── MazeGame.gd
│       ├── ColorByNumberGame.gd
│       └── SoundRecognitionGame.gd
│
├── translations/               # Archivos de traducción
│   ├── texts.es.translation
│   └── texts.en.translation
│
├── tools/                      # Herramientas de desarrollo
│   └── configure_project.gd
│
├── project.godot              # Configuración del proyecto Godot
├── export_presets.cfg         # Configuración de exportación Android
├── run_godot.sh              # Script para ejecutar Godot
└── README_GAMES.md           # Documentación completa

## 📊 Estado Actual

### ✅ Completado:
- **27 scripts GDScript** (todos funcionales, Godot 4.5)
- **12 escenas .tscn** (2 principales + 10 juegos)
- **6 autoloads** configurados en project.godot
- **Configuración Android** lista para compilar
- **Estructura de carpetas** para assets

### ⚠️ Pendiente:
- Assets visuales (iconos, sprites, fondos)
- Assets de audio (música, efectos, voces)
- Traducciones completas (ES/EN)

### 🎮 Juegos Implementados:
1. TraceGame - Trazado de letras/números
2. MemoryGame - Juego de memoria con cartas
3. PuzzleGame - Rompecabezas con piezas arrastrables
4. CountingGame - Contar objetos y sumas simples
5. ShapeTraceGame - Trazado de formas geométricas
6. MatchingGame - Unir parejas con líneas
7. PatternGame - Completar secuencias
8. MazeGame - Laberinto con generación procedural
9. ColorByNumberGame - Colorear por números
10. SoundRecognitionGame - Reconocer sonidos

## 🚀 Ejecutar el Proyecto

```bash
# Usando el script incluido
./run_godot.sh

# O directamente con Godot
godot4 --path /home/xtotox/Documentos/android-framework/features/godot

# Para editar
godot4 --path /home/xtotox/Documentos/android-framework/features/godot --editor
```

## 📦 Compilar para Android

```bash
# Desde línea de comandos
godot4 --path /home/xtotox/Documentos/android-framework/features/godot \
       --export-release Android

# O desde el editor: Project → Export → Android
```
