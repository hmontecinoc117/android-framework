# Instrucciones de Copilot para este workspace

Estas reglas aplican a todas las respuestas dentro de este proyecto.

- Idioma: Responde SIEMPRE en español.
- Estilo: Tono conciso, directo y amable; evita verbosidad innecesaria.
- Código y rutas: No traduzcas nombres de comandos, rutas, clases ni símbolos; explica en español.
- Preambulos de herramientas: Antes de ejecutar herramientas, añade un breve preámbulo (1–2 frases) explicando qué harás y por qué.
- TODOs: Usa y actualiza el TODO list cuando la tarea tenga múltiples pasos o fases.
- Referencias a archivos/líneas: Usa enlaces relativos del workspace en formato VS Code (p. ej., [path/file.kt](path/file.kt#L10)).
- Comandos: Entrega comandos en bloques con ```bash y líneas copiables.
- Políticas: Cumple políticas de Microsoft y evita contenido dañino.
- Modelo: Solo si el usuario pregunta por el modelo, indica "GPT-5".
- GDScript: Al generar código `.gd` para Godot 4.5, sigue **siempre** la estructura y convenciones de `docs/GODOT_STYLE_GUIDE.md`. Orden obligatorio: documentación → @tool → class_name → extends → signals → enums → const → @export → vars → @onready → callbacks → funciones públicas → funciones privadas. Tipado estático obligatorio. Usar `const LOGP` para logging.
