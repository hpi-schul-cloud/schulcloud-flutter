import 'dart:io' as io;
import 'dart:io' hide exit;

import 'package:git/git.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

// ignore_for_file: avoid_print

const locales = ['en-US', 'de-DE'];

Future<void> main() async {
  final path = p.current;
  require(
    await GitDir.isGitDir(path),
    'The current directory is not a Git directory.',
  );

  final git = await GitDir.fromExisting(path);
  require(
    (await git.currentBranch()).branchName == 'master',
    'You must start the release process from the master branch.',
  );

  final pubspecFile = File('./pubspec.yaml');
  require(
    pubspecFile.existsSync(),
    'Pubspec file not found, checked ${pubspecFile.absolute.path}).',
  );

  final version = updateVersion(pubspecFile);
  final branchCreationResult =
      Process.runSync('git', ['checkout', '-b', 'release/v$version']);
  require(
    branchCreationResult.exitCode >= 0,
    "Couldn't create release branch (exit code ${branchCreationResult.exitCode}).",
  );

  requireChangelogs(version.versionCode);
}

Version updateVersion(File pubspecFile) {
  final pubspec = pubspecFile.readAsLinesSync();
  final pubspecVersionIndex =
      pubspec.indexWhere((line) => line.startsWith('version:'));
  require(
    pubspecVersionIndex >= 0,
    'No version specified in ${pubspecFile.absolute.path}',
  );
  final pubspecVersion =
      pubspec[pubspecVersionIndex].replaceFirst('version:', '').trim();
  Version currentVersion;
  try {
    currentVersion = Version.parse(pubspecVersion);
  } on FormatException {
    exit("Error: Couldn't parse current version.");
  }

  stdout.write('Version (current: $currentVersion): ');
  final versionString = stdin.readLineSync().trim();
  Version version;
  try {
    version = Version.parse(versionString);
  } on FormatException {
    exit("Error: Couldn't parse version.");
  }
  require(
    version > currentVersion,
    'The new version ($version} must be greater than the current version ($currentVersion)',
  );

  pubspecFile.writeAsStringSync([
    ...pubspec.sublist(0, pubspecVersionIndex),
    'version: $version',
    ...pubspec.sublist(pubspecVersionIndex + 1, pubspec.length),
  ].map((line) => '$line\r\n').join());
  print('Updated version in pubspec.dart');

  return version;
}

void requireChangelogs(int versionCode) {
  print(
      'Please add the required changelogs and then press [Enter] to continue:');
  for (final locale in locales) {
    print(
        '• ./android/fastlane/metadata/android/$locale/changelogs/$versionCode.txt');
  }
  stdin.readLineSync();
}

extension on Version {
  int get versionCode {
    require(
      0 <= major && major <= 20,
      'Major must be between 0 and 20, was $major.',
    );
    require(
      0 <= minor && minor <= 99,
      'Minor must be between 0 and 99, was $minor.',
    );
    require(
      0 <= patch && patch <= 99,
      'Patch must be between 0 and 99, was $patch.',
    );

    var previewCode = 0;
    if (preRelease != null) {
      require(
        preRelease.length >= 2,
        'Invalid prerelease: ${preRelease.join('.')}',
      );
      final preview = preRelease[0] as String;
      final previewVersion = preRelease[1] as int;
      require(
        0 <= previewVersion && previewVersion <= 999,
        'Preview version must be between 0 and 999, was $previewVersion.',
      );

      int previewBaseCode;
      switch (preview.toLowerCase()) {
        case 'canary':
          previewBaseCode = 2;
          break;
        case 'alpha':
          previewBaseCode = 4;
          break;
        case 'beta':
          previewBaseCode = 5;
          break;
        case 'rc':
          previewBaseCode = 8;
          break;
        default:
          exit('Error: Unknown preview $preview.');
      }
      previewCode = previewBaseCode * 1000 + previewVersion;
    }

    return ((major * 100 + minor) * 100 + patch) * 10000 + previewCode;
  }
}

void exit(String message) {
  print(message);
  io.exit(-1);
}

// ignore: avoid_positional_boolean_parameters
void require(bool expression, String errorMessage) {
  if (!expression) {
    exit('Error: $errorMessage');
  }
}
