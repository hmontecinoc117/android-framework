
# Juego de Trazado (Tracing)

Este módulo proporciona un juego de trazado pensado para niños, donde se muestran palabras (ej. nombres de animales en español) y el usuario puede trazar sobre las letras. Cuando la palabra está completamente trazada, el juego avanza al siguiente nivel/palabra.

## Contenido
- `TracingMainActivity`: Activity que hospeda la UI del juego.
- `TracingGameScreen`: Composable que muestra la palabra, captura los trazos del usuario y marca letras completadas.
- Recursos: imágenes, fuentes y datos con las listas de palabras.

## Funcionamiento (resumen)
1. Se carga una lista de palabras para el nivel seleccionado (por ejemplo, nombres de animales en español).
2. `TracingGameScreen` renderiza la palabra con una fuente adecuada y calcula las áreas aproximadas de cada letra.
3. El usuario dibuja con el dedo o lápiz; los trazos quedan registrados como rutas (paths).
4. Si un trazo intersecta suficientemente el área de una letra, esa letra se marca como trazada (cambia de color/estilo).
5. Cuando todas las letras de la palabra están trazadas, se reproduce una animación/sonido y se carga la siguiente palabra.

## Cómo usar (integración rápida)
1. Añadir el módulo a `settings.gradle.kts` (ya incluido si se creó el módulo `:features:tracing`).
2. Desde el menú principal de tu app, lanza `TracingMainActivity` con un Intent:

```kotlin
val intent = Intent(context, TracingMainActivity::class.java)
startActivity(intent)
```

3. Puedes pasar extras para seleccionar lista de palabras o nivel:

```kotlin
intent.putExtra("level", 1)
intent.putStringArrayListExtra("words", arrayListOf("perro","gato","elefante"))
```

## Añadir/Modificar palabras y niveles
- Las palabras se cargan desde un archivo JSON o lista en `res/raw` / `assets` para facilitar su edición.
- Formato recomendado (JSON):

```json
{
	"levels": [
		{ "id": 1, "name": "Animales básicos", "words": ["perro","gato","pez"] },
		{ "id": 2, "name": "Animales de granja", "words": ["vaca","cerdo","oveja"] }
	]
}
```

## Extensibilidad
- Soporta múltiples categorías (animales, colores, alimentos) añadiendo nuevas listas.
- Para mejorar la precisión del reconocimiento de trazos sobre letras se puede usar la forma de los glifos (glyph paths) de la fuente en vez de rectángulos aproximados.
- Añadir nuevas recompensas (sonidos, animaciones) al completar palabras.

## Requisitos
- Jetpack Compose
- Kotlin 1.9+ (según el proyecto)
- Mínimo SDK: el mismo que usa el framework (24 en este proyecto)

## Notas para desarrolladores
- Mantener la UI modular: la lógica del juego (ViewModel) debe estar separada de la representación (Composable).
- Proveer interfaces para inyectar listas de palabras y adaptadores de persistencia (por ejemplo, Room o archivos JSON).

## Próximos pasos sugeridos
- Integrar desde el menú principal y añadir un selector de categorías.
- Añadir pruebas unitarias para la lógica de detección de letras trazadas.

---

Si quieres, traduzco también los comentarios en los archivos fuente y añado un ejemplo de datos (`res/raw/tracing_words.json`) y la Activity/Composable de ejemplo en este módulo.
