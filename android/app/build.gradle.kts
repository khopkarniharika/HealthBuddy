plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.heart_rate_monitor"
    // Compile against the latest SDK required by plugins (36)
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.heart_rate_monitor"
        // Per your requirement: minSdk 21, keep targetSdk 34 (runtime behavior),
        // but we compile with SDK 36 above for plugin compatibility.
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required for some dependencies (e.g. flutter_local_notifications)
        // that use newer Java APIs.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // Kotlin JVM target 17 as required by recent AGP
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Desugaring support library for Java 8+ APIs on older Android versions.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
