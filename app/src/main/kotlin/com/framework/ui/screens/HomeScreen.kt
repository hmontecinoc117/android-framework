package com.framework.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.ui.platform.LocalContext
import androidx.compose.foundation.background
import android.content.Intent
import com.framework.features.tracing.TracingMainActivity
import androidx.compose.ui.Alignment
import androidx.compose.ui.graphics.Color
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Edit
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Top
    ) {
        Spacer(modifier = Modifier.height(32.dp))

        Text(
            text = "Juegos GustaNuno",
            style = MaterialTheme.typography.headlineLarge
        )

        Spacer(modifier = Modifier.height(48.dp))

        val ctx = LocalContext.current

        // Cuadros de juegos (4)
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            // Juego 1: Trazar
            Card(modifier = Modifier.weight(1f).padding(4.dp).height(140.dp), onClick = {
                val intent = Intent(ctx, TracingMainActivity::class.java)
                intent.putStringArrayListExtra("words", arrayListOf("LEON","PERRO","GATO","VACA","OVEJA","RANA","PEZ","BURRO","LOBO","OSO"))
                ctx.startActivity(intent)
            }) {
                Column(modifier = Modifier.fillMaxSize().padding(8.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
                    Box(modifier = Modifier.size(48.dp).background(MaterialTheme.colorScheme.primary, shape = MaterialTheme.shapes.small), contentAlignment = Alignment.Center) {
                        Icon(imageVector = Icons.Filled.Edit, contentDescription = "Trazar", tint = Color.White)
                    }
                    Spacer(Modifier.height(8.dp))
                    Text("Trazar")
                }
            }

            // Juego 2: Placeholder
            Card(modifier = Modifier.weight(1f).padding(4.dp).height(140.dp)) {
                Column(modifier = Modifier.fillMaxSize().padding(8.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
                    Box(modifier = Modifier.size(48.dp).background(MaterialTheme.colorScheme.secondary, shape = MaterialTheme.shapes.small), contentAlignment = Alignment.Center) {
                        Text("🎯")
                    }
                    Spacer(Modifier.height(8.dp))
                    Text("Juego 2")
                }
            }

            // Juego 3: Placeholder
            Card(modifier = Modifier.weight(1f).padding(4.dp).height(140.dp)) {
                Column(modifier = Modifier.fillMaxSize().padding(8.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
                    Box(modifier = Modifier.size(48.dp).background(MaterialTheme.colorScheme.tertiary, shape = MaterialTheme.shapes.small), contentAlignment = Alignment.Center) {
                        Text("🎲")
                    }
                    Spacer(Modifier.height(8.dp))
                    Text("Juego 3")
                }
            }

            // Juego 4: Placeholder
            Card(modifier = Modifier.weight(1f).padding(4.dp).height(140.dp)) {
                Column(modifier = Modifier.fillMaxSize().padding(8.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
                    Box(modifier = Modifier.size(48.dp).background(MaterialTheme.colorScheme.error, shape = MaterialTheme.shapes.small), contentAlignment = Alignment.Center) {
                        Text("🔤")
                    }
                    Spacer(Modifier.height(8.dp))
                    Text("Juego 4")
                }
            }
        }

        Spacer(modifier = Modifier.height(24.dp))
    }
}
