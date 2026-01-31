package com.framework.features.godot

import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.View
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView

/**
 * Interfaz para comunicación Godot ↔ Kotlin
 */
interface IGodotCallback {
    fun onSceneReady(sceneName: String)
    fun onSceneEvent(eventName: String, data: Map<String, Any>)
    fun onError(errorMessage: String)
}

/**
 * Clase para gestionar vistas de Godot en Android
 */
class GodotViewManager(val context: Context) {
    private var godotView: View? = null
    private val callbacks = mutableListOf<IGodotCallback>()

    /**
     * Intenta iniciar la `GodotActivity` si Godot está incluida como dependency/APK
     * @param scenePath Ruta de la escena Godot a cargar, por ejemplo: "res://assets/scenes/menu.tscn"
     */
    fun startGodotActivity(scenePath: String) {
        try {
            // Lanzar la GodotActivity con la escena especificada
            val intent = Intent(context, Class.forName("org.godotengine.godot.GodotActivity"))
            intent.putExtra("--main-pack", scenePath)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            
            Log.d("GodotViewManager", "Iniciando escena: $scenePath")
            notifySceneReady(scenePath)
        } catch (e: ClassNotFoundException) {
            val error = "GodotActivity no encontrada. Verifica que godot-lib.aar esté en las dependencias."
            Log.e("GodotViewManager", error, e)
            notifyError(error)
        } catch (e: Exception) {
            val error = "Error al iniciar GodotActivity: ${e.message}"
            Log.e("GodotViewManager", error, e)
            notifyError(error)
        }
    }

    fun registerCallback(callback: IGodotCallback) {
        callbacks.add(callback)
    }

    fun unregisterCallback(callback: IGodotCallback) {
        callbacks.remove(callback)
    }

    fun notifySceneReady(sceneName: String) {
        callbacks.forEach { it.onSceneReady(sceneName) }
    }

    fun notifySceneEvent(eventName: String, data: Map<String, Any>) {
        callbacks.forEach { it.onSceneEvent(eventName, data) }
    }

    fun notifyError(error: String) {
        callbacks.forEach { it.onError(error) }
    }
}

/**
 * Composable para renderizar escenas de Godot
 * @param scenePath Ruta del archivo .tscn en assets
 * @param modifier Modificador de composición
 * @param onSceneReady Callback cuando la escena carga
 * @param onSceneEvent Callback para eventos de la escena
 */
@Composable
fun GodotSceneView(
    scenePath: String,
    modifier: Modifier = Modifier,
    onSceneReady: (String) -> Unit = {},
    onSceneEvent: (String, Map<String, Any>) -> Unit = { _, _ -> },
) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentAlignment = Alignment.Center
    ) {
        AndroidView(
            factory = { context ->
                // Aquí irá la instancia real de GodotView cuando esté disponible
                // Por ahora retornamos una vista simple de Android
                android.widget.TextView(context).apply {
                    text = "Godot Scene: $scenePath\nUsa GodotLauncher para abrir escenas"
                    textAlignment = android.view.View.TEXT_ALIGNMENT_CENTER
                    gravity = android.view.Gravity.CENTER
                    setTextColor(android.graphics.Color.WHITE)
                    textSize = 18f
                }
            },
            modifier = Modifier.fillMaxSize()
        )
    }
}

/**
 * Ejemplo de uso en un Screen
 * @see GodotGameScreen
 */
@Composable
fun GodotGameScreen(
    modifier: Modifier = Modifier,
    scenePath: String = "res://scenes/main_scene.tscn"
) {
    GodotSceneView(
        scenePath = scenePath,
        modifier = modifier,
        onSceneReady = { scene ->
            println("✅ Escena cargada: $scene")
        },
        onSceneEvent = { event, data ->
            println("📢 Evento de Godot: $event - $data")
        }
    )
}
