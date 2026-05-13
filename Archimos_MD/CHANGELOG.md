# Changelog

## v1.0.0 (Enero 2026)

### ✨ Features
- [x] Estructura base multi-módulo
- [x] Jetpack Compose + Material Design 3
- [x] ViewModel + StateFlow + Coroutines
- [x] Ejemplo Contador básico
- [x] Ejemplo TODO list (CRUD completo)
- [x] Integración Retrofit + OkHttp
- [x] Manejo de estados de API (Loading, Success, Error)
- [x] Bluetooth manager + descubrimiento de dispositivos
- [x] GPIO manager para Raspberry Pi
- [x] Componentes UI reutilizables
- [x] Documentación completa
- [x] Tutoriales paso a paso

### 📦 Módulos
- `app` - Aplicación principal
- `core/ui` - Componentes UI compartidos
- `core/data` - BD (Room) y persistencia
- `core/network` - APIs y networking
- `features/basic` - Ejemplos básicos
- `features/intermediate` - Ejemplos intermedios
- `features/hardware/bluetooth` - Control Bluetooth
- `features/hardware/gpio` - Control GPIO (RPi)

### 🔧 Configuración
- Gradle 8.2.0
- Kotlin 1.9.20
- Compose 1.5.4
- AndroidX + Material3

---

## v1.1.0 (Planeado)

### 🎯 Próximas mejoras
- [ ] Room Database (persistencia local completa)
- [ ] Datastore (preferencias modernas)
- [ ] WorkManager (tareas en background)
- [ ] Unit tests + Integration tests
- [ ] CI/CD con GitHub Actions
- [ ] Instrumentación de sensores (Acelerómetro, etc.)
- [ ] Firebase integration
- [ ] Soporte para NFC
- [ ] WebSocket para comunicación en tiempo real

---

## Historial de cambios

### v1.0.0
- Versión inicial del framework
- Estructura escalable para diferentes niveles de complejidad
- Soporte inicial para hardware (Bluetooth, GPIO)
