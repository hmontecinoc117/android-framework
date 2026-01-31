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
    
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        Log.d(TAG, "=== GodotGameActivity onCreate INICIADO ===")
        Log.d(TAG, "filesDir: ${filesDir.absolutePath}")
        
        // Copiar game.pck de assets al almacenamiento interno
        copyPckFromAssets()
        
        Log.d(TAG, "Llamando super.onCreate()")
        super.onCreate(savedInstanceState)
        Log.d(TAG, "=== GodotGameActivity onCreate COMPLETO ===")
    }
    
    /**
     * Copia el archivo game.pck desde assets al directorio de archivos de la app
     */
    private fun copyPckFromAssets() {
        try {
            val pckFileName = "app_game.pck"
            val outFile = File(filesDir, pckFileName)
            
            Log.d(TAG, "Copiando $pckFileName desde assets (siempre actualiza)...")
            assets.open(pckFileName).use { input ->
                FileOutputStream(outFile).use { output ->
                    input.copyTo(output)
                }
            }
            Log.d(TAG, "✅ Archivo copiado a ${outFile.absolutePath}")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error copiando .pck desde assets: ${e.message}", e)
        }
    }
    
    override fun getCommandLine(): MutableList<String> {
        val commandLine = mutableListOf<String>()
        
        // Especificar la ruta completa al archivo .pck en el almacenamiento interno
        val pckFile = File(filesDir, "app_game.pck")
        if (pckFile.exists()) {
            commandLine.add("--main-pack")
            commandLine.add(pckFile.absolutePath)
            Log.d(TAG, "Cargando .pck desde: ${pckFile.absolutePath}")
        } else {
            Log.e(TAG, "❌ No se encontró el archivo .pck en ${pckFile.absolutePath}")
        }
        
        return commandLine
    }
}
