# Uso rápido del módulo Tracing (en español)

Este documento explica cómo integrar y ejecutar el juego de trazado en tu app.

## Lanzar la Activity
Desde cualquier Activity o Composable que actúe como menú principal, lanza la Activity del módulo:

```kotlin
val intent = Intent(context, TracingMainActivity::class.java)
intent.putExtra("level", 1) // opcional: seleccionar nivel
startActivity(intent)
```

También puedes pasar una lista personalizada de palabras:

```kotlin
intent.putStringArrayListExtra("words", arrayListOf("perro","gato","elefante"))
```

## Archivos de datos
Coloca archivos JSON en `src/main/res/raw` o en `assets` con la estructura de niveles. El módulo incluye `res/raw/tracing_words.json` como ejemplo.

## Configuración recomendada
- Jetpack Compose activado en el módulo.
- Separar la lógica de juego en un `ViewModel` para facilitar pruebas.
- Inyectar listas de palabras (Hilt o constructor) para facilitar tests y cambios.

## Probar localmente
1. Compila el proyecto: `./gradlew assembleDebug`.
2. Instala el APK en un emulador o dispositivo.
3. Desde el menú principal, abre la Activity de trazado.

## Personalización
- Cambiar fuente y tamaño para ajustar la precisión del trazado.
- Ajustar el umbral de intersección para marcar una letra como "completada".
- Añadir efectos sonoros o animaciones al completar palabras.
