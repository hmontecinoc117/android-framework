# Assets Importados - Kids Educational Games

## 📦 Paquetes de Kenney Instalados

### 1. **Game Icons** (105 iconos)
- **Ubicación**: `assets/icons/`
- **Contenido**: Iconos de interfaz de usuario (flechas, audio, home, star, etc.)
- **Uso**: Botones de navegación, controles, indicadores de UI

### 2. **Animal Pack Redux** (50+ animales)
- **Ubicación**: `assets/images/animals/`
- **Contenido**: Animales en estilo redondo con contorno (bear, cow, dog, elephant, etc.)
- **Uso**: MemoryGame, MatchingGame, CountingGame

### 3. **Puzzle Pack** (54 formas)
- **Ubicación**: `assets/images/shapes/`
- **Contenido**: Formas geométricas coloridas (círculos, cuadrados, diamantes, polígonos)
- **Uso**: ShapeTraceGame, PatternGame, PuzzleGame

### 4. **UI Pack Adventure** (50+ elementos)
- **Ubicación**: 
  - `assets/images/ui/` - Botones y elementos interactivos
  - `assets/backgrounds/` - Paneles y fondos
- **Contenido**: Botones, paneles, barras de progreso, banners
- **Uso**: UI de todos los juegos

### 5. **Pixel Platformer** (30 tiles)
- **Ubicación**: `assets/sprites/`
- **Contenido**: Tiles y sprites pixel art
- **Uso**: MazeGame, decoración general

## 📊 Estadísticas

- **Total de archivos PNG**: ~252
- **Iconos**: 105
- **Animales**: 50+
- **Formas**: 54
- **Fondos/Paneles**: 30
- **Sprites**: 30

## 🎨 Estructura de Carpetas

```
assets/
├── icons/              # 105 iconos de UI
├── images/
│   ├── animals/        # 50+ animales
│   ├── shapes/         # 54 formas geométricas
│   ├── ui/             # 23 elementos de UI
│   ├── fruits/         # (vacío - pendiente)
│   ├── letters/        # (vacío - pendiente)
│   ├── numbers/        # (vacío - pendiente)
│   └── vehicles/       # (vacío - pendiente)
├── sprites/            # 30 tiles/sprites
├── backgrounds/        # 30 paneles y fondos
├── sounds/             # (vacío - pendiente audio)
└── fonts/              # (vacío - pendiente fuentes)
```

## 🎮 Uso por Juego

### TraceGame / ShapeTraceGame
- Formas de `assets/images/shapes/`
- Iconos de UI para botones

### MemoryGame
- Animales de `assets/images/animals/`
- Formas de `assets/images/shapes/`
- Paneles de `assets/backgrounds/`

### PuzzleGame
- Cualquier imagen puede ser fuente
- Usar animales o sprites

### CountingGame
- Animales de `assets/images/animals/`
- Formas para contar

### MatchingGame
- Animales de `assets/images/animals/`
- Iconos para categorías

### PatternGame
- Formas de `assets/images/shapes/`
- Animales de `assets/images/animals/`

### MazeGame
- Sprites de `assets/sprites/`
- Fondos de `assets/backgrounds/`

### ColorByNumberGame
- Formas de `assets/images/shapes/`
- Paneles de `assets/backgrounds/`

### SoundRecognitionGame
- Animales de `assets/images/animals/`
- Iconos de `assets/icons/`

## 📝 Notas

- Todos los assets son de **Kenney.nl** (licencia CC0 - dominio público)
- Los assets están optimizados para móvil
- Se pueden usar libremente sin atribución (aunque es apreciada)
- Godot importará automáticamente los PNG como texturas

## 🔗 Fuentes

- [Kenney.nl](https://kenney.nl/)
- Licencia: CC0 1.0 Universal (Public Domain)
