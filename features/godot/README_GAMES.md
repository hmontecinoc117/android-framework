# Kids Educational Games - Suite de Juegos Educativos

## 🎯 Descripción del Proyecto

Suite de mini-juegos educativos diseñados para niños de 3 a 7 años, enfocados en desarrollo cognitivo, motricidad fina, coordinación visual-motora, y aprendizaje de números, letras y formas.

**Plataforma:** Android 8.0+ (API 23+)  
**Motor:** Godot 4.5  
**Lenguaje:** GDScript  
**Orientación:** Portrait (vertical) prioritario

## 🎮 Juegos Incluidos

### Implementados

1. **TraceGame** - Trazado de Letras y Números
   - Aprende a escribir letras y números siguiendo guías
   - 4 niveles de dificultad
   - Sistema de detección de trazado preciso

2. **MemoryGame** - Memorice
   - Encuentra parejas de cartas
   - 6 temáticas: animales, frutas, colores, números, formas, vehículos
   - Ajuste de dificultad (4x3, 4x4, 6x4)

3. **PuzzleGame** - Rompecabezas
   - Completa imágenes arrastrando piezas
   - Dificultad ajustable (4, 9, 16, 25 piezas)
   - Sistema de snap magnético

4. **CountingGame** - Conteo y Números
   - 4 modos: contar objetos, número faltante, ordenar, suma simple
   - Feedback visual y auditivo
   - Progresión adaptativa

### Por Implementar

5. **ShapeTraceGame** - Trazado de Formas Geométricas
6. **MatchingGame** - Unir Objetos con su Pareja
7. **ColorByNumberGame** - Colorear por Números
8. **PatternGame** - Secuencias y Patrones
9. **MazeGame** - Laberinto
10. **SoundRecognitionGame** - Reconocimiento de Sonidos

## 🏗️ Arquitectura del Proyecto

```
features/godot/
├── project.godot              # Configuración del proyecto
├── export_presets.cfg         # Configuración de exportación Android
│
├── scenes/                    # Escenas del juego
│   ├── main/                  # Menús y navegación
│   ├── games/                 # Escenas de juegos
│   ├── ui/                    # Componentes de UI
│   └── components/            # Componentes reutilizables
│
├── scripts/                   # Scripts GDScript
│   ├── autoload/             # Singletons globales
│   │   ├── GameManager.gd    # Gestión de progreso
│   │   ├── AudioManager.gd   # Gestión de audio
│   │   ├── SaveManager.gd    # Sistema de guardado
│   │   ├── ThemeManager.gd   # Temas visuales
│   │   └── VoiceInstructions.gd
│   ├── games/                # Lógica de cada juego
│   ├── components/           # Componentes reutilizables
│   │   ├── AnimatedButton.gd
│   │   ├── DraggableObject.gd
│   │   └── StarRating.gd
│   └── utils/                # Utilidades
│       ├── TouchInputHandler.gd
│       ├── AnimationHelper.gd
│       └── ScreenSizeAdapter.gd
│
├── assets/                   # Recursos multimedia
│   ├── images/              # Imágenes y sprites
│   ├── sounds/              # Música, efectos, voces
│   ├── fonts/               # Fuentes tipográficas
│   └── animations/          # Animaciones
│
└── translations/            # Archivos de localización
```

## 🎨 Sistema de Gestión Global

### GameManager (Autoload)
- **Propósito:** Gestión central del progreso del juego
- **Funciones principales:**
  - Seguimiento de progreso por juego
  - Sistema de desbloqueo progresivo
  - Gestión de perfiles de jugadores
  - Cálculo de estrellas y recompensas

### AudioManager (Autoload)
- **Propósito:** Control centralizado de audio
- **Características:**
  - Pool de reproductores de efectos de sonido
  - Sistema de buses de audio (Música, SFX, Voz)
  - Control de volumen independiente
  - Fade in/out automático

### SaveManager (Autoload)
- **Propósito:** Persistencia de datos
- **Datos guardados:**
  - Progreso de juegos
  - Perfiles de jugadores
  - Configuración de audio
  - Tiempo de juego

### TouchInputHandler (Autoload)
- **Propósito:** Gestión avanzada de input táctil
- **Detecta:**
  - Single tap / Double tap
  - Long press
  - Swipe (con dirección)
  - Pinch (zoom)
  - Drag

## 🎨 Paleta de Colores

```gdscript
# Colores primarios
COLOR_PRIMARY_BLUE   = #4A90E2  # Azul amigable
COLOR_PRIMARY_GREEN  = #7ED321  # Verde éxito
COLOR_PRIMARY_YELLOW = #F5A623  # Amarillo atención
COLOR_PRIMARY_RED    = #E85D75  # Rojo suave

# Fondos pasteles
COLOR_BG_SKY    = #E8F4F8  # Fondo cielo
COLOR_BG_GRASS  = #F0F8E8  # Fondo pasto
COLOR_BG_SUNSET = #FFF4E6  # Fondo cálido

# Feedback
COLOR_SUCCESS = #52C41A  # Verde aprobación
COLOR_ERROR   = #FF6B6B  # Rojo error suave
COLOR_NEUTRAL = #8C8C8C  # Gris neutral
```

## 🔧 Componentes Reutilizables

