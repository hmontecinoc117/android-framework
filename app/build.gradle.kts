plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "com.framework"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.framework"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.14"
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
            // Evitar conflictos con librerías nativas de Godot
            pickFirst("lib/armeabi-v7a/libc++_shared.so")
            pickFirst("lib/arm64-v8a/libc++_shared.so")
            pickFirst("lib/x86/libc++_shared.so")
            pickFirst("lib/x86_64/libc++_shared.so")
        }
    }
}

dependencies {
    // Godot Engine Library
    implementation(files("libs/godot-lib.aar"))
    
    // AndroidX
    implementation("androidx.core:core-ktx:1.13.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.2")
    implementation("androidx.activity:activity-compose:1.8.1")

    // Compose
    implementation(platform("androidx.compose:compose-bom:2024.01.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")

    // Navigation
    implementation("androidx.navigation:navigation-compose:2.7.5")

    // Hilt
    implementation("com.google.dagger:hilt-android:2.48.1")
    annotationProcessor("com.google.dagger:hilt-compiler:2.48.1")

    // Features
    implementation(project(":features:tracing"))
    implementation(project(":features:godot"))

    // Testing
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    androidTestImplementation(platform("androidx.compose:compose-bom:2024.01.00"))
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
}

// Tarea para renombrar el APK debug después del build a Juegos_GustaNuno.apk
tasks.register("renameDebugApk") {
    doLast {
        val src = file("${buildDir}/outputs/apk/debug/app-debug.apk")
        val dst = file("${buildDir}/outputs/apk/debug/Juegos_GustaNuno.apk")
        if (src.exists()) {
            src.copyTo(dst, overwrite = true)
            println("APK copiado a ${'$'}{dst.absolutePath}")
        } else {
            println("APK no encontrado: ${'$'}{src.absolutePath}")
        }
    }
}

// Vincular la tarea de renombrado después de que se evalúen los proyectos y existan las tareas de ensamblado
gradle.projectsEvaluated {
    tasks.matching { it.name == "assembleDebug" }.configureEach {
        finalizedBy(tasks.named("renameDebugApk"))
    }
    // Asegurar que el .pck de Godot esté actualizado antes de cualquier build del app
    tasks.matching { it.name == "preBuild" }.configureEach {
        dependsOn(gradle.rootProject.tasks.named("exportGodotPack"))
    }
}
