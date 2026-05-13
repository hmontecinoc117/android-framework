# Feature: Voz a Tarea — Módulo Tareas Posit

## Contexto del proyecto

App Flutter `planhogar49`. Stack: Flutter + Riverpod + Hive + Firebase.
Plataformas objetivo: **Web (actual), Android e iOS (futuros)**.
El módulo afectado es **Tareas Posit** (`lib/features/tareas_posit/`).

Entidad principal a crear: `TaskPosit`, que ya existe con los campos:
`id`, `description`, `priority` (TaskPriority: baja/media/alta),
`dueDate`, `estimatedMinutes`, `eisenhowerQuadrant`, `isCompleted`, `createdAt`.

Provider para agregar tareas: `addTaskProvider` en
`lib/presentation/providers/task_posit_provider.dart`.

Pantalla a modificar: `TareasPositScreen` en
`lib/features/tareas_posit/presentation/screens/tareas_posit_screen.dart`.
Esta pantalla ya tiene un botón "Nueva tarea" que llama `_showAddTaskDialog()`.

---

## Objetivo

Agregar un botón de micrófono junto al botón "Nueva tarea" existente.
Al pulsarlo, abre un **bottom sheet** que permite:
1. Grabar audio con el micrófono
2. Transcribir en tiempo real el habla a texto
3. Mostrar el texto transcrito en un campo editable
4. Confirmar y crear la tarea en `addTaskProvider`

El flujo **no reemplaza** el botón "Nueva tarea" existente. Se agrega como opción adicional.

---

## Implementación requerida

### 1. Dependencia — `pubspec.yaml`

Agrega únicamente:

```yaml
speech_to_text: ^7.0.0
```

> Este paquete soporta Web (Web Speech API), Android e iOS con la misma API,
> sin necesidad de stubs adicionales.

---

### 2. Permisos de plataforma

#### Android — `android/app/src/main/AndroidManifest.xml`

Agrega dentro de `<manifest>`, antes de `<application>`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

#### iOS — `ios/Runner/Info.plist`

Agrega dentro de `<dict>`:

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>Plan Hogar necesita reconocimiento de voz para crear tareas dictadas.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Plan Hogar necesita el micrófono para grabar tareas por voz.</string>
```

#### Web — `web/index.html`

No requiere cambios. El navegador solicita el permiso de micrófono automáticamente
al primer uso de la Web Speech API.

---

### 3. Widget nuevo — `VoiceTaskBottomSheet`

Crea el archivo:
`lib/features/tareas_posit/presentation/widgets/voice_task_bottom_sheet.dart`

**Especificaciones del widget:**

```dart
// Widget: VoiceTaskBottomSheet
// Es un StatefulWidget (no ConsumerWidget; recibe un callback onTaskConfirmed)

// Parámetros:
//   final void Function(String description) onTaskConfirmed;

// Estado interno:
//   SpeechToText _speech         — instancia del paquete
//   bool _isListening            — indica si está escuchando
//   bool _isInitialized          — indica si el paquete se inicializó
//   String _transcribedText      — texto reconocido acumulado
//   TextEditingController _controller — para que el usuario edite el texto

// Comportamiento:
//   - Al abrirse, inicializa _speech con _speech.initialize()
//   - Si no se puede inicializar (navegador sin soporte, permiso denegado),
//     muestra un Text de error descriptivo en lugar de los controles
//   - Botón micrófono: alterna entre escuchar y detener
//     · Al iniciar: llama _speech.listen(onResult: ..., localeId: 'es_CL')
//       El onResult actualiza _transcribedText y _controller.text con
//       result.recognizedWords (texto parcial/final acumulado)
//     · Al detener: llama _speech.stop()
//   - Mientras escucha: muestra un indicador visual animado (pulsante)
//     usando AnimatedContainer o similar; color naranja (Color(0xFFFF9800))
//     que es el color del módulo Tareas
//   - El TextField con _controller permite editar manualmente el texto
//     antes de confirmar
//   - Botón "Agregar tarea": habilitado solo si _controller.text.trim() no está vacío
//     Al presionar: llama onTaskConfirmed(_controller.text.trim()) y cierra el sheet
//   - Botón "Cancelar": cierra el sheet sin hacer nada
//   - En dispose(): llama _speech.stop() si está escuchando y _controller.dispose()
```

**UI del bottom sheet (estructura visual):**

```
┌─────────────────────────────────────┐
│  🎤  Crear tarea por voz            │  ← Título
│                                     │
│   [Indicador pulsante mientras      │
│    escucha, estático si no]         │
│                                     │
│   ┌─────────────────────────────┐   │
│   │ Texto transcrito / editable │   │  ← TextField multilínea
│   └─────────────────────────────┘   │
│                                     │
│   [  🎤 Hablar  ] o [ ⏹ Detener ]  │  ← Botón central grande
│                                     │
│   [Cancelar]       [Agregar tarea]  │  ← Fila inferior
└─────────────────────────────────────┘
```

Usa `showModalBottomSheet` con `isScrollControlled: true` y
`shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20)))`.

---

### 4. Modificación — `TareasPositScreen`

Archivo: `lib/features/tareas_posit/presentation/screens/tareas_posit_screen.dart`

**Cambio 1 — Import:**
Agrega el import de `voice_task_bottom_sheet.dart` y `speech_to_text`.

**Cambio 2 — Nuevo método `_showVoiceTaskSheet()`:**

```dart
void _showVoiceTaskSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => VoiceTaskBottomSheet(
      onTaskConfirmed: (description) {
        const houseId = 'default_house';
        ref.read(addTaskProvider((
          houseId,
          description,
          TaskPriority.media,   // prioridad por defecto
          null,                 // sin fecha límite
          null,                 // sin estimado de tiempo
          null,                 // cuadrante auto-sugerido
        )));
      },
    ),
  );
}
```

**Cambio 3 — Barra de herramientas:**

En la sección donde se renderiza el botón `ElevatedButton.icon` de "Nueva tarea",
agrega un `IconButton` de micrófono **a la izquierda** del botón existente:

```dart
// Antes del botón "Nueva tarea":
IconButton(
  tooltip: 'Crear tarea por voz',
  icon: const Icon(Icons.mic, color: Color(0xFFFF9800)),
  onPressed: _showVoiceTaskSheet,
),
const SizedBox(width: 8),
// ... botón "Nueva tarea" existente sin modificar
```

---

## Restricciones importantes

- **No modificar** `_showAddTaskDialog()` ni el botón "Nueva tarea" existente.
- **No modificar** `addTaskProvider`, `TaskPosit`, ni ningún provider o entidad existente.
- **No agregar** campos de prioridad, fecha o estimado de tiempo al bottom sheet.
  La tarea se crea con valores por defecto (`TaskPriority.media`, sin fecha, sin estimado).
- El paquete `speech_to_text` maneja internamente las diferencias entre
  Web / Android / iOS. **No crear stubs** adicionales.
- Si `speech_to_text` no puede inicializarse (Firefox, permiso denegado),
  el bottom sheet muestra un mensaje claro al usuario en lugar de fallar silenciosamente.

---

## Archivos a crear/modificar

| Acción   | Archivo |
|----------|---------|
| Modificar | `pubspec.yaml` |
| Modificar | `android/app/src/main/AndroidManifest.xml` |
| Modificar | `ios/Runner/Info.plist` |
| Crear     | `lib/features/tareas_posit/presentation/widgets/voice_task_bottom_sheet.dart` |
| Modificar | `lib/features/tareas_posit/presentation/screens/tareas_posit_screen.dart` |

No crear ni modificar ningún otro archivo.
