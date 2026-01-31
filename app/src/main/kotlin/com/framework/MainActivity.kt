package com.framework

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.framework.ui.theme.AndroidFrameworkTheme
import kotlinx.coroutines.delay

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        setContent {
            AndroidFrameworkTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    MainScreen(
                        onLaunchGame = { launchGodotGame() }
                    )
                }
            }
        }
    }
    
    private fun launchGodotGame() {
        try {
            val intent = Intent(this, GodotGameActivity::class.java)
            startActivity(intent)
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error al iniciar Godot: ${e.message}", e)
        }
    }
}

@Composable
fun MainScreen(onLaunchGame: () -> Unit) {
    val context = LocalContext.current
    var heroBitmap by remember { mutableStateOf<androidx.compose.ui.graphics.ImageBitmap?>(null) }
    var heroResId by remember { mutableStateOf<Int?>(null) }

    // Intentar cargar imagen desde recursos: app/src/main/res/drawable/front_horizontal.(png|jpg|webp)
    LaunchedEffect(Unit) {
        val resName = "front_horizontal"
        val id = context.resources.getIdentifier(resName, "drawable", context.packageName)
        heroResId = if (id != 0) id else null
        if (heroResId == null) {
            // Fallback: intentar cargar desde assets si no existe el recurso
            try {
                context.assets.open("splash_hero.jpg").use { input ->
                    val bmp = android.graphics.BitmapFactory.decodeStream(input)
                    heroBitmap = bmp?.asImageBitmap()
                }
            } catch (_: Exception) {
                heroBitmap = null
            }
        }
    }

    // Auto-inicio tras 10s
    LaunchedEffect(Unit) {
        delay(10_000)
        onLaunchGame()
    }

    Box(modifier = Modifier.fillMaxSize().background(Color.Black)) {
        // Solo la imagen a pantalla completa, sin textos ni overlay
        when {
            heroResId != null -> {
                Image(
                    painter = painterResource(id = heroResId!!),
                    contentDescription = null,
                    contentScale = ContentScale.Fit,
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(16.dp)
                )
            }
            heroBitmap != null -> {
                val img = heroBitmap!!
                Image(
                    bitmap = img,
                    contentDescription = null,
                    contentScale = ContentScale.Fit,
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(16.dp)
                )
            }
        }
    }
}
