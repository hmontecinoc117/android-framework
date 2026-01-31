plugins {
    id("com.android.application") version "8.13.2" apply false
    id("com.android.library") version "8.13.2" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("org.jetbrains.kotlin.jvm") version "2.0.21" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
}

allprojects {
    // Configuración global opcional
}

// Export automático del PCK de Godot y copiado a assets
tasks.register("exportGodotPack") {
    doLast {
        val dst = java.io.File(projectDir, "app/src/main/assets/app_game.pck")
        val godotCmd = listOf("godot4", "--headless", "--path", "features/godot", "--export-pack", "Android", dst.absolutePath)
        println("Ejecutando: ${godotCmd.joinToString(" ")}")
        val proc = ProcessBuilder(godotCmd).inheritIO().start()
        val exit = proc.waitFor()
        if (exit != 0) {
            throw org.gradle.api.GradleException("Fallo exportando PCK (exit=$exit). Ver logs arriba.")
        }
        if (!dst.exists()) throw org.gradle.api.GradleException("No se generó ${dst.absolutePath}")
        println("PCK generado en ${dst.absolutePath}")
    }
}

tasks.register("packageAndInstallDebug") {
    dependsOn("exportGodotPack")
    doLast {
        val assemble = listOf("./gradlew", ":app:assembleDebug")
        val install = listOf("adb", "install", "-r", "app/build/outputs/apk/debug/app-debug.apk")
        val launch = listOf("adb", "shell", "monkey", "-p", "com.framework", "-c", "android.intent.category.LAUNCHER", "1")
        fun run(cmd: List<String>) {
            println("Ejecutando: ${cmd.joinToString(" ")}")
            val proc = ProcessBuilder(cmd).inheritIO().start()
            val exit = proc.waitFor()
            if (exit != 0) throw org.gradle.api.GradleException("Comando falló: ${cmd.joinToString(" ")} (exit=$exit)")
        }
        run(assemble)
        run(install)
        run(launch)
    }
}

// Tarea para detectar archivos fuente duplicados (mismo path relativo) en java/kotlin dentro de cada módulo
tasks.register("checkDuplicateSources") {
    doLast {
        val projectRoot = projectDir
        val conflicts = mutableListOf<String>()

        fun scanModule(moduleDir: java.io.File) {
            val src = java.io.File(moduleDir, "src/main")
            if (!src.exists()) return
            val kotlinFiles = src.walkTopDown().filter { it.isFile && it.extension == "kt" }.toList()
            val relativeMap = mutableMapOf<String, MutableList<java.io.File>>()
            for (f in kotlinFiles) {
                // compute path relative to src/main (preserve subdir and filename)
                val rel = f.relativeTo(src).path
                relativeMap.computeIfAbsent(rel) { mutableListOf() }.add(f)
            }
            for ((rel, files) in relativeMap) {
                if (files.size > 1) {
                    conflicts.add("Module: ${moduleDir.name} -> $rel -> ${files.joinToString { it.path }}")
                }
            }
        }

        // scan each direct subproject folder present in the repo root
        projectRoot.listFiles()?.filter { it.isDirectory }?.forEach { dir ->
            // consider folders that look like gradle modules (have build.gradle(.kts) or src)
            val hasBuild = java.io.File(dir, "build.gradle.kts").exists() || java.io.File(dir, "build.gradle").exists()
            val hasSrc = java.io.File(dir, "src").exists()
            if (hasBuild || hasSrc) scanModule(dir)
        }

        if (conflicts.isNotEmpty()) {
            println("Found duplicate source files with same relative path in module src/main (possible kotlin/java duplicates):")
            conflicts.forEach { println(it) }
            throw org.gradle.api.GradleException("Duplicate source files detected. See output above.")
        } else {
            println("No duplicate Kotlin source paths detected.")
        }
    }
}

// Hacer que la verificación se ejecute antes de compilar Kotlin en cualquier subproyecto
gradle.projectsEvaluated {
    subprojects.forEach { p ->
        p.tasks.matching { it.name.startsWith("compile") && it.name.contains("Kotlin") }.configureEach {
            dependsOn(tasks.named("checkDuplicateSources"))
        }
    }
}
