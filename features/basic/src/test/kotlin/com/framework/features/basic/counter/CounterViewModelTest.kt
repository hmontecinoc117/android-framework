package com.framework.features.basic.counter

import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test

class CounterViewModelTest {
    
    private lateinit var viewModel: CounterViewModel

    @Before
    fun setUp() {
        viewModel = CounterViewModel()
    }

    @Test
    fun testInitialCount() = runBlocking {
        val count = viewModel.count.first()
        assertEquals(0, count)
    }

    @Test
    fun testIncrement() = runBlocking {
        viewModel.increment()
        val count = viewModel.count.first()
        assertEquals(1, count)
    }

    @Test
    fun testMultipleIncrements() = runBlocking {
        viewModel.increment()
        viewModel.increment()
        viewModel.increment()
        val count = viewModel.count.first()
        assertEquals(3, count)
    }

    @Test
    fun testDecrement() = runBlocking {
        viewModel.decrement()
        val count = viewModel.count.first()
        assertEquals(-1, count)
    }

    @Test
    fun testReset() = runBlocking {
        viewModel.increment()
        viewModel.increment()
        viewModel.reset()
        val count = viewModel.count.first()
        assertEquals(0, count)
    }

    @Test
    fun testIncrementAndDecrement() = runBlocking {
        viewModel.increment()
        viewModel.increment()
        viewModel.decrement()
        val count = viewModel.count.first()
        assertEquals(1, count)
    }
}
