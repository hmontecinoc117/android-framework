Checklist para editar el repositorio

Objetivo: asegurar que cualquier cambio nuevo no introduzca conflictos de compilación ni duplicados.

Pasos antes de editar cualquier archivo:

1. Ejecutar el verificador de duplicados de fuentes (Gradle):

   ./gradlew checkDuplicateSources

   - Si falla, revisar los archivos listados y consolidar/archivar duplicados (mover a `legacy/` o eliminar).

2. Ejecutar una compilación rápida y linter:

   ./gradlew assembleDebug -x lint
   ./gradlew ktlintCheck || ./gradlew detekt

   - Arreglar errores reportados.

3. Formatear código y aplicar convenciones:

   ./gradlew ktlintFormat

4. Pequeños cambios: crear una rama, aplicar cambios, ejecutar `checkDuplicateSources` y `assembleDebug`.

5. Crear PR con descripción breve de cambios y confirmar que CI ejecuta las mismas verificaciones.

Notas:
- Evitar tener la misma clase/archivo con la misma ruta relativa en `src/main/kotlin` y `src/main/java`.
- Si necesitas mantener implementaciones alternativas, muévelas a un paquete `legacy` o `internal/legacy`.
- Añade cualquier nuevo check de formato o lint a este documento si la repo lo requiere.
