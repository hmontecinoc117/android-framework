# Android Framework - Kotlin + Jetpack Compose

Framework escalable para desarrollar aplicaciones Android desde lo básico hasta integraciones complejas con Raspberry Pi.

## 📁 Estructura del Proyecto

```
android-framework/
├── app/                          # Aplicación principal
│   ├── src/main/kotlin/
│   │   └── com/framework/
│   │       ├── MainActivity.kt
│   │       └── ui/
│   │           ├── theme/       # Temas y estilos
│   │           └── screens/     # Pantallas principales
│   └── build.gradle.kts
│
├── core/                         # Módulos compartidos
│   ├── ui/                       # Componentes UI reutilizables
│   ├── data/                     # Persistencia, BD, Room
│   └── network/                  # Networking, Retrofit, OkHttp
│
├── features/                     # Features escalables
│   ├── basic/                    # Ejemplos básicos (Contador, TODO)
│   ├── intermediate/             # Ejemplos intermedios (APIs, MVVM avanzado)
│   └── hardware/                 # Integración hardware
│       ├── bluetooth/            # Comunicación Bluetooth
│       └── gpio/                 # GPIO para Raspberry Pi
│
├── build-logic/                  # Plugins y convenciones Gradle
├── settings.gradle.kts           # Configuración multi-modular
├── build.gradle.kts              # Build script root
└── gradle.properties             # Propiedades globales
```

## 🚀 Features Incluidos

### Básicos
- **Contador**: Ejemplo simple de ViewModel + StateFlow
- **Lista de Tareas (TODO)**: CRUD completo con Compose
- **Tema Material Design 3**: Integración completa

### Intermedios
- **API REST**: Integración con Retrofit y manejo de estados
- **MVVM mejorado**: ViewModel, StateFlow, Coroutines
- **Manejo de errores**: Try-catch y UI de errores

### Hardware (Raspberry Pi)
- **Bluetooth**: Descubrimiento y conexión de dispositivos
- **GPIO**: Control de LEDs y periféricos
- **Android Things**: Soporte para Raspberry Pi

## 🛠️ Requisitos

- **Android Studio**: Versión 2023.1 o superior
- **SDK Android**: API 24+ (Android 7.0)
- **Kotlin**: 1.9.20+
- **Gradle**: 8.2.0

## 📦 Dependencias Principales

### UI & Compose
- androidx.compose.ui:ui
- androidx.compose.material3:material3
- androidx.navigation:navigation-compose

### Data & Persistence
- androidx.room:room-runtime

### Networking
- com.squareup.retrofit2:retrofit
- com.squareup.okhttp3:okhttp

### DI & State Management
- com.google.dagger:hilt-android
- androidx.lifecycle:lifecycle-runtime-ktx

## 🔧 Configuración Rápida

### 1. Clonar y abrir en Android Studio
```bash
cd android-framework
# Abrir con Android Studio
```

### 2. Sincronizar Gradle
Android Studio sincronizará automáticamente todos los módulos.

### 3. Ejecutar la app
- Conectar dispositivo Android o emulador
- Click en "Run" en Android Studio
- Seleccionar emulador o dispositivo

## 📱 Ejemplos de Uso

### Contador Simple
```kotlin
CounterScreen(viewModel = CounterViewModel())
```

### Lista de Tareas
```kotlin
TodoScreen(viewModel = TodoViewModel())
```

### Llamadas API
```kotlin
PostsScreen(viewModel = PostViewModel(apiService))
```

### Control GPIO (Raspberry Pi)
```kotlin
GpioScreen(viewModel = GpioViewModel())
```

### Bluetooth
```kotlin
BluetoothScreen(viewModel = BluetoothViewModel())
```

## 🎯 Próximos Pasos

1. **Persistencia avanzada**: Implementar Room Database
2. **Testing**: Unit tests y integration tests
3. **CI/CD**: GitHub Actions
4. **Publicación**: PlayStore
5. **Documentación**: Tutoriales paso a paso

## 🐛 Troubleshooting

### Error de sincronización Gradle
- Limpiar cache: `./gradlew clean`
- Invalida y reinicia: File > Invalidate Caches

### Errores de compilación
- Verificar SDK: File > Project Structure
- Asegurar minSdk = 24

### Emulador lento
- Usar AVD con aceleración KVM
- Aumentar memoria en emulador settings

## 📚 Recursos

- [Documentación Compose](https://developer.android.com/jetpack/compose)
- [Android Architecture Components](https://developer.android.com/guide/components)
- [Retrofit Docs](https://square.github.io/retrofit/)
- [Room Database](https://developer.android.com/training/data-storage/room)
- [Android Things](https://developer.android.com/things)

## 📄 Licencia

Este framework es open source. Siéntete libre de usarlo y modificarlo.

---

**Última actualización**: Enero 2026
