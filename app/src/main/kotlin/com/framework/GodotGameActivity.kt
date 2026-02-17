package com.framework

import android.util.Log
import org.godotengine.godot.FullScreenGodotApp
import java.io.File
import java.io.FileOutputStream

/**
 * Activity que ejecuta el juego de Godot en pantalla completa.
 * Extiende FullScreenGodotApp que es la clase correcta para Godot 4.x
 */
class GodotGameActivity : FullScreenGodotApp() {
    
    private val TAG = "GodotGameActivity"
    private val PCK_FILE_NAME = "app_game.pck"
    
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        Log.d(TAG, "=== GodotGameActivity onCreate INICIADO ===")
        Log.d(TAG, "filesDir: ${filesDir.absolutePath}")
        
        // Validar y copiar game.pck de assets al almacenamiento interno
        if (!validateAndCopyPck()) {
            Log.e(TAG, "❌ Falló la validación del PCK. Abortando.")
            showErrorDialog("Error: No se pudieron cargar los archivos del juego")
            finish()
            return
        }
        
        Log.d(TAG, "Llamando super.onCreate()")
        super.onCreate(savedInstanceState)
        Log.d(TAG, "=== GodotGameActivity onCreate COMPLETO ===")
    }
    
    /**
     * Valida y copia el archivo .pck desde assets al directorio de archivos de la app
     * @return true si el proceso fue exitoso, false en caso contrario
     */
    private fun validateAndCopyPck(): Boolean {
        try {
            // Verificar que el archivo existe en assets
            val assetFiles = assets.list("")
            if (assetFiles?.contains(PCK_FILE_NAME) != true) {
                Log.e(TAG, "❌ $PCK_FILE_NAME no encontrado en assets")
                Log.d(TAG, "Assets disponibles: ${assetFiles?.joinToString()}")
                return false
            }
            
            val outFile = File(filesDir, PCK_FILE_NAME)
            
            Log.d(TAG, "Copiando $PCK_FILE_NAME desde assets...")
            val startTime = System.currentTimeMillis()
            
            assets.open(PCK_FILE_NAME).use { input ->
                FileOutputStream(outFile).use { output ->
                    val bytescopied = input.copyTo(output)
                    Log.d(TAG, "📦 Bytes copiados: $bytescopied")
                }
            }
            
            val elapsed = System.currentTimeMillis() - startTime
            val size = outFile.length()
            
            // Validar tamaño mínimo (100KB)
            val minSize = 100_000L
            if (size < minSize) {
                Log.e(TAG, "❌ PCK demasiado pequeño: $size bytes (mínimo: $minSize)")
                return false
            }
            
            Log.d(TAG, "✅ PCK copiado exitosamente")
            Log.d(TAG, "   Ruta: ${outFile.absolutePath}")
            Log.d(TAG, "   Tamaño: ${size / 1024}KB")
            Log.d(TAG, "   Tiempo: ${elapsed}ms")
            
            return true
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error validando/copiando .pck: ${e.message}", e)
            return false
        }
    }
    
    /**
     * Muestra un diálogo de error al usuario
     */
    private fun showErrorDialog(message: String) {
        runOnUiThread {
            android.app.AlertDialog.Builder(this)
                .setTitle("Error")
                .setMessage(message)
                .setPositiveButton("Cerrar") { _, _ -> finish() }
                .setCancelable(false)
                .show()
        }
    }
    
    override fun getCommandLine(): MutableList<String> {
        val commandLine = mutableListOf<String>()
        
        // Especificar la ruta completa al archivo .pck en el almacenamiento interno
        val pckFile = File(filesDir, PCK_FILE_NAME)
        if (pckFile.exists()) {
            commandLine.add("--main-pack")
            commandLine.add(pckFile.absolutePath)
            Log.d(TAG, "✅ Cargando .pck desde: ${pckFile.absolutePath} (${pckFile.length() / 1024}KB)")
        } else {
            Log.e(TAG, "❌ CRÍTICO: No se encontró el archivo .pck en ${pckFile.absolutePath}")
        }
        
        // Pasar escena inicial solicitada (si fue proporcionada por el launcher)
        val sceneRequested = intent?.getStringExtra("godot_startup_scene")
        if (!sceneRequested.isNullOrBlank()) {
            commandLine.add("--startup-scene")
            commandLine.add(sceneRequested)
            Log.d(TAG, "🎮 Escena inicial solicitada: $sceneRequested")
        } else {
            Log.d(TAG, "ℹ️  No se especificó escena inicial, usando main_scene del proyecto")
        }
        
        Log.d(TAG, "📋 Command line: ${commandLine.joinToString(" ")}")
        return commandLine
    }
}
