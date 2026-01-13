plugins {
    id("com.android.application")
<<<<<<< HEAD
=======
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
>>>>>>> origin/master
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.breezefood"
    compileSdk = flutter.compileSdkVersion
<<<<<<< HEAD
    ndkVersion = flutter.ndkVersion
=======

    // ✅ FIX NDK (مثل اللي اشتغل معك)
    ndkVersion = "27.0.12077973"
>>>>>>> origin/master

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
<<<<<<< HEAD
=======

        // ✅ REQUIRED for flutter_local_notifications وغيره
        isCoreLibraryDesugaringEnabled = true
>>>>>>> origin/master
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
<<<<<<< HEAD
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.breezefood"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
=======
        applicationId = "com.example.breezefood"

        // ✅ FIX for firebase_messaging (minSdk 23)
        minSdk = flutter.minSdkVersion

>>>>>>> origin/master
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
<<<<<<< HEAD
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
=======
>>>>>>> origin/master
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
<<<<<<< HEAD
=======

// ✅ REQUIRED (desugar version 2.1.4+)
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
>>>>>>> origin/master
