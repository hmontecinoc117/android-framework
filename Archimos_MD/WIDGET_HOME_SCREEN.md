# WIDGET_HOME_SCREEN.md
# Feature: Widget de pantalla de inicio — Plan Hogar

## Objetivo
Implementar un widget nativo de pantalla de inicio para Android (4×2 Large) e iOS (Medium)
que permita acceso rápido a los 5 módulos de la app con info dinámica.

Implementar **un paso a la vez** y esperar confirmación antes de continuar.

---

## Dependencia

Agregar en `pubspec.yaml`:

```yaml
dependencies:
  home_widget: ^0.6.0
```

---

## Módulos y colores de identidad

| Módulo | Color | Deep link |
|---|---|---|
| Plan Hogar | `#00897B` (teal) | `planhogar://dashboard` |
| Menú Semanal | `#3949AB` (indigo) | `planhogar://menu_semanal` |
| Recetas | `#E53935` (red) | `planhogar://recipes` |
| Lista de Compras | `#43A047` (green) | `planhogar://lista_compras` |
| Tareas | `#FB8C00` (orange) | `planhogar://tareas_posit` |

---

## Paso 1 — Android: layout XML del widget

### Archivo nuevo: `android/app/src/main/res/layout/plan_hogar_widget.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="@drawable/widget_background"
    android:padding="12dp">

    <!-- Header -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:gravity="center_vertical"
        android:layout_marginBottom="8dp">

        <TextView
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="Plan Hogar"
            android:textSize="12sp"
            android:textColor="#99FFFFFF"
            android:fontFamily="sans-serif-medium" />

        <TextView
            android:id="@+id/widget_date"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="hoy"
            android:textSize="10sp"
            android:textColor="#66FFFFFF" />
    </LinearLayout>

    <!-- Módulos: fila de 5 -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:orientation="horizontal"
        android:gravity="center">

        <!-- Plan Hogar -->
        <LinearLayout
            android:id="@+id/btn_plan_hogar"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical"
            android:gravity="center"
            android:padding="4dp">
            <ImageView
                android:layout_width="32dp"
                android:layout_height="32dp"
                android:src="@drawable/ic_widget_home"
                android:background="@drawable/module_bg_teal"
                android:padding="6dp"
                android:contentDescription="Plan Hogar" />
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Plan"
                android:textSize="8sp"
                android:textColor="#BDFFFFFF"
                android:layout_marginTop="3dp" />
        </LinearLayout>

        <!-- Menú Semanal -->
        <LinearLayout
            android:id="@+id/btn_menu_semanal"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical"
            android:gravity="center"
            android:padding="4dp">
            <ImageView
                android:layout_width="32dp"
                android:layout_height="32dp"
                android:src="@drawable/ic_widget_calendar"
                android:background="@drawable/module_bg_indigo"
                android:padding="6dp"
                android:contentDescription="Menú Semanal" />
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Menú"
                android:textSize="8sp"
                android:textColor="#BDFFFFFF"
                android:layout_marginTop="3dp" />
        </LinearLayout>

        <!-- Recetas -->
        <LinearLayout
            android:id="@+id/btn_recetas"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical"
            android:gravity="center"
            android:padding="4dp">
            <ImageView
                android:layout_width="32dp"
                android:layout_height="32dp"
                android:src="@drawable/ic_widget_restaurant"
                android:background="@drawable/module_bg_red"
                android:padding="6dp"
                android:contentDescription="Recetas" />
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Recetas"
                android:textSize="8sp"
                android:textColor="#BDFFFFFF"
                android:layout_marginTop="3dp" />
        </LinearLayout>

        <!-- Lista Compras -->
        <LinearLayout
            android:id="@+id/btn_lista_compras"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical"
            android:gravity="center"
            android:padding="4dp">
            <ImageView
                android:layout_width="32dp"
                android:layout_height="32dp"
                android:src="@drawable/ic_widget_cart"
                android:background="@drawable/module_bg_green"
                android:padding="6dp"
                android:contentDescription="Lista de Compras" />
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Compras"
                android:textSize="8sp"
                android:textColor="#BDFFFFFF"
                android:layout_marginTop="3dp" />
        </LinearLayout>

        <!-- Tareas -->
        <LinearLayout
            android:id="@+id/btn_tareas"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical"
            android:gravity="center"
            android:padding="4dp">
            <ImageView
                android:layout_width="32dp"
                android:layout_height="32dp"
                android:src="@drawable/ic_widget_task"
                android:background="@drawable/module_bg_orange"
                android:padding="6dp"
                android:contentDescription="Tareas" />
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Tareas"
                android:textSize="8sp"
                android:textColor="#BDFFFFFF"
                android:layout_marginTop="3dp" />
        </LinearLayout>

    </LinearLayout>

    <!-- Info dinámica -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:layout_marginTop="6dp"
        android:paddingTop="6dp"
        android:gravity="center_vertical">

        <TextView
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="Próxima tarea"
            android:textSize="9sp"
            android:textColor="#66FFFFFF" />

        <TextView
            android:id="@+id/widget_next_task"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Sin tareas pendientes"
            android:textSize="9sp"
            android:textColor="#B200BFA5"
            android:fontFamily="sans-serif-medium"
            android:maxLines="1"
            android:ellipsize="end" />
    </LinearLayout>

