allprojects {
    repositories {
        google()
        mavenCentral()
        // Mapbox Maps SDK (native Android AAR). Requires a *secret* downloads
        // token from https://console.mapbox.com/account/access-tokens/ with the
        // "Downloads:Read" scope. Put it in ~/.gradle/gradle.properties (NOT this
        // repo) as: MAPBOX_DOWNLOADS_TOKEN=sk.xxx
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
            authentication {
                create<BasicAuthentication>("basic")
            }
            credentials {
                username = "mapbox"
                password = (providers.gradleProperty("MAPBOX_DOWNLOADS_TOKEN").orNull ?: "")
            }
        }
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
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
