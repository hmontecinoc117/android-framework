package com.framework.features.basic.todo

import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class TodoViewModelTest {
    
    private lateinit var viewModel: TodoViewModel

    @Before
    fun setUp() {
        viewModel = TodoViewModel()
    }

    @Test
    fun testInitialTodoListIsEmpty() = runBlocking {
        val todos = viewModel.todos.first()
        assertTrue(todos.isEmpty())
    }

    @Test
    fun testAddTodo() = runBlocking {
        viewModel.addTodo("Test Todo", "Description")
        val todos = viewModel.todos.first()
        
        assertEquals(1, todos.size)
        assertEquals("Test Todo", todos[0].title)
        assertEquals("Description", todos[0].description)
        assertEquals(false, todos[0].completed)
    }

    @Test
    fun testAddTodoWithoutDescription() = runBlocking {
        viewModel.addTodo("Test Todo")
        val todos = viewModel.todos.first()
        
        assertEquals(1, todos.size)
        assertEquals("Test Todo", todos[0].title)
        assertEquals("", todos[0].description)
    }

    @Test
    fun testAddMultipleTodos() = runBlocking {
        viewModel.addTodo("Todo 1")
        viewModel.addTodo("Todo 2")
        viewModel.addTodo("Todo 3")
        val todos = viewModel.todos.first()
        
        assertEquals(3, todos.size)
    }

    @Test
    fun testAddBlankTodoIsIgnored() = runBlocking {
        viewModel.addTodo("")
        val todos = viewModel.todos.first()
        
        assertTrue(todos.isEmpty())
    }

    @Test
    fun testToggleTodo() = runBlocking {
        viewModel.addTodo("Test Todo")
        val todoId = viewModel.todos.first()[0].id
        
        viewModel.toggleTodo(todoId)
        val todos = viewModel.todos.first()
        
        assertEquals(true, todos[0].completed)
    }

    @Test
    fun testToggleTodoMultipleTimes() = runBlocking {
        viewModel.addTodo("Test Todo")
        val todoId = viewModel.todos.first()[0].id
        
        viewModel.toggleTodo(todoId)
        viewModel.toggleTodo(todoId)
        val todos = viewModel.todos.first()
        
        assertEquals(false, todos[0].completed)
    }

    @Test
    fun testDeleteTodo() = runBlocking {
        viewModel.addTodo("Todo 1")
        viewModel.addTodo("Todo 2")
        val todoId = viewModel.todos.first()[0].id
        
        viewModel.deleteTodo(todoId)
        val todos = viewModel.todos.first()
        
        assertEquals(1, todos.size)
        assertEquals("Todo 2", todos[0].title)
    }

    @Test
    fun testUpdateTodo() = runBlocking {
        viewModel.addTodo("Old Title", "Old Description")
        val todoId = viewModel.todos.first()[0].id
        
        viewModel.updateTodo(todoId, "New Title", "New Description")
        val todos = viewModel.todos.first()
        
        assertEquals("New Title", todos[0].title)
        assertEquals("New Description", todos[0].description)
    }

    @Test
    fun testComplexScenario() = runBlocking {
        // Add todos
        viewModel.addTodo("Buy groceries")
        Thread.sleep(2) // Pequeña pausa para evitar IDs duplicados
        viewModel.addTodo("Complete project")
        Thread.sleep(2)
        viewModel.addTodo("Call mom")
        
        var todos = viewModel.todos.first()
        assertEquals(3, todos.size)
        
        // Toggle first todo
        val firstTodoId = todos[0].id
        viewModel.toggleTodo(firstTodoId)
        todos = viewModel.todos.first()
        assertEquals(true, todos[0].completed)
        
        // Delete second todo
        val secondTodoId = todos[1].id
        viewModel.deleteTodo(secondTodoId)
        todos = viewModel.todos.first()
        assertEquals(2, todos.size)
        
        // Update remaining todo
        viewModel.updateTodo(todos[0].id, "Buy groceries - DONE", "All items")
        todos = viewModel.todos.first()
        assertEquals("Buy groceries - DONE", todos[0].title)
    }
}
