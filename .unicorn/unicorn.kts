import com.google.auth.oauth2.GoogleCredentials
import com.jonaswanke.unicorn.action.*
import com.jonaswanke.unicorn.api.*
import com.jonaswanke.unicorn.api.github.*
import com.jonaswanke.unicorn.core.*
import com.jonaswanke.unicorn.core.ProjectConfig.*
import com.jonaswanke.unicorn.script.*
import com.jonaswanke.unicorn.script.parameters.*
import com.jonaswanke.unicorn.template.*
import java.io.File
import java.util.*
import net.swiftzer.semver.SemVer


fun SemVer.versionCode(): Int {
    require(major in 0..20) { "major must be between 0 and 20, was $major" }
    require(minor in 0..99) { "minor must be between 0 and 99, was $minor" }
    require(patch in 0..99) { "patch must be between 0 and 99, was $patch" }

    val preRelease = preRelease
    val previewCode = if (preRelease != null) {
        require(preRelease.contains('.'))
        val preview = preRelease.substringBefore('.')
        val previewVersion = preRelease.substringAfter('.').toInt()
        require(previewVersion in 0..999) { "preview version must be between 0 and 999, was $previewVersion" }

        val previewBaseCode = when (preview.toLowerCase()) {
            "canary" -> 2
            "alpha" -> 4
            "beta" -> 5
            "rc" -> 8
            else -> throw IllegalArgumentException("Unknown preview: $preview")
        }
        previewBaseCode * 1000 + previewVersion
    } else 0

    return ((major * 100 + minor) * 100 + patch) * 10000 + previewCode
}

val CANARY = "canary"

unicorn {
    gitHubAction {
        when (val event = this.event) {
            is Action.Event.Push -> {
                if (git.flow.currentBranch(this) !is Git.Flow.MasterBranch)
                    return@gitHubAction

                val serviceAccountFile = File("./android/fastlane/googlePlay-serviceAccount.json")
                val credentials = GoogleCredentials.fromStream(serviceAccountFile.inputStream())
                    .createScoped("https://www.googleapis.com/auth/androidpublisher")
                val releases = Google.Play.getReleases(credentials, "org.schulcloud.android", "internal")

                val currentVersion = releases.map { it.version }.max() ?: error("No releases found")
                val currentPreRelease = currentVersion.preRelease
                val version = if (currentPreRelease == null || !currentPreRelease.startsWith(CANARY))
                    currentVersion.nextPatch.copy(preRelease = "$CANARY.0")
                else {
                    val canaryRelease = currentPreRelease.substring(CANARY.length + 1).toInt()
                    currentVersion.copy(preRelease = "$CANARY.${canaryRelease + 1}")
                }
                val versionCode = version.versionCode()
                Action.setOutput("version", version.toString())
                Action.setOutput("versionCode", versionCode.toString())

                val commit = git.getHeadCommit(this)
                Fastlane.saveChangelog(
                    this,
                    versionCode,
                    contents = mapOf(
                        Locale.US to "Canary deployment of commit ${commit.name}:\n${commit.fullMessage}",
                        Locale.GERMANY to "Canary-Deployment von Commit ${commit.name}:\n${commit.fullMessage}"
                    ),
                    directory = projectDir.resolve("android/fastlane")
                )
            }
        }
    }
}
