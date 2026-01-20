allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Fix for plugins missing 'namespace' in AGP 8.0+
    // This hook injects the required namespace into older plugins at build time
    project.plugins.withType<com.android.build.gradle.api.AndroidBasePlugin> {
        val android = project.extensions.getByType<com.android.build.gradle.BaseExtension>()
        
        if (android.namespace == null) {
            if (project.name == "flutter_bluetooth_serial") {
                android.namespace = "io.github.edufolly.flutterbluetoothserial"
            } else {
                // Fallback for other potential plugins
                android.namespace = "com.example.she_secure.${project.name.replace("-", "_")}"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
