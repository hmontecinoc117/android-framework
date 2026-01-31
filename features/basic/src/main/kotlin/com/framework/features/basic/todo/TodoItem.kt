package com.framework.features.basic.todo

data class TodoItem(
    val id: String = "",
    val title: String = "",
    val description: String = "",
    val completed: Boolean = false,
    val createdAt: Long = System.currentTimeMillis()
)
