## Script para generar placeholders de assets faltantes
## Se ejecuta en el editor de Godot para crear imágenes temporales

extends EditorScript

const LOGP := "[AssetPlaceholderGenerator] "

# Rutas de assets que suelen faltar
const MISSING_ASSETS := {
	"animals": [
		"res://assets/images/animals/perro.png",
		"res://assets/images/animals/gato.png",
		"res://assets/images/animals/leon.png",
		"res://assets/images/animals/elephant.png",
		"res://assets/images/animals/giraffe.png",
		"res://assets/images/animals/mono.png",
		"res://assets/images/animals/bear.png",
		"res://assets/images/animals/panda.png",
		"res://assets/images/animals/vaca.png",
		"res://assets/images/animals/oveja.png",
		"res://assets/images/animals/zorro.png"
	],
	"vehicles": [
		"res://assets/images/vehicles/car.png",
		"res://assets/images/vehicles/plane.png",
		"res://assets/images/vehicles/boat.png",
		"res://assets/images/vehicles/bike.png"
	],
	"nature": [
		"res://assets/images/nature/tree.png",
		"res://assets/images/nature/flower.png"
	],
	"ui": [
		"res://assets/images/ui/button_grey.png",
		"res://assets/images/ui/button_red_close.png"
	],
	"placeholder": [
		"res://assets/images/placeholder_card.png"
	]
}

# Colores por categoría
const CATEGORY_COLORS := {
	"animals": Color(0.85, 0.65, 0.45),  # Marrón claro
	"vehicles": Color(0.5, 0.6, 0.8),    # Azul claro
	"nature": Color(0.4, 0.75, 0.4),     # Verde
	"ui": Color(0.7, 0.7, 0.7),          # Gris
	"placeholder": Color(0.9, 0.5, 0.5)  # Rosa
}

func _run() -> void:
	print(LOGP, "Iniciando generación de placeholders...")
	
	var created_count := 0
	var skipped_count := 0
	
	for category in MISSING_ASSETS:
		var color := CATEGORY_COLORS.get(category, Color.GRAY)
		
		for asset_path in MISSING_ASSETS[category]:
			if ResourceLoader.exists(asset_path):
				print(LOGP, "⏭️  Existe: ", asset_path)
				skipped_count += 1
				continue
			
			# Crear directorio si no existe
			var dir_path := asset_path.get_base_dir()
			if not DirAccess.dir_exists_absolute(dir_path):
				DirAccess.make_dir_recursive_absolute(dir_path)
				print(LOGP, "📁 Creado directorio: ", dir_path)
			
			# Generar placeholder
			var success := _create_placeholder_image(asset_path, color, category)
			if success:
				print(LOGP, "✅ Creado: ", asset_path)
				created_count += 1
			else:
				print(LOGP, "❌ Error: ", asset_path)
	
	print(LOGP, "=" * 50)
	print(LOGP, "Resumen:")
	print(LOGP, "  Creados: ", created_count)
	print(LOGP, "  Omitidos (ya existían): ", skipped_count)
	print(LOGP, "=" * 50)

func _create_placeholder_image(path: String, base_color: Color, category: String) -> bool:
	"""Crea una imagen placeholder de 512x512"""
	var img := Image.create(512, 512, false, Image.FORMAT_RGBA8)
	
	# Fondo con gradiente
	for y in 512:
		for x in 512:
			var t := float(y) / 512.0
			var color := base_color.lerp(base_color.darkened(0.3), t)
			# Agregar un poco de textura
			var noise := (sin(x * 0.1) + sin(y * 0.1)) * 0.05
			color = color.lightened(noise)
			img.set_pixel(x, y, color)
	
	# Agregar borde
	for i in 512:
		for thickness in 8:
			# Borde superior
			img.set_pixel(i, thickness, Color.WHITE)
			# Borde inferior
			img.set_pixel(i, 511 - thickness, Color.WHITE)
			# Borde izquierdo
			img.set_pixel(thickness, i, Color.WHITE)
			# Borde derecho
			img.set_pixel(511 - thickness, i, Color.WHITE)
	
	# Guardar imagen
	var err := img.save_png(path)
	return err == OK

func _get_asset_name(path: String) -> String:
	"""Extrae el nombre del asset desde la ruta"""
	return path.get_file().get_basename()
