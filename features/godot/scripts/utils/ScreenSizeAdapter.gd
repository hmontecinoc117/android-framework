## Adaptador de tamaños de pantalla y resoluciones.
## Provee utilidades estáticas para detectar tipo de dispositivo,
## orientación, safe area y escalado adaptativo.

class_name ScreenSizeAdapter

# --- Enums ---
enum DeviceType {
	PHONE_SMALL,    # < 5"
	PHONE_MEDIUM,   # 5" - 6"
	PHONE_LARGE,    # 6" - 7"
	TABLET_SMALL,   # 7" - 9"
	TABLET_LARGE    # > 9"
}


# ──────────────────────────────────────────────
#  Detección de Dispositivo
# ──────────────────────────────────────────────

## Obtener tipo de dispositivo basado en tamaño de pantalla.
static func get_device_type() -> DeviceType:
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	var diagonal: float = Vector2(screen_size).length()
	var dpi: int = DisplayServer.screen_get_dpi()

	# Estimar diagonal en pulgadas
	var diagonal_inches: float = diagonal / dpi if dpi > 0 else diagonal / 160.0

	if diagonal_inches < 5.0:
		return DeviceType.PHONE_SMALL
	elif diagonal_inches < 6.0:
		return DeviceType.PHONE_MEDIUM
	elif diagonal_inches < 7.0:
		return DeviceType.PHONE_LARGE
	elif diagonal_inches < 9.0:
		return DeviceType.TABLET_SMALL
	else:
		return DeviceType.TABLET_LARGE

## Obtener nombre legible del tipo de dispositivo.
static func get_device_type_name() -> String:
	var device: DeviceType = get_device_type()
	match device:
		DeviceType.PHONE_SMALL:
			return "Teléfono Pequeño"
		DeviceType.PHONE_MEDIUM:
			return "Teléfono Mediano"
		DeviceType.PHONE_LARGE:
			return "Teléfono Grande"
		DeviceType.TABLET_SMALL:
			return "Tablet Pequeña"
		DeviceType.TABLET_LARGE:
			return "Tablet Grande"
		_:
			return "Desconocido"


# ──────────────────────────────────────────────
#  Tamaños Adaptativos
# ──────────────────────────────────────────────

## Obtener tamaño de fuente adaptado al dispositivo.
static func get_adaptive_font_size(base_size: int) -> int:
	var device: DeviceType = get_device_type()

	match device:
		DeviceType.PHONE_SMALL:
			return int(base_size * 0.8)
		DeviceType.PHONE_MEDIUM:
			return base_size
		DeviceType.PHONE_LARGE:
			return int(base_size * 1.1)
		DeviceType.TABLET_SMALL:
			return int(base_size * 1.3)
		DeviceType.TABLET_LARGE:
			return int(base_size * 1.5)
		_:
			return base_size

## Obtener tamaño de botón adaptado al dispositivo.
static func get_adaptive_button_size(base_size: Vector2) -> Vector2:
	var device: DeviceType = get_device_type()

	match device:
		DeviceType.PHONE_SMALL:
			return base_size * 0.9
		DeviceType.PHONE_MEDIUM:
			return base_size
		DeviceType.PHONE_LARGE:
			return base_size * 1.1
		DeviceType.TABLET_SMALL:
			return base_size * 1.4
		DeviceType.TABLET_LARGE:
			return base_size * 1.7
		_:
			return base_size

## Obtener espaciado adaptado al dispositivo.
static func get_adaptive_spacing(base_spacing: float) -> float:
	var device: DeviceType = get_device_type()

	match device:
		DeviceType.PHONE_SMALL:
			return base_spacing * 0.8
		DeviceType.PHONE_MEDIUM:
			return base_spacing
		DeviceType.PHONE_LARGE:
			return base_spacing * 1.1
		DeviceType.TABLET_SMALL:
			return base_spacing * 1.3
		DeviceType.TABLET_LARGE:
			return base_spacing * 1.6
		_:
			return base_spacing


