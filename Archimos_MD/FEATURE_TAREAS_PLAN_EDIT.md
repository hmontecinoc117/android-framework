# FEATURE BRIEF — Tareas: Enviar a Plan Hogar + Editar Tarea

## Contexto del proyecto

App Flutter **Plan Hogar** (`planhogar49`). Stack: Flutter + Riverpod + Hive + Firebase.

Módulo afectado: **Tareas PostIt** (color naranja `Colors.orange` / `#F97316`).
Módulo destino: **Plan Hogar** (color teal `#0D9488` / `Colors.teal`).

---

## Feature 1 — Enviar tarea al Plan Hogar

### Descripción
Desde el módulo Tareas, cada PostIt debe tener un botón **"Enviar a Plan Hogar"**. Al pulsarlo se despliega un bottom sheet flotante donde el usuario selecciona:
- **Día** de la semana (Lun–Dom, un solo día)
- **Cantidad de veces** (cuántas instancias se agregan ese día, rango 1–5)
- **Tiempo estimado** en minutos (pre-cargado desde `task.estimatedMinutes`, editable)

Al confirmar, se crean `N` instancias de `PlannedTask` en el día elegido dentro del `WeeklyPlan` activo.

---

### Archivos a modificar / crear

#### 1. `lib/presentation/providers/weekly_plan_provider.dart`

Agregar el siguiente método público a la clase `WeeklyPlanNotifier`:

```dart
/// Agrega una o más PlannedTask al día indicado, generadas desde un TaskPosit.
void addTaskFromPosit({
  required TaskPosit posit,
  required int dayIndex,
  required int times,
  required int estimatedMinutes,
}) {
  final current = state.plan;
  if (current == null) return;

  // Mapear prioridad del posit al weight de Task
  final weight = switch (posit.priority) {
    TaskPriority.alta  => 3,
    TaskPriority.media => 2,
    TaskPriority.baja  => 1,
  };

  // Truncar nombre si supera 60 caracteres
  final name = posit.description.length > 60
      ? '${posit.description.substring(0, 57)}...'
      : posit.description;

  final baseTask = Task(
    id: 'posit_${posit.id}',
    name: name,
    frequency: 1,
    weight: weight,
    estimatedMinutes: estimatedMinutes,
    category: TaskCategory.general,
    isCustom: true,
    priority: weight,
  );

  final day = current.days.firstWhere(
    (d) => d.dayIndex == dayIndex,
    orElse: () => DailyPlan(dayIndex: dayIndex, tasks: const []),
  );

  // Calcular sortOrder base (después de las tareas existentes)
  final baseSortOrder = (day.tasks.isEmpty ? 0 : day.tasks.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b)) + 10;

  final newTasks = List.generate(times, (i) {
    return PlannedTask(
      instanceId: const Uuid().v4(),
      task: baseTask,
      dayIndex: dayIndex,
      isCompleted: false,
      sortOrder: baseSortOrder + (i * 10),
    );
  });

  final updatedDays = current.days.map((d) {
    if (d.dayIndex == dayIndex) {
      return d.copyWith(tasks: [...d.tasks, ...newTasks]);
    }
    return d;
  }).toList();

  // Si el día no existía aún, agregarlo
  final dayExists = updatedDays.any((d) => d.dayIndex == dayIndex);
  final finalDays = dayExists
      ? updatedDays
      : [...updatedDays, DailyPlan(dayIndex: dayIndex, tasks: newTasks)];

  state = WeeklyPlanState(plan: current.copyWith(days: finalDays));
  _persist();
}
```

**Imports necesarios** (verificar que ya estén, agregar si faltan):
```dart
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_posit.dart';
```

---

#### 2. NUEVO archivo — `lib/features/tareas_posit/presentation/widgets/send_to_plan_bottom_sheet.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/task_posit.dart';
import '../../../../presentation/providers/weekly_plan_provider.dart';

/// Bottom sheet para enviar un TaskPosit al Plan Hogar.
/// Parámetros: [task] — la tarea origen, [houseId] — ID del hogar activo.
class SendToPlanBottomSheet extends ConsumerStatefulWidget {
  final TaskPosit task;

  const SendToPlanBottomSheet({Key? key, required this.task}) : super(key: key);

  static Future<bool> show(BuildContext context, TaskPosit task) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SendToPlanBottomSheet(task: task),
    );
    return result ?? false;
  }

  @override
  ConsumerState<SendToPlanBottomSheet> createState() =>
      _SendToPlanBottomSheetState();
}