### AnimatedButton
Botón con animaciones automáticas:
- Efecto hover (escala 1.1x)
- Efecto press (escala 0.95x)
- Bounce al hacer clic
- Animación de pulso
- Shake para errores

### DraggableObject
Objeto arrastrable con:
- Detección de drag & drop
- Snap magnético a objetivos
- Retorno elástico al origen
- Cambio de escala durante arrastre
- Bloqueo/desbloqueo dinámico

### StarRating
Sistema de calificación por estrellas:
- Animación secuencial de estrellas
- Efectos de partículas
- Sonidos por estrella conseguida
- Vibración en móvil

## 🎯 Principios de Diseño UI/UX

1. **Botones grandes:** Mínimo 120x120px para dedos pequeños
2. **Espaciado generoso:** 20-40px entre elementos interactivos
3. **Feedback inmediato:** Animaciones de 0.2-0.5s
4. **Sonidos positivos:** Nunca punitivos
5. **Fuentes grandes:** Mínimo 48px para instrucciones
6. **Iconografía clara:** Símbolos universales

## 📱 Configuración Android

### Requisitos
- **Min SDK:** API 23 (Android 8.0)
- **Target SDK:** API 33 (Android 13)
- **Arquitecturas:** ARM64-v8a (solo dispositivos modernos)
- **Permisos:** Ninguno (sin internet, sin datos)

### Orientación
- **Primaria:** Portrait (vertical)
- **Secundaria:** Landscape opcional
- **Modo Inmersivo:** Activado (sin barras del sistema)

### Performance Targets
- **FPS mínimo:** 60 FPS
- **Tamaño APK:** < 150 MB
- **Uso de RAM:** < 300 MB
- **Tiempo de carga:** < 3 segundos por juego

## 🚀 Cómo Usar

### Desarrollo

1. Abre el proyecto en Godot 4.5+
2. Las escenas principales están en `scenes/main/`
3. Cada juego tiene su propia escena en `scenes/games/`
4. Los autoloads están configurados automáticamente

### Testing

```bash
# Ejecutar en el editor
F5 en Godot

# Exportar para Android
Project > Export > Android > Export Project
```

### Build para Producción

```bash
# Desde línea de comandos
godot --headless --export-release "Android" builds/KidsGames.apk

# Instalar en dispositivo
adb install builds/KidsGames.apk
```

## 🎓 Sistema de Progreso

### Desbloqueo Progresivo
- El primer juego (TraceGame) está desbloqueado por defecto
- Completar un juego con al menos 1 estrella desbloquea el siguiente
- Cada juego tiene 5 niveles internos de dificultad

### Sistema de Estrellas
- **3 estrellas:** Excelente rendimiento (tiempo/precisión)
- **2 estrellas:** Buen rendimiento
- **1 estrella:** Completado

### Guardado Automático
- El progreso se guarda automáticamente al completar juegos
- Los datos se almacenan en `user://save_data.json`
- Las configuraciones en `user://settings.json`

## 📊 Adaptación de Pantalla

El sistema `ScreenSizeAdapter` ajusta automáticamente:
- Tamaños de fuente
- Tamaños de botones
- Espaciado entre elementos
- Layout según dispositivo (teléfono/tablet)

## 🔊 Sistema de Audio

### Estructura de Sonidos
```
assets/sounds/
├── music/
│   ├── menu_theme.ogg
│   └── game_background.ogg
├── effects/
│   ├── button_press.ogg
│   ├── success.ogg
│   ├── error.ogg
│   ├── star_earned.ogg
│   └── game_complete.ogg
└── voice/
    ├── instructions_es/
    └── feedback_es/
```

## 🌐 Internacionalización

Preparado para i18n:
- Sistema de traducciones en `translations/`
- Actualmente soporta español
- Fácil añadir nuevos idiomas

## ⚖️ Consideraciones Legales (COPPA)

✅ **NO implementa:**
- Recolección de datos personales
- Analytics con datos identificables
- Publicidad
- Compras in-app
- Redes sociales
- Geolocalización

✅ **SÍ implementa:**
- Modo offline completo
- Guardado local únicamente
- Sin conexión a internet

## 🐛 Debug y Testing

### Comandos útiles
```bash
# Ver logs en Android
adb logcat -s godot:*

# Profiling de rendimiento
godot --profile scenes/games/MemoryGame.tscn
```

### Flags de Debug
- `OS.is_debug_build()` para código de debug
- `ScreenSizeAdapter.print_screen_info()` para info de pantalla

## 📝 TODO / Próximos Pasos

- [ ] Implementar juegos restantes (5-10)
- [ ] Crear assets visuales (iconos, sprites, fondos)
- [ ] Grabar efectos de sonido
- [ ] Grabar instrucciones de voz en español
- [ ] Crear música de fondo
- [ ] Diseñar íconos de launcher
- [ ] Testing en múltiples dispositivos
- [ ] Optimización de rendimiento
- [ ] Crear video promocional
- [ ] Publicar en Google Play Store

## 👥 Contribución

Este es un proyecto educativo. Para contribuir:
1. Mantén el código simple y comentado
2. Sigue la guía de estilo de GDScript
3. Prueba en dispositivos reales
4. Documenta nuevas características

## 📄 Licencia

[Definir licencia apropiada]

---

**Versión:** 1.0.0  
**Fecha:** Enero 2026  
**Motor:** Godot 4.5  
**Plataforma:** Android 8.0+
