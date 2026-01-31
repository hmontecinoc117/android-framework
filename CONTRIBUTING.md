# Guía de Contribución

## Cómo contribuir al Framework

### 1. Agregar nuevas features

1. Crear carpeta en `features/FEATURE_NAME`
2. Crear `build.gradle.kts` con dependencias
3. Implementar código en `src/main/kotlin/`
4. Agregar en `settings.gradle.kts`

### 2. Estándares de código

- **Nomenclatura**: camelCase para variables, PascalCase para clases
- **Composables**: Función por archivo, con `@Composable` annotation
- **ViewModels**: Extender `ViewModel` y usar `StateFlow`
- **Comentarios**: Documentar funciones públicas

### 3. Estructura de features

```
features/mi_feature/
├── src/main/kotlin/com/framework/features/mi_feature/
│   ├── MiFeatureViewModel.kt    # Lógica
│   ├── MiFeatureScreen.kt       # UI
│   ├── MiFeatureModel.kt        # Modelos de datos
│   └── MiFeatureRepository.kt   # (Opcional) Acceso a datos
├── src/test/kotlin/...          # Tests
└── build.gradle.kts
```

### 4. Testing

```kotlin
// Ejemplo de test
class CounterViewModelTest {
    @get:Rule
    val instantExecutorRule = InstantTaskExecutorRule()

    private lateinit var viewModel: CounterViewModel

    @Before
    fun setup() {
        viewModel = CounterViewModel()
    }

    @Test
    fun incrementTest() {
        viewModel.increment()
        // Verificar resultado
    }
}
```

### 5. Pull Request

1. Fork el repositorio
2. Crear rama: `git checkout -b feature/mi-feature`
3. Hacer cambios y tests
4. Commit: `git commit -m "feat: agregar nueva feature"`
5. Push y crear PR

---

**Gracias por contribuir!**
