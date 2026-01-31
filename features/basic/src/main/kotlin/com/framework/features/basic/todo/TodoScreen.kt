package com.framework.features.basic.todo

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp

@Composable
fun TodoScreen(viewModel: TodoViewModel = TodoViewModel()) {
    val todos by viewModel.todos.collectAsState()
    var newTodoTitle by remember { mutableStateOf("") }
    var newTodoDescription by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text(
            text = "Mi Lista de Tareas",
            style = MaterialTheme.typography.headlineLarge
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Input para nueva tarea
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                TextField(
                    value = newTodoTitle,
                    onValueChange = { newTodoTitle = it },
                    label = { Text("Título") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )

                Spacer(modifier = Modifier.height(8.dp))

                TextField(
                    value = newTodoDescription,
                    onValueChange = { newTodoDescription = it },
                    label = { Text("Descripción") },
                    modifier = Modifier.fillMaxWidth(),
                    maxLines = 2
                )

                Spacer(modifier = Modifier.height(8.dp))

                Button(
                    onClick = {
                        viewModel.addTodo(newTodoTitle, newTodoDescription)
                        newTodoTitle = ""
                        newTodoDescription = ""
                    },
                    modifier = Modifier.align(Alignment.End)
                ) {
                    Icon(Icons.Default.Add, contentDescription = "Añadir")
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("Añadir")
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Lista de tareas
        LazyColumn(
            modifier = Modifier.fillMaxSize()
        ) {
            items(todos) { todo ->
                TodoItemCard(
                    todo = todo,
                    onToggle = { viewModel.toggleTodo(todo.id) },
                    onDelete = { viewModel.deleteTodo(todo.id) }
                )
                Spacer(modifier = Modifier.height(8.dp))
            }
        }
    }
}

@Composable
fun TodoItemCard(
    todo: TodoItem,
    onToggle: () -> Unit,
    onDelete: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(
                onClick = onToggle,
                modifier = Modifier.size(40.dp)
            ) {
                Icon(
                    Icons.Default.Check,
                    contentDescription = "Completar",
                    tint = if (todo.completed) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline
                )
            }

            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(start = 8.dp)
            ) {
                Text(
                    text = todo.title,
                    style = MaterialTheme.typography.titleMedium,
                    textDecoration = if (todo.completed) TextDecoration.LineThrough else TextDecoration.None
                )
                if (todo.description.isNotEmpty()) {
                    Text(
                        text = todo.description,
                        style = MaterialTheme.typography.bodySmall
                    )
                }
            }

            IconButton(onClick = onDelete) {
                Icon(Icons.Default.Delete, contentDescription = "Eliminar")
            }
        }
    }
}
