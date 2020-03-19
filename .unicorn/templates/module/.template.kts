val module = prompt("Module name (lowercase; used as the folder name)")
val modulePath = "lib/$module"
if (baseDir.resolve(modulePath).exists()) {
    exit("directory $modulePath already exists")
}
variables["module"] = module

variables["entity"] = prompt("Main entity class")

copy("module.dart", "$modulePath/$module.dart")
copy("data.dart.ftl", "$modulePath/data.dart")

copy("routes.dart.ftl", "$modulePath/routes.dart")
log.i("Please remember to register the new routes in lib/app/routing.dart")
