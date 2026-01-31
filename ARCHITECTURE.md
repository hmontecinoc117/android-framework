# Arquitectura del Framework

## Diagrama de Módulos

```
┌─────────────────────────────────────────────────────────┐
│                    APP (Aplicación)                      │
│         MainActivity + HomeScreen + Navegación          │
└─────────────────────────┬───────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
   ┌─────────┐      ┌──────────┐     ┌──────────────┐
   │ FEATURES│      │   CORE   │     │   HARDWARE   │
   │         │      │  (Shared)│     │  (Periféricos│
   └─────────┘      └──────────┘     └──────────────┘
        │                 │                 │
   ┌────┴────┐       ┌────┼────┬──┐    ┌────┴────┐
   │          │       │    │    │  │    │         │
   ▼          ▼       ▼    ▼    ▼  ▼    ▼         ▼
┌──────┐ ┌──────┐ ┌──┐ ┌──┐ ┌────┐  ┌───────┐ ┌────────┐
│Basic │ │Inter-│ │UI│ │DT│ │NET │  │BT     │ │GPIO    │
│      │ │mediate
│      │ └──────┘ └──┘ └──┘ └────┘  │(Blue) │ │(RasPi) │
└──────┘                            └───────┘ └────────┘

├─ Counter              ├─ Material3   ├─ Room      ├─ Retrofit
├─ TODO List            ├─ Composables ├─ TypedDB   └─ OkHttp
└─ Basic UI             └─ Theme       └─ Entities

├─ API Integration      ├─ Network Requests
├─ MVVM Pattern         └─ Devices
└─ State Management
```

## Flujo de Datos

```
┌────────────┐
│   User     │
│   Action   │
└─────┬──────┘
      │
      ▼
┌──────────────┐
│   Composable │ (UI)
│   Screen     │
└────┬─────────┘
     │
     ▼
┌──────────────┐
│  ViewModel   │ (Lógica)
│  + StateFlow │
└────┬─────────┘
     │
     ▼
┌──────────────────┐
│  Repository      │ (Datos)
│ + Use Cases      │
└────┬─────────────┘
     │
     ├─────┬───────┬──────────┐
     ▼     ▼       ▼          ▼
  ┌────┐┌────┐┌────────┐┌──────────┐
  │Room││API ││Hardware││Shared    │
  │ DB ││REST││Manager ││Preferences
  └────┘└────┘└────────┘└──────────┘
```

## Stack por Capa

```
┌────────────────────────────────────────────┐
│        PRESENTACIÓN (UI Layer)             │
│  Jetpack Compose + Material Design 3       │
└────────────────────┬───────────────────────┘
                     │
┌────────────────────▼───────────────────────┐
│      LÓGICA (Business Logic Layer)         │
│  ViewModel + StateFlow + Coroutines        │
└────────────────────┬───────────────────────┘
                     │
┌────────────────────▼───────────────────────┐
│       DATOS (Data Layer)                   │
│  Repository + Room + Retrofit              │
└────────────────────┬───────────────────────┘
                     │
┌────────────────────▼───────────────────────┐
│      INFRAESTRUCTURA (Hardware)            │
│  Bluetooth + GPIO + Android Things         │
└────────────────────────────────────────────┘
```

## Relaciones entre Módulos

```
app/
  ├── depends on: core/ui, features/*
  
features/basic/
  ├── depends on: core/ui, core/data
  
features/intermediate/
  ├── depends on: core/*, features/basic
  
features/hardware/bluetooth/
  ├── depends on: core/ui, core/data
  
features/hardware/gpio/
  ├── depends on: core/ui, core/data
  ├── requires: Android Things
  
core/ui/
  ├── no external dependencies (excepto Compose)
  
core/data/
  ├── depends on: Room, Hilt
  
core/network/
  ├── depends on: Retrofit, OkHttp
```

## Patrón MVVM por Módulo

```
┌──────────────────────────────────┐
│   Feature Module                 │
├──────────────────────────────────┤
│                                  │
│  ┌──────────────────────────┐   │
│  │ Composables (Screens)    │   │
│  │ - CounterScreen          │   │
│  │ - TodoScreen             │   │
│  │ - BluetoothScreen        │   │
│  └────────────┬─────────────┘   │
│               │                  │
│  ┌────────────▼─────────────┐   │
│  │ ViewModels               │   │
│  │ - CounterViewModel       │   │
│  │ - TodoViewModel          │   │
│  │ - BluetoothViewModel     │   │
│  └────────────┬─────────────┘   │
│               │                  │
│  ┌────────────▼─────────────┐   │
│  │ Repositories (Opcional)  │   │
│  │ - TodoRepository         │   │
│  │ - PostRepository         │   │
│  └────────────┬─────────────┘   │
│               │                  │
│  ┌────────────▼─────────────┐   │
│  │ Data Sources             │   │
│  │ - Remote (API)           │   │
│  │ - Local (Room/SP)        │   │
│  │ - Hardware (GPIO/BT)     │   │
│  └──────────────────────────┘   │
│                                  │
└──────────────────────────────────┘
```

---

**Nota**: Esta arquitectura permite escalabilidad, mantenibilidad y facilita el testing.
