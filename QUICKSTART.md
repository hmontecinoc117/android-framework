## 🎯 Resumen Rápido del Framework

**Android Framework** es un kit de desarrollo escalable para aplicaciones Android con Kotlin y Jetpack Compose.

### ✅ Incluido

#### Core (Módulos Reutilizables)
- `core/ui` - Componentes Compose
- `core/data` - Room, persistencia
- `core/network` - Retrofit, APIs REST

#### Features Básicas
- Contador (ViewModel + StateFlow)
- Lista de Tareas (CRUD completo)
- Temas Material Design 3

#### Features Intermedias
- Consumo de APIs REST
- Manejo de estados (Loading, Success, Error)
- Notas con Database

#### Hardware (Raspberry Pi)
- 🔵 Bluetooth - Descubrimiento de dispositivos
- ⚡ GPIO - Control de LEDs y periféricos

### 🚀 Inicio Rápido

```bash
# 1. Abre en Android Studio
File > Open > /home/xtotox/Documentos/android-framework

# 2. Sincroniza Gradle
Ctrl+Shift+A > Sync Now

# 3. Ejecuta
Shift+F10 (Windows/Linux) o Cmd+R (Mac)
```

### 📁 Estructura

```
features/          Desarrolla aquí nuevas características
├── basic/        Ejemplos simples
├── intermediate/  Nivel medio
└── hardware/     Bluetooth, GPIO, sensores

core/             Código compartido
├── ui/          Componentes reutilizables
├── data/        Persistencia y BD
└── network/     APIs y networking
```

### 📚 Recursos

- [README.md](README.md) - Documentación completa
- [TUTORIALS.md](TUTORIALS.md) - 5 tutoriales paso a paso
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribuir al proyecto
- [CHANGELOG.md](CHANGELOG.md) - Historial de versiones

### 🎓 Nivel de Aprendizaje

- **Principiante**: Leer `TUTORIALS.md` lecciones 1-2
- **Intermedio**: Lecciones 3-4
- **Avanzado**: Lección 5 (Bluetooth + GPIO)

### 🔧 Stack Utilizado

| Layer | Tecnología |
|-------|-----------|
| UI | Jetpack Compose |
| Arquitectura | MVVM + Repository |
| Estado | StateFlow + Coroutines |
| Networking | Retrofit + OkHttp |
| BD Local | Room |
| DI | Hilt |
| Hardware | Android Things |

### ⚡ Características

✅ Multi-módulo escalable  
✅ Moderno y actualizado  
✅ Ejemplos funcionales  
✅ Documentación completa  
✅ Soporte Raspberry Pi  
✅ Prácticas recomendadas  

---

**¡Listo para comenzar!** 🚀

Próximo paso: Lee [TUTORIALS.md](TUTORIALS.md)
