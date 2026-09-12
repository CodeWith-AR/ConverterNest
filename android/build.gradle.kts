allprojects {
    repositories {
        google()
        mavenCentral()
    }
    configurations.all {
        resolutionStrategy.dependencySubstitution {
            substitute(module("com.arthenica:ffmpeg-kit-https"))
                .using(module("dev.ffmpegkit-maintained:ffmpeg-kit-https:8.1.7"))
                .because("com.arthenica binaries removed from Maven Central in 2025; redirected to maintained fork")
            substitute(module("com.arthenica:ffmpeg-kit-full"))
                .using(module("dev.ffmpegkit-maintained:ffmpeg-kit-full:8.1.7"))
                .because("com.arthenica binaries removed from Maven Central in 2025; redirected to maintained fork")
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
