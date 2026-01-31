package com.framework.features.godot

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp

/**
 * Pantalla de ejemplo para demostrar cómo lanzar juegos de Godot
 */
@Composable
fun GodotGamesScreen(
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(12.dp, Alignment.CenterVertically)
    ) {
        Text(
            text = "Juegos GustaNuno",
            style = androidx.compose.material3.MaterialTheme.typography.headlineMedium
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        Button(
            onClick = { GodotLauncher.launchMenu(context) },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Menú Principal")
        }
        
        Button(
            onClick = { GodotLauncher.launchTraceWords(context) },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Trazar Palabras")
        }
        
        Button(
            onClick = { GodotLauncher.launchTraceShapes(context) },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Trazar Figuras")
        }
        
        Button(
            onClick = { GodotLauncher.launchPuzzle(context) },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Rompecabezas")
        }
        
        Button(
            onClick = { GodotLauncher.launchMemory(context) },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Juego de Memoria")
        }
    }
}
