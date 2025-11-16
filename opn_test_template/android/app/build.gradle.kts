plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.isyfu.opn.template"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Base application ID (será sobrescrito por cada flavor)
        applicationId = "com.isyfu.opn.template"

        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ════════════════════════════════════════════════════════════════
    // CONFIGURACIÓN DE SIGNING POR FLAVOR
    // ════════════════════════════════════════════════════════════════
    // Cada flavor tiene su propio keystore en flavors/<flavor>/android/

    signingConfigs {
        // Signing config para Guardia Civil
        create("guardiaCivil") {
            val keystorePropertiesFile = rootProject.file("../../flavors/guardia_civil/android/key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = java.util.Properties()
                keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))

                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = rootProject.file("../../flavors/guardia_civil/android/${keystoreProperties["storeFile"]}")
                storePassword = keystoreProperties["storePassword"] as String
            } else {
                println("⚠️  WARNING: No se encontró key.properties para guardiaCivil")
            }
        }

        // Signing config para Policía Nacional
        create("policiaNacional") {
            val keystorePropertiesFile = rootProject.file("../../flavors/policia_nacional/android/key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = java.util.Properties()
                keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))

                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = rootProject.file("../../flavors/policia_nacional/android/${keystoreProperties["storeFile"]}")
                storePassword = keystoreProperties["storePassword"] as String
            } else {
                println("⚠️  WARNING: No se encontró key.properties para policiaNacional")
            }
        }

        // TODO: Agregar signing configs para otros flavors aquí
    }

    // ════════════════════════════════════════════════════════════════
    // PRODUCT FLAVORS
    // ════════════════════════════════════════════════════════════════

    flavorDimensions += "app"

    productFlavors {
        create("guardiaCivil") {
            dimension = "app"
            applicationId = "com.isyfu.opn.guardiacivil"
            versionNameSuffix = "-gc"

            // Configurar el nombre de la app (se mostrará en el launcher)
            resValue("string", "app_name", "OPN Test Guardia Civil")

            // Configuración de signing
            signingConfig = signingConfigs.getByName("guardiaCivil")
        }

        create("policiaNacional") {
            dimension = "app"
            applicationId = "com.oposicionespolicianacional.app"
            versionNameSuffix = "-pn"

            // Configurar el nombre de la app (se mostrará en el launcher)
            resValue("string", "app_name", "OPN Test Policía Nacional")

            // Configuración de signing
            signingConfig = signingConfigs.getByName("policiaNacional")
        }

        // TODO: Agregar otros flavors aquí
    }

    buildTypes {
        release {
            // El signingConfig se toma del flavor, no aquí
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isDebuggable = true
            isMinifyEnabled = false
        }
    }

    // ════════════════════════════════════════════════════════════════
    // SOURCE SETS POR FLAVOR
    // ════════════════════════════════════════════════════════════════
    // Permite tener AndroidManifest.xml y recursos específicos por flavor

    sourceSets {
        named("guardiaCivil") {
            // Manifest específico del flavor (opcional)
            // manifest.srcFile("src/guardiaCivil/AndroidManifest.xml")

            // Recursos específicos del flavor (opcional)
            // res.srcDirs("src/guardiaCivil/res")
        }

        named("policiaNacional") {
            // Manifest específico del flavor (opcional)
            // manifest.srcFile("src/policiaNacional/AndroidManifest.xml")

            // Recursos específicos del flavor (opcional)
            // res.srcDirs("src/policiaNacional/res")
        }

        // TODO: Agregar source sets para otros flavors
    }
}

flutter {
    source = "../.."
}