# FIX_WIDGET_AND_POSIT.md
# Correcciones: Widget visual, deep links y botón Plan Hogar en PostIt

Implementar **un fix a la vez** y esperar confirmación antes de continuar.

---

## Fix 1 — Widget: íconos más grandes y visibles

### Problema
Los íconos se ven pequeños (32dp) y oscuros (opacidad de fondo al 20%).

### Archivo: `android/app/src/main/res/layout/plan_hogar_widget.xml`

Cambios en cada `<ImageView>` de módulo:
- `android:layout_width` y `android:layout_height`: de `32dp` → `42dp`
- `android:padding`: de `6dp` → `8dp`

Cambios en cada `<LinearLayout>` de módulo (los que contienen icono + label):
- `android:padding`: de `4dp` → `6dp`

### Archivos: `android/app/src/main/res/drawable/module_bg_*.xml` (×5)

Aumentar la opacidad del color de fondo de cada módulo.
Cambiar el primer byte del color hexadecimal (canal alpha) de `33` → `77`:

| Archivo | Antes | Después |
|---|---|---|
| `module_bg_teal.xml` | `#3300897B` | `#7700897B` |
| `module_bg_indigo.xml` | `#333949AB` | `#773949AB` |
| `module_bg_red.xml` | `#33E53935` | `#77E53935` |
| `module_bg_green.xml` | `#3343A047` | `#7743A047` |
| `module_bg_orange.xml` | `#33FB8C00` | `#77FB8C00` |

---

## Fix 2 — Widget: deep links no navegan al módulo correcto

### Problema
Al tocar cualquier módulo del widget, la app siempre abre la pantalla principal
(DashboardShell) en vez de ir directamente al módulo.

**Causa:** el listener `HomeWidget.widgetClicked` solo captura taps cuando la app
ya está corriendo en memoria (warm start). Cuando la app estaba cerrada (cold start),
el deep link llega antes de que el listener esté registrado y se pierde.
Además, `DashboardShell` no reacciona a la URI de entrada.

### Solución: manejar ambos casos en `lib/main.dart`

Dentro de `PlanHogarApp` (o en un `ConsumerStatefulWidget` wrapper al nivel raíz),
agregar lo siguiente:

```dart
@override
void initState() {
  super.initState();
  // Cold start: app lanzada desde el widget estando cerrada
  HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
    if (uri != null) _handleWidgetUri(uri);
  });
  // Warm start: app ya estaba corriendo en memoria
  HomeWidget.widgetClicked.listen((uri) {
    if (uri != null) _handleWidgetUri(uri);
  });
}

void _handleWidgetUri(Uri uri) {
  final navigatorKey = ReminderController.navigatorKey;
  // Esperar un frame para que el navigator esté montado
  WidgetsBinding.instance.addPostFrameCallback((_) {
    switch (uri.host) {
      case 'dashboard':
        navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/dashboard', (_) => false);
        break;
      case 'menu_semanal':
        navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/dashboard', (_) => false);
        navigatorKey.currentState?.pushNamed('/menu_semanal');
        break;
      case 'recipes':
        navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/dashboard', (_) => false);
        navigatorKey.currentState?.pushNamed('/recipes');
        break;
      case 'lista_compras':
        navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/dashboard', (_) => false);
        navigatorKey.currentState?.pushNamed('/lista_compras');
        break;
      case 'tareas_posit':
        navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/dashboard', (_) => false);
        navigatorKey.currentState?.pushNamed('/tareas_posit');
        break;
    }
  });
}
```

> **Nota:** el patrón `pushNamedAndRemoveUntil('/dashboard')` + `pushNamed('/modulo')`
> garantiza que el stack de navegación siempre quede limpio con el dashboard como base,
> y el módulo encima. Si la ruta `/dashboard` no existe como named route, reemplazar
> por `MaterialPageRoute(builder: (_) => const DashboardShell())`.

### Verificar en `AndroidManifest.xml`

Confirmar que el intent-filter de deep link en `<activity>` de MainActivity incluye:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="planhogar" />
</intent-filter>
```

Si no está, agregarlo.

---

## Fix 3 — PostIt: botón "Plan Hogar" fuera de la tarjeta

### Problema
En `posit_widget.dart`, el botón "Plan Hogar" (y el de editar) aparece fuera
del área visual de la tarjeta amarilla.

### Causa probable
Los botones de acción (`onEdit`, `onSendToPlan`) están siendo renderizados
**fuera** del `Container` principal de la tarjeta, posiblemente en un `Stack`
o `Column` externo al `ClipRRect`/`Container` que dibuja el fondo amarillo.

### Solución en `lib/features/tareas_posit/presentation/widgets/posit_widget.dart`

La fila de acciones debe estar **dentro** del `Column` principal de la tarjeta,
antes del botón "Listo". La estructura correcta es:

```
Container (fondo amarillo, padding, borderRadius)
  └── Column
        ├── Row (título + botón X de cerrar)   ← ya existe
        ├── ... (prioridad, info adicional)    ← ya existe
        ├── Spacer()
        ├── Row (acciones: editar | Plan Hogar) ← MOVER AQUÍ, dentro del Container
        └── Center → botón "Listo"             ← ya existe
```

La fila de acciones debe tener esta estructura, ubicada **antes** del botón Listo
y **dentro** del mismo Container amarillo:

```dart
Row(
  children: [
    // Botón editar
    GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, size: 11, color: Colors.black54),
            SizedBox(width: 3),
            Text('Editar',
                style: TextStyle(fontSize: 10, color: Colors.black54,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ),
    const SizedBox(width: 6),
    // Botón enviar a Plan Hogar
    GestureDetector(
      onTap: onSendToPlan,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.teal.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home_work, size: 11, color: Colors.teal),
            const SizedBox(width: 3),
            Text('Plan Hogar',
                style: TextStyle(fontSize: 10,
                    color: Colors.teal[700],
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ),
  ],
),
const SizedBox(height: 6),
```

Verificar que `onEdit` y `onSendToPlan` sean parámetros del widget (`VoidCallback?`)
y que estén siendo pasados correctamente desde `tareas_posit_screen.dart`.

Si los callbacks son nulos (la tarea no tiene `onSendToPlan` asignado),
ocultar el botón con: `if (onSendToPlan != null) ...`

---

## Resumen de archivos tocados

| Archivo | Fix |
|---|---|
| `android/app/src/main/res/drawable/module_bg_*.xml` (×5) | Fix 1 — opacidad |
| `android/app/src/main/res/layout/plan_hogar_widget.xml` | Fix 1 — tamaño íconos |
| `lib/main.dart` | Fix 2 — cold + warm start deep links |
| `android/app/src/main/AndroidManifest.xml` | Fix 2 — verificar intent-filter |
| `lib/features/tareas_posit/presentation/widgets/posit_widget.dart` | Fix 3 — botones dentro del card |
