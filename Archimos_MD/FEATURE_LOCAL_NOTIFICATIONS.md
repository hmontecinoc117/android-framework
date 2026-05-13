# FEATURE: Notificaciones en Background / App Cerrada

## Objetivo
Reemplazar el sistema de polling in-app (`InAppNotificationService`) por notificaciones
locales programadas en el sistema operativo Android, de modo que los recordatorios se
disparen aunque la app esté en background o completamente cerrada.

---

## Paquetes a agregar en `pubspec.yaml`

```yaml
dependencies:
  flutter_local_notifications: ^18.0.1
  timezone: ^0.9.4
```

Ejecutar tras editar:
```bash
flutter pub get
```

---

## Paso 1 — Permisos en `android/app/src/main/AndroidManifest.xml`

Agregar dentro de `<manifest>`, antes de `<application>`:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

Agregar dentro de `<application>`:

```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
    <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
    <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
  </intent-filter>
</receiver>
```

---

## Paso 2 — Nuevo archivo `lib/core/utils/local_notification_service.dart`

Crear este archivo completo:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio que programa y cancela notificaciones locales en el OS de Android.
/// En web es un no-op completo (no hace nada, sin errores).
class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _androidDetails = AndroidNotificationDetails(
    'plan_hogar_reminders',
    'Recordatorios Plan Hogar',
    channelDescription: 'Avisos de tareas y recordatorios del hogar',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction('snooze', 'Posponer'),
      AndroidNotificationAction('dismiss', 'Descartar'),
    ],
  );

  static const _notificationDetails = NotificationDetails(
    android: _androidDetails,
  );

  /// Inicializar una sola vez desde `main.dart` antes de `runApp`.
  static Future<void> init() async {
    if (kIsWeb || _initialized) return;

    tz.initializeTimeZones();
    // Usar zona horaria local del dispositivo
    tz.setLocalLocation(tz.local);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundResponse,
    );

    // Solicitar permiso en Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Solicitar permiso para alarmas exactas (Android 12+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    _initialized = true;
  }

  /// Programa una notificación para la hora exacta del recordatorio.
  /// [id] debe ser un entero estable derivado del reminderId (usar hashCode).
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    if (kIsWeb) return;
    if (!_initialized) await init();

    final tzDate = tz.TZDateTime.from(scheduledAt, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancela una notificación programada por su id.
  static Future<void> cancel(int id) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancel(id);
  }

  /// Cancela todas las notificaciones programadas.
  static Future<void> cancelAll() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancelAll();
  }
}

/// Handler de respuestas cuando el usuario toca la notificación o sus acciones.
/// Se ejecuta tanto en foreground como cuando el usuario toca desde el panel.
void _onNotificationResponse(NotificationResponse response) {
  // Acciones de los botones
  final action = response.actionId;
  if (action == 'dismiss') {
    // La notificación ya fue descartada visualmente; sin acción adicional aquí.
    // El reminder_provider se encargará al re-entrar a la app si es necesario.
  }
  // 'snooze' y tap principal: la app abrirá y el InAppNotificationService
  // mostrará el diálogo si corresponde.
}

/// Handler para respuestas recibidas cuando la app está terminada (killed).
@pragma('vm:entry-point')
void _onBackgroundResponse(NotificationResponse response) {
  // Solo log en background; lógica de snooze/dismiss se resuelve al reabrir.
}
```

---

## Paso 3 — Modificar `lib/main.dart`

Agregar la inicialización de `LocalNotificationService` antes de `runApp`:

```dart
// Importar al inicio del archivo
import 'core/utils/local_notification_service.dart';

// Dentro de main(), tras Firebase.initializeApp y antes de runApp:
await LocalNotificationService.init();
```

El bloque `main()` quedará así:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService.init();           // <-- NUEVA LÍNEA
  final storage = await LocalHouseStorage.init();
  runApp(
    ProviderScope(
      overrides: [localHouseStorageProvider.overrideWithValue(storage)],
      child: const PlanHogarApp(),
    ),
  );
}
```

---

## Paso 4 — Modificar `lib/presentation/providers/reminder_provider.dart`

### 4a — Agregar import

```dart
import '../../core/utils/local_notification_service.dart';
```

### 4b — Helper para convertir reminderId a int estable

Agregar dentro de `ReminderController`, como método privado:

```dart
/// Convierte un UUID a un int de 32 bits estable para usar como ID
/// de notificación local (flutter_local_notifications requiere int).
int _notifId(String reminderId) => reminderId.hashCode.abs() % 0x7FFFFFFF;
```

### 4c — En `addReminder`, programar la notificación tras guardar

Después de `await _storage.saveReminders(updated);` agregar:

```dart
await LocalNotificationService.schedule(
  id: _notifId(reminder.id),
  title: '¡Recordatorio!',
  body: reminder.message,
  scheduledAt: reminder.scheduledAt,
);
```

### 4d — En `snoozeReminder`, reprogramar la notificación

Después de `await _storage.saveReminders(updated);` agregar:

```dart
final snoozed = updated.firstWhere((r) => r.id == reminderId);
await LocalNotificationService.schedule(
  id: _notifId(reminderId),
  title: '¡Recordatorio pospuesto!',
  body: snoozed.message,
  scheduledAt: snoozed.effectiveTime,
);
```

### 4e — En `dismissReminder`, cancelar la notificación

Después de `await _storage.saveReminders(updated);` agregar:

```dart
await LocalNotificationService.cancel(_notifId(reminderId));
```

### 4f — En `deleteReminder`, cancelar la notificación

Después de `await _storage.saveReminders(updated);` agregar:

```dart
await LocalNotificationService.cancel(_notifId(reminderId));
```

---

## Archivos tocados

| Archivo | Acción |
|---|---|
| `pubspec.yaml` | Agregar `flutter_local_notifications` y `timezone` |
| `android/app/src/main/AndroidManifest.xml` | Agregar permisos y receivers |
| `lib/core/utils/local_notification_service.dart` | **NUEVO** — servicio nativo |
| `lib/main.dart` | Agregar `LocalNotificationService.init()` |
| `lib/presentation/providers/reminder_provider.dart` | Integrar schedule/cancel en CRUD de recordatorios |

## Archivos que NO se tocan

- `lib/core/utils/in_app_notification_service.dart` — sigue igual, gestiona el diálogo in-app
- `lib/domain/entities/task_reminder.dart` — sin cambios
- `lib/presentation/widgets/reminder_form_dialog.dart` — sin cambios
- `lib/data/datasources/local_house_storage.dart` — sin cambios
- Toda la UI de notificaciones — sin cambios

---

## Comportamiento resultante

| Estado de la app | Comportamiento |
|---|---|
| App abierta | Android dispara la notificación → `InAppNotificationService` muestra el diálogo (como antes) |
| App en background | Android muestra la notificación en el panel; al tocar, abre la app |
| App cerrada | Android muestra la notificación en el panel; al tocar, abre la app desde cero |

---

## Notas importantes para Claude Code

- No modificar ningún archivo de web (los métodos de `LocalNotificationService` tienen guard `if (kIsWeb) return` en todos los puntos de entrada).
- No cambiar la lógica de `InAppNotificationService` — ambos servicios coexisten.
- `_notifId` usa `hashCode.abs() % 0x7FFFFFFF` para garantizar un int positivo de 32 bits.
- Si el dispositivo corre Android 12+ y el usuario no otorga el permiso de alarmas exactas, `zonedSchedule` fallará silenciosamente — esto es aceptable para MVP.
