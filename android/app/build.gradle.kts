import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun signingValue(envName: String, propertyName: String): String? {
    return System.getenv(envName)?.takeIf { it.isNotBlank() }
        ?: keystoreProperties.getProperty(propertyName)?.takeIf { it.isNotBlank() }
}

android {
    namespace = "bw.kgwebo.kgwebo"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "bw.kgwebo.kgwebo"
        minSdk = maxOf(flutter.minSdkVersion, 24)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storeFilePath = signingValue("KGWEBO_STORE_FILE", "storeFile")
            val storePasswordValue = signingValue("KGWEBO_STORE_PASSWORD", "storePassword")
            val keyAliasValue = signingValue("KGWEBO_KEY_ALIAS", "keyAlias")
            val keyPasswordValue = signingValue("KGWEBO_KEY_PASSWORD", "keyPassword")
            if (
                storeFilePath != null &&
                storePasswordValue != null &&
                keyAliasValue != null &&
                keyPasswordValue != null
            ) {
                storeFile = rootProject.file(storeFilePath)
                storePassword = storePasswordValue
                keyAlias = keyAliasValue
                keyPassword = keyPasswordValue
            }
        }
    }

    buildTypes {
        release {
            val releaseSigning = signingConfigs.getByName("release")
            val configured =
                releaseSigning.storeFile != null &&
                    !releaseSigning.storePassword.isNullOrBlank() &&
                    !releaseSigning.keyAlias.isNullOrBlank() &&
                    !releaseSigning.keyPassword.isNullOrBlank()
            if (configured) {
                signingConfig = releaseSigning
            }
        }
    }
}

flutter {
    source = "../.."
}

tasks.matching {
    it.name.startsWith("assembleRelease") || it.name.startsWith("bundleRelease")
}.configureEach {
    doFirst {
        val releaseSigning = android.signingConfigs.getByName("release")
        val store = releaseSigning.storeFile
        val configured =
            store != null &&
                !releaseSigning.storePassword.isNullOrBlank() &&
                !releaseSigning.keyAlias.isNullOrBlank() &&
                !releaseSigning.keyPassword.isNullOrBlank()
        if (!configured) {
            throw GradleException(
                "Release signing credentials are missing. Copy android/key.properties.example " +
                    "to android/key.properties (gitignored) or set KGWEBO_STORE_FILE, " +
                    "KGWEBO_STORE_PASSWORD, KGWEBO_KEY_ALIAS, and KGWEBO_KEY_PASSWORD. " +
                    "Debug builds still work without this file. Do not sign a release with the debug keystore.",
            )
        }
        if (store?.exists() != true) {
            throw GradleException("Release keystore was not found: $store")
        }
    }
}
