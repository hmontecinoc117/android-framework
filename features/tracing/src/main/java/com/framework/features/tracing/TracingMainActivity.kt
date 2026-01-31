package com.framework.features.tracing

/** Activity que lanza la pantalla de trazado. */
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import com.framework.features.tracing.ui.TracingGameScreen
class TracingMainActivity : ComponentActivity() {

    // Implementación simplificada: la lógica está en el Composable para esta versión de prueba.

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Opcionales: recibir extras y pasarlas al Composable
        val words = intent?.getStringArrayListExtra("words")

        setContent {
            MaterialTheme {
                Surface(modifier = androidx.compose.ui.Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
                    if (words != null) {
                        TracingGameScreen(words = words)
                    } else {
                        TracingGameScreen()
                    }
                }
            }
        }
    }
}

