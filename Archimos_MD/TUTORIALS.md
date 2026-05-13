# Tutoriales - Android Framework

## 📚 Guías paso a paso

### Tutorial 1: Crear una app básica con Contador

#### Objetivo
Crear una pantalla con un contador que se incrementa/decrementa usando ViewModel y StateFlow.

#### Pasos

1. **Crear el ViewModel**
```kotlin
class CounterViewModel : ViewModel() {
    private val _count = MutableStateFlow(0)
    val count: StateFlow<Int> = _count.asStateFlow()

    fun increment() { _count.value++ }
    fun decrement() { _count.value-- }
}
```

2. **Crear la UI con Compose**
```kotlin
@Composable
fun CounterScreen(viewModel: CounterViewModel) {
    val count by viewModel.count.collectAsState()
    
    Column {
        Text("Contador: $count")
        Button(onClick = { viewModel.increment() }) {
            Text("Incrementar")
        }
    }
}
```

3. **Integrar en MainActivity**
```kotlin
setContent {
    AndroidFrameworkTheme {
        CounterScreen()
    }
}
```

---

### Tutorial 2: Lista de Tareas con CRUD

#### Objetivo
Crear un TODO app con funcionalidad completa (Create, Read, Update, Delete).

#### Pasos

1. **Definir el modelo**
```kotlin
data class TodoItem(
    val id: String,
    val title: String,
    val completed: Boolean = false
)
```

2. **Crear ViewModel con lógica CRUD**
```kotlin
class TodoViewModel : ViewModel() {
    private val _todos = MutableStateFlow<List<TodoItem>>(emptyList())
    val todos: StateFlow<List<TodoItem>> = _todos.asStateFlow()

    fun addTodo(title: String) {
        _todos.value = _todos.value + TodoItem(
            id = UUID.randomUUID().toString(),
            title = title
        )
    }

    fun deleteTodo(id: String) {
        _todos.value = _todos.value.filterNot { it.id == id }
    }

    fun toggleTodo(id: String) {
        _todos.value = _todos.value.map { todo ->
            if (todo.id == id) todo.copy(completed = !todo.completed) else todo
        }
    }
}
```

3. **UI con LazyColumn**
```kotlin
@Composable
fun TodoScreen(viewModel: TodoViewModel) {
    val todos by viewModel.todos.collectAsState()

    LazyColumn {
        items(todos) { todo ->
            TodoItemCard(
                todo = todo,
                onToggle = { viewModel.toggleTodo(todo.id) },
                onDelete = { viewModel.deleteTodo(todo.id) }
            )
        }
    }
}
```

---

### Tutorial 3: Consumir una API REST

#### Objetivo
Llamar a una API REST con Retrofit y mostrar datos en la UI.

#### Pasos

1. **Definir el servicio API**
```kotlin
interface PostApiService {
    @GET("posts")
    suspend fun getPosts(): List<Post>
}
```

2. **Crear ViewModel con manejo de estados**
```kotlin
sealed class ApiState<T> {
    class Loading<T> : ApiState<T>()
    data class Success<T>(val data: T) : ApiState<T>()
    data class Error<T>(val exception: Exception) : ApiState<T>()
}

class PostViewModel(private val api: PostApiService) : ViewModel() {
    private val _state = MutableStateFlow<ApiState<List<Post>>>(ApiState.Loading())

    fun loadPosts() {
        viewModelScope.launch {
            try {
                val posts = api.getPosts()
                _state.value = ApiState.Success(posts)
            } catch (e: Exception) {
                _state.value = ApiState.Error(e)
            }
        }
    }
}
```

3. **UI con estados**
```kotlin
@Composable
fun PostsScreen(viewModel: PostViewModel) {
    val state by viewModel.state.collectAsState()

    when (state) {
        is ApiState.Loading -> CircularProgressIndicator()
        is ApiState.Success -> {
            val posts = (state as ApiState.Success).data
            LazyColumn {
                items(posts) { post ->
                    PostCard(post)
                }
            }
        }
        is ApiState.Error -> ErrorCard("Error cargando posts")
    }
}
```

---

### Tutorial 4: Control GPIO con Raspberry Pi

#### Objetivo
Controlar LEDs conectados a un Raspberry Pi desde una app Android.

#### Requisitos
- Raspberry Pi con Android Things
- Android Studio con soporte Android Things
- LEDs conectados a pines GPIO

#### Pasos

1. **Inicializar GPIO**
```kotlin
class GpioManager {
    private var ledPin: DigitalOutputUserDriver? = null

    fun initLed(pinName: String) {
        ledPin = DigitalOutputUserDriver(pinName)
    }

    fun toggleLed() {
        ledPin?.value = !ledPin?.value!!
    }
}
```

2. **ViewModel para GPIO**
```kotlin
class GpioViewModel : ViewModel() {
    private val gpioManager = GpioManager()

    fun toggleLed(pinName: String) {
        gpioManager.toggleLed(pinName)
    }
}
```

3. **UI con switches**
```kotlin
@Composable
fun GpioScreen(viewModel: GpioViewModel) {
    var ledState by remember { mutableStateOf(false) }

    Switch(
        checked = ledState,
        onCheckedChange = {
            ledState = it
            viewModel.toggleLed("GPIO17")
        }
    )
}
```

---

### Tutorial 5: Bluetooth - Conectarse a dispositivos

#### Objetivo
Descubrir y conectarse a dispositivos Bluetooth.

#### Pasos

1. **Permisos en AndroidManifest.xml**
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

2. **BluetoothManager**
```kotlin
class BluetoothManager {
    private val adapter = BluetoothAdapter.getDefaultAdapter()

    fun startDiscovery() {
        adapter?.startDiscovery()
    }

    fun getPairedDevices(): Set<BluetoothDevice> {
        return adapter?.bondedDevices ?: emptySet()
    }
}
```

3. **UI para listar dispositivos**
```kotlin
@Composable
fun BluetoothScreen(viewModel: BluetoothViewModel) {
    val devices by viewModel.devices.collectAsState()

    LazyColumn {
        items(devices.toList()) { device ->
            BluetoothDeviceCard(device)
        }
    }
}
```

---

## 🔗 Recursos Recomendados

- [Documentación Jetpack Compose](https://developer.android.com/jetpack/compose/documentation)
- [Kotlin Coroutines](https://kotlinlang.org/docs/coroutines-overview.html)
- [Android Architecture Components](https://developer.android.com/topic/architecture)
- [Retrofit Tutorial](https://square.github.io/retrofit/)
- [Android Things (GPIO)](https://developer.android.com/things/hardware/raspberrypi)
- [Bluetooth en Android](https://developer.android.com/guide/topics/connectivity/bluetooth)

---

## ❓ Preguntas Frecuentes

### P: ¿Cómo agregar un nuevo módulo?
R: Crear carpeta en `features/`, agregar `build.gradle.kts` e incluir en `settings.gradle.kts`.

### P: ¿Cómo publicar la app en PlayStore?
R: Seguir [esta guía oficial](https://developer.android.com/studio/publish).

### P: ¿Puedo usar este framework en producción?
R: Sí, pero asegúrate de agregar pruebas, logging y manejo de errores robusto.

---

**Última actualización**: Enero 2026
