import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release builds do not fall back to debug signing', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, isNot(contains('signingConfigs.getByName("debug")')));
    expect(gradle, contains('assembleRelease'));
    expect(gradle, contains('Release signing credentials are missing'));
    expect(gradle, contains('KGWEBO_STORE_FILE'));
  });

  test('keystore example and gitignore keep secrets out of source control', () {
    final example = File('android/key.properties.example').readAsStringSync();
    expect(example, contains('storeFile='));
    expect(example, contains('storePassword='));
    expect(example, isNot(contains('storePassword=secret')));
    expect(example, isNot(contains('keyPassword=secret')));

    final gitignore = File('.gitignore').readAsStringSync();
    expect(gitignore, contains('android/key.properties'));
    expect(gitignore, contains('*.jks'));
    expect(gitignore, contains('*.keystore'));
  });
}
