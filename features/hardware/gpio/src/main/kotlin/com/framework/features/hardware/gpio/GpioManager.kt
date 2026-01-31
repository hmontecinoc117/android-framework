package com.framework.features.hardware.gpio

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * GPIO Manager para Raspberry Pi usando Android Things
 * Permite controlar LEDs, botones, sensores, etc.
 */
class GpioManager {
    private val _gpioStates = MutableStateFlow<Map<String, Boolean>>(emptyMap())
    val gpioStates: StateFlow<Map<String, Boolean>> = _gpioStates.asStateFlow()

    fun setGpioPinState(pinName: String, state: Boolean) {
        _gpioStates.value = _gpioStates.value.toMutableMap().apply {
            put(pinName, state)
        }
    }

    fun getGpioPinState(pinName: String): Boolean {
        return _gpioStates.value[pinName] ?: false
    }

    fun toggleGpio(pinName: String) {
        val currentState = getGpioPinState(pinName)
        setGpioPinState(pinName, !currentState)
    }
}

class GpioViewModel : ViewModel() {
    private val gpioManager = GpioManager()

    fun toggleLed(ledName: String) {
        gpioManager.toggleGpio(ledName)
    }

    fun setLedState(ledName: String, state: Boolean) {
        gpioManager.setGpioPinState(ledName, state)
    }

    fun getGpioStates(): StateFlow<Map<String, Boolean>> = gpioManager.gpioStates
}
