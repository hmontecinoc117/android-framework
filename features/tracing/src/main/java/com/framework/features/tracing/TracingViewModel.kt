package com.framework.features.tracing

/**
 * ViewModel para la lógica del juego de trazado.
 * Mantiene la lista de palabras, índice actual y qué letras fueron completadas.
 */
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

data class TracingUiState(
    val words: List<String> = emptyList(),
    val index: Int = 0,
    val completedLetters: List<Boolean> = emptyList()
) {
    val currentWord: String
        get() = words.getOrNull(index) ?: ""
}

class TracingViewModel : ViewModel() {
    private val defaultWords = listOf("perro", "gato", "pez")
    private val _uiState = MutableStateFlow(TracingUiState(words = defaultWords, index = 0, completedLetters = List(defaultWords.firstOrNull()?.length ?: 0) { false }))
    val uiState: StateFlow<TracingUiState> = _uiState.asStateFlow()

    /**
     * Establece la lista de palabras a usar en el juego.
     */
    fun setWords(list: List<String>) {
        _uiState.value = TracingUiState(words = list, index = 0, completedLetters = List(list.firstOrNull()?.length ?: 0) { false })
    }

    fun setLevel(level: Int) {
        // Placeholder: en el futuro cargar por nivel
        val word = _uiState.value.words.getOrNull(_uiState.value.index) ?: ""
        _uiState.value = _uiState.value.copy(completedLetters = List(word.length) { false })
    }

    /**
     * Procesamiento de trazos (no usado directamente): la detección real se hace en la capa UI
     * y se notifican los índices de letras completadas mediante `markLetters`.
     */
    fun processStroke(points: List<androidx.compose.ui.geometry.Offset>) {
        val word = _uiState.value.currentWord
        if (word.isEmpty()) return

        // Placeholder: la detección la realiza el Composable y llama a `markLetters`.
    }

    fun markLetters(indices: List<Int>) {
        val current = _uiState.value
        val newCompleted = current.completedLetters.toMutableList()
        for (i in indices) if (i in newCompleted.indices) newCompleted[i] = true
        _uiState.value = current.copy(completedLetters = newCompleted)
    }

    fun nextWord() {
        val current = _uiState.value
        if (current.words.isEmpty()) return
        val nextIndex = if (current.index + 1 < current.words.size) current.index + 1 else 0
        val nextWord = current.words.getOrNull(nextIndex) ?: ""
        _uiState.value = current.copy(index = nextIndex, completedLetters = List(nextWord.length) { false })
    }
}
