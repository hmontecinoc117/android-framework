package com.framework.features.intermediate.database

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

data class Note(
    val id: String = "",
    val title: String = "",
    val content: String = "",
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
)

class NoteViewModel : ViewModel() {
    private val _notes = MutableStateFlow<List<Note>>(emptyList())
    val notes: StateFlow<List<Note>> = _notes.asStateFlow()

    fun addNote(title: String, content: String) {
        val newNote = Note(
            id = System.currentTimeMillis().toString(),
            title = title,
            content = content
        )
        _notes.value = _notes.value + newNote
    }

    fun updateNote(id: String, title: String, content: String) {
        _notes.value = _notes.value.map { note ->
            if (note.id == id) {
                note.copy(
                    title = title,
                    content = content,
                    updatedAt = System.currentTimeMillis()
                )
            } else {
                note
            }
        }
    }

    fun deleteNote(id: String) {
        _notes.value = _notes.value.filterNot { it.id == id }
    }
}
