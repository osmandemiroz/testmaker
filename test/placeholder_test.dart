// ********************************************************************************************
//  Basic placeholder test file for CI
//
//  This project did not previously include any automated tests, but our GitHub
//  Actions workflow (see `.github/workflows/test-and-build.yaml`) runs
//  `flutter test` on every push / pull request as part of the CI pipeline
//  described in the "Setting up CI/CD for Flutter Apps" article.
//
//  Flutter expects a `test/` directory to exist; if it is missing, the
//  `flutter test` command exits with a non‑zero status code and causes the
//  workflow to fail even though the application itself is fine.
//
//  This simple test ensures:
//  - The `test/` directory exists
//  - `flutter test` has at least one passing test to execute
//  - We keep the CI pipeline green while we gradually add real tests later
//
//  When you start introducing real unit/widget tests for the app, you can:
//  - Keep this file as a smoke test, or
//  - Remove it once there are meaningful tests covering the functionality.
// ********************************************************************************************

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder smoketest for CI', () {
    // Simple assertion just to prove that the test harness is wired correctly.
    expect(1, 1);
  });
}
