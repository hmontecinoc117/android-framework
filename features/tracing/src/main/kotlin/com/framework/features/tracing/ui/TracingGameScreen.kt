package com.framework.features.tracing.ui.legacy

import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.BasicText
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.IntRect
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.toSize
import androidx.compose.ui.zIndex
import androidx.compose.foundation.Canvas
import androidx.compose.ui.Alignment
import androidx.compose.ui.layout.boundsInWindow
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

@Composable
fun TracingGameScreenLegacy(
    words: List<String> = listOf("gato", "perro", "elefante", "tigre", "caballo", "vaca", "oveja"),
    tracedColor: Color = Color(0xFF4CAF50),
    defaultColor: Color = Color.Black,
    strokeColor: Color = Color(0xFF2196F3)
) {
    var index by remember { mutableStateOf(0) }
    val word = words.getOrNull(index) ?: words.first()

    // Track bounds for each letter
    val letterBounds = remember { mutableStateListOf<IntRect>() }
    val traced = remember { mutableStateListOf<Boolean>() }
    LaunchedEffect(word) {
        letterBounds.clear()
        traced.clear()
        for (i in word.indices) traced.add(false)
    }

    // strokes for visual feedback
    val strokes = remember { mutableStateListOf<Path>() }
    var currentPath by remember { mutableStateOf<Path?>(null) }

    Box(modifier = Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        Column(modifier = Modifier
            .fillMaxSize()
            .padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally) {

            BasicText(text = "Traza las letras:", style = androidx.compose.ui.text.TextStyle(fontSize = 20.sp, fontWeight = FontWeight.Bold))
            Spacer(modifier = Modifier.height(16.dp))

            // Row of letters with known positions
            Row(modifier = Modifier.wrapContentWidth().height(IntrinsicSize.Min)) {
                word.forEachIndexed { i, ch ->
                    Box(modifier = Modifier
                        .padding(6.dp)
                        .onGloballyPositioned { coords ->
                            val pos = coords.boundsInWindow()
                            val size = coords.size
                            val rect = IntRect(pos.left.toInt(), pos.top.toInt(), pos.right.toInt(), pos.bottom.toInt())
                            if (letterBounds.size > i) letterBounds[i] = rect else letterBounds.add(rect)
                        }
                    ) {
                        val color = if (i < traced.size && traced[i]) tracedColor else defaultColor
                        BasicText(text = ch.toString(), style = androidx.compose.ui.text.TextStyle(color = color, fontSize = 48.sp, fontWeight = FontWeight.Bold))
                    }
                }
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
                        checkTouch(offset, letterBounds, traced)
                    },
                    onDrag = { change, dragAmount ->
                        change.consume()
                        val pos = change.position
                        currentPath?.lineTo(pos.x, pos.y)
                        checkTouch(pos, letterBounds, traced)
                    },
                    onDragEnd = {
                        currentPath = null
                        // check completion
                        if (traced.all { it }) {
                            // advance level
                            index = (index + 1) % words.size
                        }
                    }
                )
            }
        ) {
            Canvas(modifier = Modifier.matchParentSize()) {
                strokes.forEach { path ->
                    drawPath(path = path, color = strokeColor, style = Stroke(width = 18f, cap = androidx.compose.ui.graphics.StrokeCap.Round))
                }
            }
        }
    }
}

private fun checkTouch(pos: Offset, letterBounds: List<IntRect>, traced: MutableList<Boolean>) {
    val point = androidx.compose.ui.unit.IntOffset(pos.x.toInt(), pos.y.toInt())
    for (i in letterBounds.indices) {
        val r = letterBounds[i]
        if (r.contains(point)) {
            if (i < traced.size) traced[i] = true
        }
    }
}
