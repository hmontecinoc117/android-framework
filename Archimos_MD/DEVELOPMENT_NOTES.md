# NOTAS DE DESARROLLO - Kids Educational Games

## ✅ Mejoras Aplicadas (Memorizar)

### 1. **Sistema de Input Manual**
- **Problema**: Los botones nativos de Godot no respondían al touch en Android
- **Solución**: Implementar `_input()` con detección manual:
  ```gdscript
  func _input(event):
      if event is InputEventScreenTouch and not event.pressed:
          check_button_click(event.position)
  
  func check_button_click(pos: Vector2):
      if button and button.get_global_rect().has_point(pos):
          button.pressed.emit()
  ```

### 2. **Proceso de Build**
**CRÍTICO**: El .pck NO se actualiza automáticamente
```bash
# Pasos obligatorios en cada cambio:
cd features/godot
rm -f game.pck
godot4 --headless --export-pack "Android" game.pck
cp -f game.pck ../../app/src/main/assets/
cd ../..
./gradlew assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

### 3. **Configuración de Botones**
Para que funcionen en Android:
```gdscript
button.custom_minimum_size = Vector2(800, 300)  # GRANDE
button.add_theme_font_size_override("font_size", 120)
button.focus_mode = Control.FOCUS_NONE
button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
```

### 4. **Viewport**
- Física del dispositivo: 1080x2168
- Godot crea viewport: 1920x3854 (debido a stretch mode)
- **No importa**: El sistema de click manual funciona con cualquier resolución

### 5. **Estructura Simplificada**
```
MainMenu.gd → Botones grandes con _input()
GameSelector.gd → Grid de juegos con click manual
TraceGame.gd → Juego simple con input directo
```

## 🚀 Script de Deploy Rápido
Usar `./deploy.sh` para automatizar todo el proceso

## 📱 Testing
```bash
# Ver logs en tiempo real
adb logcat | grep "godot"

# Ver última ejecución
adb logcat -d | grep "I godot" | tail -30

# Reiniciar app
adb shell am force-stop com.framework
adb shell am start -n com.framework/.MainActivity
```

## ⚠️ Problemas Comunes

### Botones no responden
- ✅ Verificar que `_input()` esté implementado
- ✅ Usar `set_process_input(true)` en `_ready()`
- ✅ Check manual con `get_global_rect().has_point(pos)`

### .pck desactualizado
- ✅ Siempre borrar `game.pck` antes de exportar
- ✅ Copiar manualmente a `app/src/main/assets/`
- ✅ Hacer `clean build` si es necesario

### Errores de sintaxis
- ✅ Verificar logs: `adb logcat -d | grep "godot" | grep "ERROR"`
- ✅ Los errores impiden que se cargue la escena

## 📝 Próximos Pasos
1. ✅ MainMenu funcional
2. ✅ GameSelector con botones grandes
3. ✅ TraceGame básico
4. ⏳ Implementar más juegos
5. ⏳ Agregar animaciones
6. ⏳ Sistema de progreso
