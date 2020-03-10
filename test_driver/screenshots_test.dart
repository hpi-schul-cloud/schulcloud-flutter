import 'package:flutter_driver/flutter_driver.dart';
import 'package:screenshots/screenshots.dart';
import 'package:test/test.dart';

void main() {
  group('Screenshot', () {
    // Note: We use the same app instance for all "tests".

    final config = Config();

    FlutterDriver driver;
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });
    tearDownAll(() async {
      await driver.close();
    });

    test('SignInScreen', () async {
      await screenshot(driver, config, 'signIn');
    });

    test('DashboardScreen', () async {
      await driver.tap(find.byValueKey('signIn-demoTeacher'));
      await screenshot(driver, config, 'dashboard');
    });

    group('course', () {
      test('CoursesScreen', () async {
        await driver.tap(find.byValueKey('navigation-course'));
        await screenshot(driver, config, 'courses');
      });
      test('CourseDetailScreen', () async {
        await driver.tap(find.text('🦠 Biologie 10b'));
        await screenshot(driver, config, 'course');
      });
    });

    group('assignment', () {
      test('AssignmentsScreen', () async {
        await driver.tap(find.byValueKey('navigation-assignment'));
        await screenshot(driver, config, 'assignments');
      });
      test('AssignmentDetailsScreen', () async {
        await driver.tap(find.text('Würfelspiel - Gruppenarbeit'));
        await screenshot(driver, config, 'assignment');
      });
    });
  });
}
