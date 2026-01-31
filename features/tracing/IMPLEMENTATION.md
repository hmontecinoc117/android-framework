# Implementación interna del módulo Tracing

Este documento describe la arquitectura y los puntos clave de implementación del juego de trazado.

## Componentes principales
- `TracingMainActivity`: Activity que configura el `ViewModel` y muestra el `TracingGameScreen`.
- `TracingViewModel`: Lógica del juego (cargar palabras, estado de letras, manejo de niveles y progreso).
- `TracingGameScreen` (Composable): Renderiza la palabra y captura eventos de puntero (touch).
- `TracingCanvas`: Composable o helper que mantiene las rutas (`Path`) dibujadas por el usuario y calcula colisiones.

## Detección de letras trazadas
- Inicialmente se calculan bounds aproximados por letra (rectángulos o polígonos) usando la posición en la pantalla y métricas de la fuente.
- Los trazos del usuario se registran como `Path` y se simplifican a líneas/curvas para calcular intersecciones con bounding boxes.
- Si la proporción de área o longitud de trazo dentro del área de la letra supera un umbral configurable, la letra se marca como completada.
- Mejora futura: usar `Paint.getTextPath()` o la API de `Typeface` para obtener los contornos reales del glifo y comparar con el `Path` del usuario.

## Datos y niveles
- Los datos de palabras se cargan desde JSON en `res/raw` o `assets`.
- Estructura soportada: objeto `levels` con id, nombre y array `words`.

## Extensibilidad y pruebas
- Separar lógica en `TracingViewModel` permite probar la detección de completitud de letras sin depender de la UI.
- Añadir interfaces para la fuente de datos (ej. `WordRepository`) facilita cambiar entre `assets`, `res/raw` o una fuente remota.

## Recomendaciones de rendimiento
- Debounce de eventos de puntero para no procesar intersecciones en cada píxel.
- Cachear bounds de letras hasta que la configuración de pantalla/fuente cambie.

## Puntos de integración
- Intent extras para seleccionar nivel/lista de palabras.
- Callbacks o `Flow` para notificar completitud de palabra (útil para integrar animaciones o sonido desde la Activity).

