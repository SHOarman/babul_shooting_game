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
}

subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    tasks.configureEach {
        if (name.contains("compile") && name.contains("Kotlin")) {
            try {
                val kotlinOptions = this.javaClass.getMethod("getKotlinOptions").invoke(this)
                val getFreeArgs = kotlinOptions.javaClass.getMethod("getFreeCompilerArgs")
                val setFreeArgs = kotlinOptions.javaClass.getMethod("setFreeCompilerArgs", List::class.java)
                @Suppress("UNCHECKED_CAST")
                val current = (getFreeArgs.invoke(kotlinOptions) as? List<String>) ?: emptyList()
                if (!current.contains("-Xskip-metadata-version-check")) {
                    setFreeArgs.invoke(kotlinOptions, current + "-Xskip-metadata-version-check")
                }
            } catch (_: Throwable) {}
            try {
                val compOpts = this.javaClass.getMethod("getCompilerOptions").invoke(this)
                val freeArgs = compOpts.javaClass.getMethod("getFreeCompilerArgs").invoke(compOpts)
                freeArgs.javaClass.getMethod("add", Object::class.java).invoke(freeArgs, "-Xskip-metadata-version-check")
            } catch (_: Throwable) {}
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