# ──────────────────────────────────────────────
#  Orientación y Viewport
# ──────────────────────────────────────────────

## Verificar si es orientación portrait.
static func is_portrait() -> bool:
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	return screen_size.y > screen_size.x

## Verificar si es orientación landscape.
static func is_landscape() -> bool:
	return not is_portrait()

## Obtener tamaño de viewport.
static func get_viewport_size() -> Vector2i:
	return DisplayServer.screen_get_size()

## Obtener aspect ratio de la pantalla.
static func get_aspect_ratio() -> float:
	var size: Vector2i = get_viewport_size()
	return float(size.x) / float(size.y) if size.y > 0 else 1.0


# ──────────────────────────────────────────────
#  Notch y Safe Area
# ──────────────────────────────────────────────

## Verificar si tiene notch (basado en aspect ratio inusual).
static func has_notch() -> bool:
	var aspect: float = get_aspect_ratio()
	# Aspect ratios comunes con notch: 19.5:9, 20:9, 21:9
	return aspect > 2.0 or aspect < 0.5

## Obtener safe area considerando notch.
static func get_safe_area_rect() -> Rect2i:
	var screen_size: Vector2i = get_viewport_size()
	var safe_rect: Rect2i = Rect2i(Vector2i.ZERO, screen_size)

	if has_notch():
		# Ajustar márgenes para notch
		if is_portrait():
			safe_rect.position.y = 80  # Margen superior
			safe_rect.size.y -= 80
		else:
			safe_rect.position.x = 80  # Margen lateral
			safe_rect.size.x -= 80

	return safe_rect


# ──────────────────────────────────────────────
#  Conversión de Coordenadas
# ──────────────────────────────────────────────

## Convertir posición relativa (0-1) a posición absoluta.
static func relative_to_absolute(relative_pos: Vector2) -> Vector2:
	var screen_size: Vector2i = get_viewport_size()
	return Vector2(
		relative_pos.x * screen_size.x,
		relative_pos.y * screen_size.y
	)

## Convertir posición absoluta a relativa (0-1).
static func absolute_to_relative(absolute_pos: Vector2) -> Vector2:
	var screen_size: Vector2i = get_viewport_size()
	return Vector2(
		absolute_pos.x / screen_size.x if screen_size.x > 0 else 0,
		absolute_pos.y / screen_size.y if screen_size.y > 0 else 0
	)


# ──────────────────────────────────────────────
#  Escalado y DPI
# ──────────────────────────────────────────────

## Escalar nodo según tamaño de pantalla manteniendo aspect ratio.
static func scale_node_to_screen(node: Node2D, base_resolution: Vector2 = Vector2(1080, 1920)) -> void:
	var screen_size: Vector2i = get_viewport_size()
	var scale_factor: Vector2 = Vector2(
		float(screen_size.x) / base_resolution.x,
		float(screen_size.y) / base_resolution.y
	)

	# Usar el factor menor para mantener aspect ratio
	var min_scale: float = min(scale_factor.x, scale_factor.y)
	node.scale = Vector2.ONE * min_scale

## Obtener DPI de la pantalla.
static func get_screen_dpi() -> int:
	var dpi: int = DisplayServer.screen_get_dpi()
	return dpi if dpi > 0 else 160  # 160 es valor por defecto

## Verificar si es pantalla de alta densidad.
static func is_high_density() -> bool:
	return get_screen_dpi() > 300


# ──────────────────────────────────────────────
#  Debug
# ──────────────────────────────────────────────

## Imprimir información de debug de la pantalla.
static func print_screen_info() -> void:
	print("=== Screen Info ===")
	print("Resolución: ", get_viewport_size())
	print("Tipo de dispositivo: ", get_device_type_name())
	print("DPI: ", get_screen_dpi())
	print("Orientación: ", "Portrait" if is_portrait() else "Landscape")
	print("Aspect Ratio: ", get_aspect_ratio())
	print("Tiene Notch: ", has_notch())
	print("Safe Area: ", get_safe_area_rect())
	print("==================")
