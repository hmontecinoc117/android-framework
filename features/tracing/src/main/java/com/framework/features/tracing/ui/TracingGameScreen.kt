package com.framework.features.tracing.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.BasicText
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalContext
import android.app.Activity
import android.media.ToneGenerator
import android.media.AudioManager
import androidx.compose.ui.unit.IntRect
import androidx.compose.ui.platform.LocalDensity
import android.graphics.Paint
import android.graphics.Path as AndroidPath
import android.graphics.Region
import android.graphics.RectF
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.toSize
import androidx.compose.ui.zIndex
import androidx.compose.foundation.Canvas
import androidx.compose.ui.Alignment
import androidx.compose.ui.layout.boundsInWindow
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.foundation.gestures.detectDragGestures
// No import drawPath needed; use drawPath inside Canvas draw scope

import androidx.compose.animation.core.Animatable
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.animation.core.tween
import kotlinx.coroutines.launch
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.IntSize
@Composable
fun TracingGameScreen(
    words: List<String> = listOf("gato", "perro", "elefante", "tigre", "caballo", "vaca", "oveja"),
    tracedColor: Color = Color(0xFF4CAF50),
    defaultColor: Color = Color.Black,
    strokeColor: Color = Color(0xFF2196F3)
) {
    var index by remember { mutableStateOf(0) }
    val word = words.getOrNull(index) ?: words.first()

    // Usaremos Text + TextLayoutResult para mostrar la palabra centrada en mayúsculas
    val displayWord = word.uppercase()
    val traced = remember { mutableStateListOf<Boolean>() }
    LaunchedEffect(displayWord) {
        traced.clear()
        for (i in displayWord.indices) traced.add(false)
    }

    // strokes para feedback visual
    val strokes = remember { mutableStateListOf<Path>() }
    var currentPath by remember { mutableStateOf<Path?>(null) }
    var currentPoints by remember { mutableStateOf(mutableListOf<Offset>()) }
    var textLayoutResult by remember { mutableStateOf<androidx.compose.ui.text.TextLayoutResult?>(null) }
    var textPosition by remember { mutableStateOf(Offset.Zero) }
    val density = LocalDensity.current
    val charTextSizePx = with(density) { 192.sp.toPx() }
    val touchPaddingPx = with(density) { 24.dp.toPx() }

    // glyph paths (android.graphics.Path) para detección más precisa (inicialmente vacías)
    val glyphPaths = remember { mutableStateListOf<AndroidPath>() }

    val toneGenerator = remember { ToneGenerator(AudioManager.STREAM_MUSIC, 100) }
    DisposableEffect(Unit) { onDispose { toneGenerator.release() } }

    Box(modifier = Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        Column(modifier = Modifier
            .fillMaxSize()
            .padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally) {

            BasicText(text = "Traza las letras:", style = androidx.compose.ui.text.TextStyle(fontSize = 20.sp, fontWeight = FontWeight.Bold))
            Spacer(modifier = Modifier.height(16.dp))

            // Texto grande centrado (GRIS). Las letras se renderizarán en MAYÚSCULAS.
            Box(modifier = Modifier.fillMaxWidth().height(300.dp), contentAlignment = Alignment.Center) {
                // Construir AnnotatedString para colorear letras marcadas
                val annotated = androidx.compose.ui.text.buildAnnotatedString {
                    for (i in displayWord.indices) {
                        val ch = displayWord[i].toString()
                        if (traced.getOrNull(i) == true) {
                            withStyle(style = androidx.compose.ui.text.SpanStyle(color = Color.Blue, fontSize = 192.sp, fontWeight = FontWeight.Bold)) {
                                append(ch)
                            }
                        } else {
                            withStyle(style = androidx.compose.ui.text.SpanStyle(color = Color.Gray, fontSize = 192.sp, fontWeight = FontWeight.Bold)) {
                                append(ch)
                            }
                        }
                    }
                }

                Text(
                    text = annotated,
                    textAlign = TextAlign.Center,
                    modifier = Modifier
                        .onGloballyPositioned { coords ->
                            val pos = coords.boundsInWindow()
                            textPosition = Offset(pos.left.toFloat(), pos.top.toFloat())
                        },
                    onTextLayout = { result ->
                        textLayoutResult = result
                        // construir rutas de glifo para cada carácter
                        glyphPaths.clear()
                        val paint = Paint().apply { isAntiAlias = true; textSize = charTextSizePx }
                        for (i in displayWord.indices) {
                            val box = try { result.getBoundingBox(i) } catch (e: Exception) { null }
                            val p = AndroidPath()
                            try {
                                if (box != null) {
                                    val x = textPosition.x + box.left
                                    val y = textPosition.y + box.bottom
                                    paint.getTextPath(displayWord, i, i + 1, x, y, p)
                                } else {
                                    // fallback: dibujar el carácter en 0,0
                                    paint.getTextPath(displayWord, i, i + 1, 0f, charTextSizePx, p)
                                }
                            } catch (_: Exception) {}
                            glyphPaths.add(p)
                        }
                    }
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            Button(onClick = {
                // reset
                for (i in traced.indices) traced[i] = false
                strokes.clear()
            }) {
                BasicText("Reiniciar")
            }

            Spacer(modifier = Modifier.weight(1f))

            // Next level button for testing
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center) {
                Button(onClick = {
                    index = (index + 1) % words.size
                    strokes.clear()
                }) {
                    BasicText("Siguiente palabra")
                }
            }
            // Controls: Reiniciar y Siguiente
            Row(modifier = Modifier.fillMaxWidth().padding(8.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                Button(onClick = {
                    // reiniciar trazos y estado
                    strokes.clear()
                    for (i in traced.indices) traced[i] = false
                }) {
                    Text("🔄 Reiniciar")
                }

                Button(onClick = {
                    // siguiente palabra manual
                    index = (index + 1) % words.size
                    strokes.clear()
                    for (i in traced.indices) traced[i] = false
                }) {
                    Text("Siguiente palabra")
                }
            }

            // Confetti simple: cuando todas las letras están marcadas, mostramos partículas efímeras
            if (traced.all { it }) {
                ConfettiOverlay()
            }
        }

        // Top controls: volver, limpiar, siguiente (z-index alto)
        val _ctx = LocalContext.current
        Row(modifier = Modifier.fillMaxWidth().padding(8.dp).zIndex(10f), horizontalArrangement = Arrangement.SpaceBetween) {
            Button(onClick = { (_ctx as? Activity)?.finish() }) {
                Text("←")
            }

            Row {
                Button(onClick = {
                    strokes.clear()
                }) {
                    Text("⤺")
                }
                Spacer(modifier = Modifier.width(8.dp))
                Button(onClick = {
                    index = (index + 1) % words.size
                    strokes.clear()
                    for (i in traced.indices) traced[i] = false
                }) {
                    Text("→")
                }
            }
        }

        // Drawing overlay
        Box(modifier = Modifier
            .matchParentSize()
            .zIndex(5f)
            .pointerInput(Unit) {
                detectDragGestures(
                    onDragStart = { offset ->
                        val p = Path().apply { moveTo(offset.x, offset.y) }
                        currentPath = p
                        strokes.add(p)
                        currentPoints = mutableListOf(offset)
                        // detectar intersecciones usando textLayoutResult
                        val layout = textLayoutResult
                        if (layout != null) {
                            // primero intentamos detección por path si está disponible (con padding para ser menos estricto)
                            if (glyphPaths.isNotEmpty()) {
                                val px = offset.x.toInt()
                                val py = offset.y.toInt()
                                for (i in glyphPaths.indices) {
                                    try {
                                        val g = glyphPaths[i]
                                        val r = RectF()
                                        g.computeBounds(r, true)
                                        r.inset(-touchPaddingPx, -touchPaddingPx)
                                        val region = Region()
                                        region.setPath(g, Region(r.left.toInt(), r.top.toInt(), r.right.toInt(), r.bottom.toInt()))
                                        if (region.contains(px, py)) {
                                            if (i < traced.size) traced[i] = true
                                        } else {
                                            if (px >= r.left && px <= r.right && py >= r.top && py <= r.bottom) {
                                                if (i < traced.size) traced[i] = true
                                            }
                                        }
                                    } catch (_: Exception) {}
                                }
                            } else {
                                for (i in displayWord.indices) {
                                    val box = try { layout.getBoundingBox(i) } catch (e: Exception) { null }
                                    if (box != null) {
                                        val left = box.left + textPosition.x - touchPaddingPx
                                        val top = box.top + textPosition.y - touchPaddingPx
                                        val right = box.right + textPosition.x + touchPaddingPx
                                        val bottom = box.bottom + textPosition.y + touchPaddingPx
                                        if (offset.x >= left && offset.x <= right && offset.y >= top && offset.y <= bottom) {
                                            if (i < traced.size) traced[i] = true
                                        }
                                    }
                                }
                            }
                        }
                    },
                    onDrag = { change, _ ->
                        change.consume()
                        val pos = change.position
                        currentPath?.lineTo(pos.x, pos.y)
                        currentPoints.add(pos)
                        val layout = textLayoutResult
                        if (layout != null) {
                            // menos estricto: si alguno de los puntos toca la caja, marcamos
                            if (glyphPaths.isNotEmpty()) {
                                val px = pos.x.toInt()
                                val py = pos.y.toInt()
                                for (i in glyphPaths.indices) {
                                    if (traced.getOrNull(i) != true) {
                                        try {
                                            val g = glyphPaths[i]
                                            val r = RectF()
                                            g.computeBounds(r, true)
                                            r.inset(-touchPaddingPx, -touchPaddingPx)
                                            val region = Region()
                                            region.setPath(g, Region(r.left.toInt(), r.top.toInt(), r.right.toInt(), r.bottom.toInt()))
                                            if (region.contains(px, py)) {
                                                if (i < traced.size) traced[i] = true
                                            } else {
                                                if (px >= r.left && px <= r.right && py >= r.top && py <= r.bottom) {
                                                    if (i < traced.size) traced[i] = true
                                                }
                                            }
                                        } catch (_: Exception) {}
                                    }
                                }
                            } else {
                                for (i in displayWord.indices) {
                                    if (traced.getOrNull(i) != true) {
                                        val box = try { layout.getBoundingBox(i) } catch (e: Exception) { null }
                                        if (box != null) {
                                            val left = box.left + textPosition.x - touchPaddingPx
                                            val top = box.top + textPosition.y - touchPaddingPx
                                            val right = box.right + textPosition.x + touchPaddingPx
                                            val bottom = box.bottom + textPosition.y + touchPaddingPx
                                            for (pt in listOf(pos)) {
                                                if (pt.x >= left && pt.x <= right && pt.y >= top && pt.y <= bottom) {
                                                    if (i < traced.size) traced[i] = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    },
                    onDragEnd = {
                        currentPath = null
                        // no avanzamos aquí; manejamos el avance al reproducir el sonido
                    }
                )
            }
        ) {
            Canvas(modifier = Modifier.matchParentSize()) {
                // dibujar trazos persistentes
                for (p in strokes) drawPath(p, color = strokeColor, style = Stroke(width = 36f, cap = androidx.compose.ui.graphics.StrokeCap.Round))
                // opcional: dibujar overlay de letras marcadas en azul sobre el texto
            }
        }
    }

    // Reproducir sonido y avanzar cuando la palabra se complete
    LaunchedEffect(traced.toList()) {
        if (traced.all { it }) {
            toneGenerator.startTone(ToneGenerator.TONE_PROP_ACK, 450)
            kotlinx.coroutines.delay(500)
            index = (index + 1) % words.size
            strokes.clear()
        }
    }
}

private fun checkTouch(pos: Offset, letterBounds: List<IntRect>, traced: MutableList<Boolean>) {
    val point = IntOffset(pos.x.toInt(), pos.y.toInt())
    for (i in letterBounds.indices) {
        val r = letterBounds[i]
        if (r.contains(point)) {
            if (i < traced.size) traced[i] = true
        }
    }
}

@Composable
private fun ConfettiOverlay() {
    val colors = listOf(Color.Red, Color.Green, Color.Yellow, Color.Cyan, Color.Magenta)
    val particleCount = 12
    val anims = remember { List(particleCount) { Animatable(0f) } }
    LaunchedEffect(Unit) {
        anims.forEachIndexed { i, a ->
            launch {
                a.animateTo(1f, animationSpec = tween(durationMillis = 700 + (i * 30)))
            }
        }
    }

    Box(modifier = Modifier.fillMaxSize()) {
        for (i in 0 until particleCount) {
            val xFrac = (i + 1) / (particleCount + 1).toFloat()
            val y = anims[i].value
            Box(
                modifier = Modifier
                    .offset(x = (xFrac * 300).dp, y = (y * 300).dp)
                    .size(10.dp)
                    .background(color = colors[i % colors.size], shape = CircleShape)
            ) {}
        }
    }
}

