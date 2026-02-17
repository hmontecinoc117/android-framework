plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

// Tarea personalizada para exportar el proyecto Godot a .pck
tasks.register<Exec>("exportGodotPack") {
    group = "godot"
    description = "Exporta el proyecto Godot a un archivo .pck para Android"
    
    workingDir = projectDir
    
    // Comando para exportar (requiere godot4 en PATH o usar ruta completa)
    val godotCommand = System.getenv("GODOT_BIN") ?: "godot4"
    commandLine(godotCommand, "--headless", "--export-pack", "Android", "app_game.pck")
    
    // Limpiar PCK anterior
    doFirst {
        val pckFile = file("app_game.pck")
        if (pckFile.exists()) {
            println("🗑️  Eliminando PCK anterior...")
            pckFile.delete()
        }
    }
    
    // Copiar a assets después de exportar
    doLast {
        val pckSource = file("app_game.pck")
        val pckDest = file("../../app/src/main/assets/app_game.pck")
        
        if (!pckSource.exists()) {
            throw GradleException("❌ Error: No se generó el archivo .pck")
        }
        
        val size = pckSource.length()
        if (size < 100_000) {
            throw GradleException("❌ Error: PCK demasiado pequeño (${size} bytes)")
        }
        
        println("📦 PCK generado: ${size / 1024}KB")
        
        pckDest.parentFile.mkdirs()
        pckSource.copyTo(pckDest, overwrite = true)
        
        println("✅ PCK copiado a assets")
    }
}

// Tarea para verificar que Godot está disponible
tasks.register<Exec>("checkGodotInstallation") {
    group = "godot"
    description = "Verifica que Godot esté instalado y accesible"
    
    val godotCommand = System.getenv("GODOT_BIN") ?: "godot4"
    commandLine(godotCommand, "--version")
    
    isIgnoreExitValue = true
    
    doLast {
        if (executionResult.get().exitValue != 0) {
            println("⚠️  Godot no encontrado. Instala Godot 4.x o configura GODOT_BIN")
            println("   Ejemplo: export GODOT_BIN=/opt/godot/godot")
        }
    }
}

// Hacer que las tareas de Android dependan de la exportación de Godot
// Solo si Godot está disponible (no obligatorio para CI sin Godot)
if (System.getenv("SKIP_GODOT_EXPORT") != "true") {
    tasks.matching { it.name == "preBuild" }.configureEach {
        dependsOn("exportGodotPack")
    }
}

android {
    namespace = "com.framework.features.godot"
    compileSdk = 35

    defaultConfig {
        minSdk = 24
        targetSdk = 35
    }

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.14"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    // Godot AAR - compileOnly permite compilar contra él sin empaquetarlo
    compileOnly(files("../../app/libs/godot-lib.aar"))
    
    // Jetpack Compose
    implementation("androidx.compose.ui:ui:1.5.4")
    implementation("androidx.compose.foundation:foundation:1.5.4")
    implementation("androidx.compose.material3:material3:1.1.2")
    
    // Android Core
    implementation("androidx.core:core-ktx:1.13.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.2")
    
    // Core módulos del framework
    implementation(project(":core:ui"))
}