class _SendToPlanBottomSheetState
    extends ConsumerState<SendToPlanBottomSheet> {
  // 0 = Lunes … 6 = Domingo
  int _selectedDay = DateTime.now().weekday - 1;
  int _times = 1;
  late TextEditingController _minutesController;

  static const _dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  void initState() {
    super.initState();
    _minutesController = TextEditingController(
      text: (widget.task.estimatedMinutes ?? 15).toString(),
    );
  }

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  void _confirm() {
    final minutes = int.tryParse(_minutesController.text) ?? 15;

    ref.read(weeklyPlanProvider.notifier).addTaskFromPosit(
          posit: widget.task,
          dayIndex: _selectedDay,
          times: _times,
          estimatedMinutes: minutes.clamp(1, 480),
        );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.home_work_outlined,
                          color: Colors.teal, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Agregar al Plan Hogar',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.task.description.length > 50
                                ? '${widget.task.description.substring(0, 47)}...'
                                : widget.task.description,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Selector de día
                Text('Día',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600])),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final isSelected = _selectedDay == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 40,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.teal : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected ? Colors.teal : Colors.grey[300]!,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _dayLabels[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // Veces + Tiempo
                Row(
                  children: [
                    // Cantidad de veces
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Veces',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600])),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() {
                                    if (_times > 1) _times--;
                                  }),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.remove,
                                        size: 16, color: Colors.teal),
                                  ),
                                ),
                                Text('$_times',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    if (_times < 5) _times++;
                                  }),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.add,
                                        size: 16, color: Colors.teal),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Tiempo estimado
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tiempo (min)',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600])),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _minutesController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              suffixText: 'min',
                              suffixStyle: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Botón confirmar
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _confirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Confirmar',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

#### 3. `lib/features/tareas_posit/presentation/widgets/posit_widget.dart`

Agregar el callback `onSendToPlan` al widget y el botón correspondiente.

**Cambios:**

a) Agregar parámetro al constructor:
```dart
// ANTES
class PostItWidget extends StatelessWidget {
  final TaskPosit task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const PostItWidget({
    Key? key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

// DESPUÉS
class PostItWidget extends StatelessWidget {
  final TaskPosit task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onSendToPlan;
  final VoidCallback onEdit;

  const PostItWidget({
    Key? key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
    required this.onTap,
    required this.onSendToPlan,
    required this.onEdit,
  }) : super(key: key);
```

b) En el `build`, localizar la sección de acciones del widget (donde están los botones de completar/eliminar) y agregar los nuevos botones. El resultado debe verse así en la zona de acciones del card:

```dart
// Fila de acciones al pie del PostIt
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    // Botón editar
    IconButton(
      onPressed: onEdit,
      icon: const Icon(Icons.edit_outlined, size: 16),
      style: IconButton.styleFrom(
        foregroundColor: Colors.grey[700],
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.all(4),
      ),
      tooltip: 'Editar',
    ),
    const SizedBox(width: 2),
    // Botón enviar a Plan Hogar
    TextButton.icon(
      onPressed: onSendToPlan,
      style: TextButton.styleFrom(
        foregroundColor: Colors.teal[700],
        backgroundColor: Colors.teal.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      icon: const Icon(Icons.home_work_outlined, size: 14),
      label: const Text('Plan Hogar',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
    ),
    const SizedBox(width: 4),
    // Botón completar (existente)
    IconButton(
      onPressed: onComplete,
      icon: const Icon(Icons.check_circle_outline, size: 16),
      style: IconButton.styleFrom(
        foregroundColor: Colors.green[700],
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.all(4),
      ),
      tooltip: 'Completar',
    ),
  ],
),
```

---

#### 4. `lib/features/tareas_posit/presentation/screens/tareas_posit_screen.dart`

**4a — Agregar import del nuevo bottom sheet:**
```dart
import '../widgets/send_to_plan_bottom_sheet.dart';
```

**4b — Agregar provider `updateTaskProvider` al archivo `task_posit_provider.dart` primero (ver Feature 2), luego importarlo si es necesario.**

**4c — En `_TareasPositScreenState`, agregar el método `_showSendToPlanSheet`:**
```dart
Future<void> _showSendToPlanSheet(TaskPosit task) async {
  final sent = await SendToPlanBottomSheet.show(context, task);
  if (sent && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Tarea agregada al Plan Hogar'),
          ],
        ),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
```

**4d — En todos los lugares donde se instancie `PostItWidget`, agregar los dos nuevos parámetros:**
```dart
PostItWidget(
  task: task,
  onComplete: () => _confirmComplete(houseId, task),
  onDelete: () => ref.read(deleteTaskProvider((houseId, task.id))),
  onTap: () => _showTaskDetail(task),
  onEdit: () => _showEditTaskDialog(task),            // ← nuevo
  onSendToPlan: () => _showSendToPlanSheet(task),     // ← nuevo
),
```

---

## Feature 2 — Editar tarea PostIt

### Descripción
Actualmente no existe forma de editar una `TaskPosit` ya creada. La infraestructura de datos ya está completa (`updateTask` existe en datasource, repository impl e interfaz), pero falta:
1. El provider de Riverpod para exponer la operación.
2. El diálogo de edición en la pantalla.
3. El botón en el widget.

---

### Archivos a modificar

#### 1. `lib/presentation/providers/task_posit_provider.dart`

