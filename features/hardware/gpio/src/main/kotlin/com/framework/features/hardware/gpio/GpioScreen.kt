package com.framework.features.hardware.gpio

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

data class LedControl(val name: String, val pin: String)

@Composable
fun GpioScreen(viewModel: GpioViewModel = GpioViewModel()) {
    val gpioStates by viewModel.getGpioStates().collectAsState()

    val leds = listOf(
        LedControl("LED Rojo", "GPIO17"),
        LedControl("LED Verde", "GPIO27"),
        LedControl("LED Azul", "GPIO22"),
        LedControl("LED Amarillo", "GPIO23")
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text(
            text = "GPIO - Control de LEDs (Raspberry Pi)",
            style = MaterialTheme.typography.headlineLarge
        )

        Spacer(modifier = Modifier.height(16.dp))

        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp)
        ) {
            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Text(
                    text = "LEDs conectados: ${leds.size}",
                    style = MaterialTheme.typography.titleMedium
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Activos: ${gpioStates.values.count { it }}",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.primary
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        LazyColumn {
            items(leds) { led ->
                val isOn = gpioStates[led.pin] ?: false
                LedControlCard(
                    led = led,
                    isOn = isOn,
                    onToggle = { viewModel.toggleLed(led.pin) }
                )
                Spacer(modifier = Modifier.height(8.dp))
            }
        }
    }
}

@Composable
fun LedControlCard(
    led: LedControl,
    isOn: Boolean,
    onToggle: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // LED Indicator
            Box(
                modifier = Modifier
                    .size(24.dp)
                    .clip(CircleShape)
                    .background(
                        color = if (isOn) Color(0xFFFFD700) else Color.Gray
                    )
            )

            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(start = 16.dp)
            ) {
                Text(
                    text = led.name,
                    style = MaterialTheme.typography.titleMedium
                )
                Text(
                    text = led.pin,
                    style = MaterialTheme.typography.bodySmall
                )
            }

            Switch(
                checked = isOn,
                onCheckedChange = { onToggle() }
            )
        }
    }
}
