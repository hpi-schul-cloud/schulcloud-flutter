val module = prompt("Module name (lowercase; used as the folder name)")
val modulePath = "lib/$module"
if (baseDir.resolve(modulePath).exists()) {
    exit("directory $modulePath already exists")
}
variables["module"] = module

variables["entity"] = prompt("Main entity class")

copyDir("module", modulePath)