</LinearLayout>
```

---

### Archivo nuevo: `android/app/src/main/res/drawable/widget_background.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#E6000000" />
    <corners android:radius="20dp" />
</shape>
```

### Archivos nuevos: fondos de módulo (uno por color)

**`android/app/src/main/res/drawable/module_bg_teal.xml`**
```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#3300897B" />
    <corners android:radius="8dp" />
</shape>
```

Repetir para los otros cuatro colores con sus respectivos valores:
- `module_bg_indigo.xml` → `#333949AB`
- `module_bg_red.xml` → `#33E53935`
- `module_bg_green.xml` → `#3343A047`
- `module_bg_orange.xml` → `#33FB8C00`

---

### Archivo nuevo: `android/app/src/main/res/xml/plan_hogar_widget_info.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="250dp"
    android:minHeight="110dp"
    android:targetCellWidth="4"
    android:targetCellHeight="2"
    android:updatePeriodMillis="1800000"
    android:initialLayout="@layout/plan_hogar_widget"
    android:widgetCategory="home_screen"
    android:description="@string/widget_description"
    android:previewLayout="@layout/plan_hogar_widget" />
```

---

## Paso 2 — Android: AppWidgetProvider en Kotlin

### Archivo nuevo: `android/app/src/main/kotlin/.../PlanHogarWidgetProvider.kt`

Ubicar en el mismo paquete que `MainActivity.kt`.

```kotlin
package com.example.planhogar49

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PlanHogarWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val nextTask = widgetData.getString("widget_next_task", "Sin tareas pendientes")

        val views = RemoteViews(context.packageName, R.layout.plan_hogar_widget)

        views.setTextViewText(R.id.widget_next_task, nextTask)

        // Deep links por módulo
        val modules = mapOf(
            R.id.btn_plan_hogar    to "planhogar://dashboard",
            R.id.btn_menu_semanal  to "planhogar://menu_semanal",
            R.id.btn_recetas       to "planhogar://recipes",
            R.id.btn_lista_compras to "planhogar://lista_compras",
            R.id.btn_tareas        to "planhogar://tareas_posit"
        )

        modules.forEach { (viewId, deepLink) ->
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(deepLink)).apply {
                setPackage(context.packageName)
            }
            val pendingIntent = PendingIntent.getActivity(
                context, viewId, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(viewId, pendingIntent)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
```

---

## Paso 3 — Android: AndroidManifest.xml

Dentro de `<application>` en `android/app/src/main/AndroidManifest.xml`, agregar:

```xml
<!-- Widget provider -->
<receiver
    android:name=".PlanHogarWidgetProvider"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/plan_hogar_widget_info" />
</receiver>
```

Agregar también el intent-filter de deep link en la `<activity>` de MainActivity:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="planhogar" />
</intent-filter>
```

---

## Paso 4 — Flutter: servicio de actualización del widget

### Archivo nuevo: `lib/core/services/widget_update_service.dart`

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:home_widget/home_widget.dart';

import '../../domain/entities/task.dart';

class WidgetUpdateService {
  static const _appGroupId = 'group.com.example.planhogar49';
  static const _iOSName = 'PlanHogarWidget';
  static const _androidName = 'PlanHogarWidgetProvider';

  static Future<void> init() async {
    if (kIsWeb) return;
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// Actualiza los datos del widget con la próxima tarea pendiente del día.
  static Future<void> updateNextTask(List<Task> todayTasks) async {
    if (kIsWeb) return;

    final pending = todayTasks.where((t) => !t.isCompleted).toList();
    final label = pending.isEmpty
        ? 'Sin tareas pendientes'
        : pending.first.title;

    await HomeWidget.saveWidgetData<String>('widget_next_task', label);
    await HomeWidget.updateWidget(
      iOSName: _iOSName,
      androidName: _androidName,
    );
  }

  /// Llamar al abrir la app para refrescar el widget.
  static Future<void> refresh(List<Task> todayTasks) => updateNextTask(todayTasks);
}
```

---

## Paso 5 — Flutter: deep link handler en `main.dart`

En `main.dart`, dentro de `PlanHogarApp.build`, agregar inicialización del widget y
manejo del deep link al inicio de la app. Usar `HomeWidget.widgetClicked` stream:

```dart
// Dentro de initState o un Consumer al tope del widget tree:
HomeWidget.widgetClicked.listen((uri) {
  if (uri == null) return;
  final path = uri.host; // e.g. "dashboard", "menu_semanal", etc.
  switch (path) {
    case 'dashboard':
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/dashboard', (_) => false);
      break;
    case 'menu_semanal':
      navigatorKey.currentState?.pushNamed('/menu_semanal');
      break;
    case 'recipes':
      navigatorKey.currentState?.pushNamed('/recipes');
      break;
    case 'lista_compras':
      navigatorKey.currentState?.pushNamed('/lista_compras');
      break;
    case 'tareas_posit':
      navigatorKey.currentState?.pushNamed('/tareas_posit');
      break;
  }
});
```

Usar `ReminderController.navigatorKey` que ya existe en el proyecto.

---

## Paso 6 — Trigger de actualización desde providers

En `weekly_plan_provider.dart`, al terminar de cargar el plan del día actual, llamar:

```dart
// Al resolver las tareas de hoy:
final todayTasks = /* tareas del día actual */;
WidgetUpdateService.updateNextTask(todayTasks.map((pt) => pt.task).toList());
```

Agregar el import correspondiente y proteger con `!kIsWeb`.

---

## Paso 7 — iOS: WidgetKit extension (implementar solo si hay compilación iOS activa)

> **Nota:** Este paso requiere Xcode. Si no hay Mac disponible, omitir por ahora
> y marcar como pendiente para cuando se configure Codemagic CI/CD.

Crear un Widget Extension en Xcode:
- File → New → Target → Widget Extension
- Nombre: `PlanHogarWidget`
- Bundle ID: `com.example.planhogar49.widget`
- Habilitar "Include Configuration Intent": NO

El widget debe mostrar 4 módulos principales (Plan Hogar, Menú, Compras, Tareas)
más dos chips de datos dinámicos (tareas pendientes hoy, plato del menú).

Los datos se leen desde el App Group compartido configurado en `WidgetUpdateService`.

---

## Íconos vectoriales requeridos en Android

Crear los siguientes drawables en `android/app/src/main/res/drawable/`
usando vectores simples (Vector Asset en Android Studio o XML a mano):

| Archivo | Ícono |
|---|---|
| `ic_widget_home.xml` | Casa simple |
| `ic_widget_calendar.xml` | Calendario |
| `ic_widget_restaurant.xml` | Plato/tenedor |
| `ic_widget_cart.xml` | Carrito de compras |
| `ic_widget_task.xml` | Nota/sticker |

Todos en blanco (`#FFFFFFFF`) con `viewportWidth/Height="24"`.

---

## Resumen de archivos

| Archivo | Acción |
|---|---|
| `pubspec.yaml` | Agregar `home_widget: ^0.6.0` |
| `android/app/src/main/res/layout/plan_hogar_widget.xml` | NUEVO |
| `android/app/src/main/res/drawable/widget_background.xml` | NUEVO |
| `android/app/src/main/res/drawable/module_bg_*.xml` (×5) | NUEVO |
| `android/app/src/main/res/xml/plan_hogar_widget_info.xml` | NUEVO |
| `android/app/src/main/kotlin/.../PlanHogarWidgetProvider.kt` | NUEVO |
| `android/app/src/main/AndroidManifest.xml` | MODIFICAR (receiver + deep link) |
| `lib/core/services/widget_update_service.dart` | NUEVO |
| `lib/main.dart` | MODIFICAR (deep link listener) |
| `lib/presentation/providers/weekly_plan_provider.dart` | MODIFICAR (trigger actualización) |

---

## Notas de implementación

- Verificar el `applicationId` real en `android/app/build.gradle` y usarlo
  consistentemente en el package de `PlanHogarWidgetProvider.kt`.
- El campo `widget_next_task` se almacena vía `HomeWidget.saveWidgetData`
  y se lee desde Kotlin con `HomeWidgetPlugin.getData(context)`.
- No tocar lógica de Firebase, Hive ni Riverpod providers existentes más allá
  del trigger de actualización en `weekly_plan_provider.dart`.
- `kIsWeb` debe proteger todas las llamadas a `home_widget` para mantener
  compatibilidad con la versión web del proyecto.
- Implementar un paso a la vez y confirmar antes de continuar con el siguiente.
