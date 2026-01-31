package com.framework.features.godot

/**
 * Constantes para las rutas de las escenas de Godot
 */
object GodotScenes {
    /**
     * Menú principal con botones para los juegos
     */
    const val MENU = "res://assets/scenes/menu.tscn"
    
    /**
     * Juego de trazado de palabras (usa assets/data/animals.json)
     */
    const val TRACE_WORDS = "res://assets/scenes/trace_words.tscn"
    
    /**
     * Juego de trazado de figuras (auto, tren, avión, etc.)
     */
    const val TRACE_SHAPES = "res://assets/scenes/trace_shapes.tscn"
    
    /**
     * Juego de rompecabezas
     * Nota: Asigna source_image en el inspector de Godot
     */
    const val PUZZLE = "res://assets/scenes/puzzle.tscn"
    
    /**
     * Juego de memoria (memorice)
     * Nota: Asigna card_textures en el inspector de Godot
     */
    const val MEMORY = "res://assets/scenes/memory.tscn"
}

/**
 * Helper para lanzar escenas de Godot fácilmente
 */
object GodotLauncher {
    /**
     * Lanza una escena de Godot desde cualquier contexto Android
     * @param context Contexto de Android
     * @param scenePath Ruta de la escena (usar constantes de GodotScenes)
     */
    fun launch(context: android.content.Context, scenePath: String) {
        val manager = GodotViewManager(context)
        manager.startGodotActivity(scenePath)
    }
    
    /**
     * Lanza el menú principal de Godot
     */
    fun launchMenu(context: android.content.Context) {
        launch(context, GodotScenes.MENU)
    }
    
    /**
     * Lanza el juego de trazado de palabras
     */
    fun launchTraceWords(context: android.content.Context) {
        launch(context, GodotScenes.TRACE_WORDS)
    }
    
    /**
     * Lanza el juego de trazado de formas
     */
    fun launchTraceShapes(context: android.content.Context) {
        launch(context, GodotScenes.TRACE_SHAPES)
    }
    
    /**
     * Lanza el juego de rompecabezas
     */
    fun launchPuzzle(context: android.content.Context) {
        launch(context, GodotScenes.PUZZLE)
    }
    
    /**
     * Lanza el juego de memoria
     */
    fun launchMemory(context: android.content.Context) {
        launch(context, GodotScenes.MEMORY)
    }
}
