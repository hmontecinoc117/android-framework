pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "AndroidFramework"

include(":app")
include(":core:ui")
include(":core:data")
include(":core:network")
include(":features:basic")
include(":features:intermediate")
include(":features:hardware:bluetooth")
include(":features:hardware:gpio")
include(":features:godot")
include(":build-logic")
include(":features:tracing")