Agregar al final del archivo el provider de actualización:

```dart
// Actualizar tarea existente
final updateTaskProvider = FutureProvider.family<void,
    (String houseId, TaskPosit updatedTask)>((ref, params) async {
  final (houseId, updatedTask) = params;
  final repository = ref.watch(taskPositRepositoryProvider);
  await repository.updateTask(houseId, updatedTask);
  ref.invalidate(houseTasksProvider(houseId));
});
```

---

#### 2. `lib/features/tareas_posit/presentation/screens/tareas_posit_screen.dart`

Agregar el método `_showEditTaskDialog` en `_TareasPositScreenState`.

Este método es **idéntico en estructura** al `_showAddTaskDialog` existente, con las siguientes diferencias:
- Recibe un parámetro `TaskPosit taskToEdit`.
- Pre-carga todos los campos con los valores actuales de la tarea:
  - `_descriptionController.text = taskToEdit.description`
  - `selectedPriority = taskToEdit.priority`
  - `selectedDate = taskToEdit.dueDate`
  - `estimatedMinutes = taskToEdit.estimatedMinutes`
  - `manualQuadrant = taskToEdit.eisenhowerQuadrant`
- El título del diálogo es `'Editar Tarea'` en lugar de `'Nueva Tarea'`.
- El botón de acción dice `'Guardar'` en lugar de `'Agregar'`.
- Al confirmar llama a `updateTaskProvider` en lugar de `addTaskProvider`:

```dart
void _showEditTaskDialog(TaskPosit taskToEdit) {
  _descriptionController.text = taskToEdit.description;
  TaskPriority selectedPriority = taskToEdit.priority;
  DateTime? selectedDate = taskToEdit.dueDate;
  int? estimatedMinutes = taskToEdit.estimatedMinutes;
  EisenhowerQuadrant? manualQuadrant = taskToEdit.eisenhowerQuadrant;

  // Obtener houseId del mismo modo que en _showAddTaskDialog
  final houseId = ref.read(householdProvider).house.hashCode.toString();

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (ctx, setDlg) {
        // — cuerpo idéntico al de _showAddTaskDialog —
        // — solo cambia el título, etiqueta del botón y la acción al guardar —

        // Al pulsar "Guardar":
        // if (_descriptionController.text.trim().isNotEmpty) {
        //   final updated = taskToEdit.copyWith(
        //     description: _descriptionController.text.trim(),
        //     priority: selectedPriority,
        //     dueDate: () => selectedDate,
        //     estimatedMinutes: () => estimatedMinutes,
        //     eisenhowerQuadrant: () => manualQuadrant ?? EisenhowerQuadrantX.suggest(...),
        //   );
        //   ref.read(updateTaskProvider((houseId, updated)));
        //   Navigator.pop(ctx);
        // }
      },
    ),
  );
}
```

> **Nota para Claude Code:** copiar el cuerpo completo de `_showAddTaskDialog` dentro de `_showEditTaskDialog`, cambiar título a `'Editar Tarea'`, etiqueta a `'Guardar'`, y reemplazar la llamada final de `addTaskProvider` por `updateTaskProvider` con el `taskToEdit.copyWith(...)`. No duplicar código fuera del diálogo; los widgets internos (`_ColorOption`, etc.) ya existen.

---

## Resumen de archivos tocados

| Archivo | Acción |
|---|---|
| `lib/presentation/providers/weekly_plan_provider.dart` | Agregar método `addTaskFromPosit` |
| `lib/presentation/providers/task_posit_provider.dart` | Agregar provider `updateTaskProvider` |
| `lib/features/tareas_posit/presentation/widgets/posit_widget.dart` | Agregar callbacks `onEdit` y `onSendToPlan` + botones |
| `lib/features/tareas_posit/presentation/widgets/send_to_plan_bottom_sheet.dart` | **NUEVO** — widget completo |
| `lib/features/tareas_posit/presentation/screens/tareas_posit_screen.dart` | Agregar `_showSendToPlanSheet`, `_showEditTaskDialog`, wiring |

## Notas de implementación

- `addTaskFromPosit` no depende de Firebase; solo actúa sobre el `WeeklyPlan` local/activo. Si el hogar está en modo compartido, `SharedPlanProvider` sincronizará el plan automáticamente en el siguiente ciclo de auto-sync.
- El `houseId` para las operaciones de `TaskPosit` se obtiene del mismo modo que en `_showAddTaskDialog` existente — verificar cómo se extrae actualmente y mantener consistencia.
- En `PostItWidget`, si el diseño actual no tiene una fila de acciones explícita, buscar dónde se renderizan `onComplete` y `onDelete` e insertar los nuevos botones en el mismo contenedor.
- La tarea enviada al plan aparece con `isCustom: true` y `category: TaskCategory.general`. El badge "Nuevo" visual mencionado en el diseño es opcional y queda fuera del scope de este brief.
