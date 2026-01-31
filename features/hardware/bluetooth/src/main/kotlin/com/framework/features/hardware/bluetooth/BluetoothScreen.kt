package com.framework.features.hardware.bluetooth

import android.bluetooth.BluetoothDevice
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun BluetoothScreen(viewModel: BluetoothViewModel = BluetoothViewModel()) {
    val devices by viewModel.devices.collectAsState()
    val isDiscovering by viewModel.isDiscovering.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text(
            text = "Bluetooth - Dispositivos",
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
                Button(
                    onClick = { viewModel.setDiscovering(!isDiscovering) },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(if (isDiscovering) "Detener búsqueda" else "Buscar dispositivos")
                }

                if (isDiscovering) {
                    Spacer(modifier = Modifier.height(8.dp))
                    Box(
                        modifier = Modifier.fillMaxWidth(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator()
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Text(
            text = "Dispositivos encontrados: ${devices.size}",
            style = MaterialTheme.typography.titleMedium
        )

        Spacer(modifier = Modifier.height(8.dp))

        LazyColumn {
            items(devices) { device ->
                BluetoothDeviceCard(device)
                Spacer(modifier = Modifier.height(8.dp))
            }
        }
    }
}

@Composable
fun BluetoothDeviceCard(device: BluetoothDevice) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                text = device.name ?: "Dispositivo desconocido",
                style = MaterialTheme.typography.titleMedium
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = device.address,
                style = MaterialTheme.typography.bodySmall
            )
        }
    }
}
