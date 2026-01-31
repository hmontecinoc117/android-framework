# Mapeo de Sonidos - Kenney Interface Sounds

## Sonidos Disponibles (100 archivos .ogg)

### Clicks y Botones
- `click_001.ogg` - `click_005.ogg` - Sonidos de click variados
- `bong_001.ogg` - Click tipo campana

### Confirmación
- `confirmation_001.ogg` - `confirmation_004.ogg` - Sonidos de confirmación positivos

### Errores
- `error_001.ogg` - `error_008.ogg` - Sonidos de error variados
- `glass_001.ogg` - `glass_006.ogg` - Sonidos de vidrio rompiéndose
- `glitch_001.ogg` - `glitch_004.ogg` - Sonidos de glitch/error

### UI Interactiva
- `maximize_001.ogg` - `maximize_009.ogg` - Sonidos de maximizar/abrir
- `minimize_001.ogg` - `minimize_009.ogg` - Sonidos de minimizar/cerrar
- `open_001.ogg` - `open_004.ogg` - Sonidos de apertura
- `close_001.ogg` - `close_004.ogg` - Sonidos de cierre

### Navegación
- `forward_001.ogg` - `forward_005.ogg` - Sonidos de avanzar
- `back_001.ogg` - `back_004.ogg` - Sonidos de retroceder
- `scroll_001.ogg` - `scroll_005.ogg` - Sonidos de scroll
- `switch_001.ogg` - `switch_007.ogg` - Sonidos de cambio/switch

### Selección
- `select_001.ogg` - `select_008.ogg` - Sonidos de selección
- `toggle_001.ogg` - `toggle_003.ogg` - Sonidos de toggle

### Acciones
- `drop_001.ogg` - `drop_004.ogg` - Sonidos de soltar objetos
- `tick_001.ogg` - `tick_004.ogg` - Sonidos de tick/check

### Alertas
- `question_001.ogg` - `question_003.ogg` - Sonidos de pregunta

## Mapeo Recomendado para Juegos

### Efectos Generales
- **button_click**: `click_001.ogg`
- **button_hover**: `minimize_001.ogg`
- **success**: `confirmation_001.ogg`
- **error**: `error_001.ogg`
- **complete**: `confirmation_004.ogg`

### TraceGame / ShapeTraceGame
- **trace_start**: `toggle_001.ogg`
- **trace_progress**: `tick_001.ogg`
- **trace_complete**: `confirmation_002.ogg`

### MemoryGame
- **card_flip**: `toggle_002.ogg`
- **card_match**: `select_003.ogg`
- **card_no_match**: `error_003.ogg`

### PuzzleGame
- **piece_pick**: `select_001.ogg`
- **piece_drop**: `drop_001.ogg`
- **piece_snap**: `tick_002.ogg`

### CountingGame
- **number_select**: `click_002.ogg`
- **correct_answer**: `confirmation_003.ogg`
- **wrong_answer**: `error_002.ogg`

### MatchingGame
- **line_start**: `toggle_001.ogg`
- **line_complete**: `select_002.ogg`
- **match_success**: `maximize_001.ogg`

### PatternGame
- **pattern_show**: `tick_003.ogg`
- **element_place**: `select_004.ogg`

### MazeGame
- **player_move**: `scroll_002.ogg`
- **item_collect**: `maximize_002.ogg`
- **goal_reach**: `confirmation_004.ogg`

### ColorByNumberGame
- **color_select**: `select_005.ogg`
- **section_fill**: `tick_004.ogg`

### SoundRecognitionGame
- **option_select**: `select_006.ogg`
- **play_sound**: `toggle_003.ogg`

## Ubicación de Archivos
- **Música**: `assets/sounds/music/`
- **Efectos**: `assets/sounds/sfx/`
- **Voces**: `assets/sounds/voice/`

## Notas
- Todos los archivos son formato .ogg (compatible con Godot)
- Licencia: CC0 (dominio público)
- Fuente: Kenney.nl
