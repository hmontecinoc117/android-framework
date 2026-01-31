package com.framework.features.basic.counter

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun CounterScreen(viewModel: CounterViewModel = CounterViewModel()) {
    val count by viewModel.count.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "Contador",
            style = MaterialTheme.typography.headlineLarge
        )

        Spacer(modifier = Modifier.height(32.dp))

        Text(
            text = count.toString(),
            style = MaterialTheme.typography.displayLarge,
            color = MaterialTheme.colorScheme.primary
        )

        Spacer(modifier = Modifier.height(48.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Button(
                onClick = { viewModel.decrement() },
                modifier = Modifier
                    .width(100.dp)
                    .height(50.dp)
            ) {
                Text("- Menos")
            }

            Spacer(modifier = Modifier.width(16.dp))

            Button(
                onClick = { viewModel.reset() },
                modifier = Modifier
                    .width(100.dp)
                    .height(50.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.secondary
                )
            ) {
                Text("Reset")
            }

            Spacer(modifier = Modifier.width(16.dp))

            Button(
                onClick = { viewModel.increment() },
                modifier = Modifier
                    .width(100.dp)
                    .height(50.dp)
            ) {
                Text("+ Más")
            }
        }
    }
}
