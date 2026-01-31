package com.framework.features.basic.todo

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class TodoViewModel : ViewModel() {
    private val _todos = MutableStateFlow<List<TodoItem>>(emptyList())
    val todos: StateFlow<List<TodoItem>> = _todos.asStateFlow()

    fun addTodo(title: String, description: String = "") {
        if (title.isBlank()) return
        val newTodo = TodoItem(
            id = java.util.UUID.randomUUID().toString(),
            title = title,
            description = description
        )
        _todos.value = _todos.value + newTodo
    }

    fun toggleTodo(id: String) {
        _todos.value = _todos.value.map { todo ->
            if (todo.id == id) todo.copy(completed = !todo.completed) else todo
        }
    }

    fun deleteTodo(id: String) {
        _todos.value = _todos.value.filterNot { it.id == id }
    }

    fun updateTodo(id: String, title: String, description: String) {
        _todos.value = _todos.value.map { todo ->
            if (todo.id == id) todo.copy(title = title, description = description) else todo
        }
    }
}
