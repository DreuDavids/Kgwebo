import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/app_config.dart';
import 'package:kgwebo/app/config/app_environment.dart';
import 'package:kgwebo/core/errors/app_exception.dart';
import 'package:kgwebo/core/logging/app_logger.dart';
import 'package:logging/logging.dart';

void main() {
  const validUrl = 'https://hhwxajxjmyjntxykptvs.supabase.co';
  const publishableKey = 'sb_publishable_test_anon_key_not_real';

  test('valid development config is live and may connect', () {
    final config = AppConfig.resolve({
      'APP_ENV': 'development',
      'SUPABASE_URL': validUrl,
      'SUPABASE_ANON_KEY': publishableKey,
    });

    expect(config.environment, AppEnvironment.development);
    expect(config.runtimeMode, AppRuntimeMode.live);
    expect(config.isBackendConfigured, isTrue);
    expect(config.shouldBlockStartup, isFalse);
    expect(config.connectsToBackend, isTrue);
    expect(config.hasSupabaseAnonKey, isTrue);
    expect(config.issues, isEmpty);
  });

  test('missing required development config becomes labelled local mode', () {
    final config = AppConfig.resolve({
      'APP_ENV': 'development',
      'SUPABASE_URL': validUrl,
    });

    expect(config.runtimeMode, AppRuntimeMode.local);
    expect(config.isBackendConfigured, isFalse);
    expect(config.shouldBlockStartup, isFalse);
    expect(config.issues, isNotEmpty);
    expect(config.issues.first, contains('SUPABASE_ANON_KEY'));
  });

  test('missing production config blocks startup and is not demo', () {
    final config = AppConfig.resolve({'APP_ENV': 'production'});

    expect(config.environment, AppEnvironment.production);
    expect(config.runtimeMode, AppRuntimeMode.local);
    expect(config.shouldBlockStartup, isTrue);
    expect(config.runtimeMode, isNot(AppRuntimeMode.demo));
  });

  test('explicit demo mode stays demo and never connects', () {
    final config = AppConfig.resolve({
      'APP_ENV': 'demo',
      'SUPABASE_URL': validUrl,
      'SUPABASE_ANON_KEY': publishableKey,
    });

    expect(config.runtimeMode, AppRuntimeMode.demo);
    expect(config.shouldBlockStartup, isFalse);
    expect(config.connectsToBackend, isFalse);
  });

  test('unknown APP_ENV throws a clear config error', () {
    expect(
      () => AppConfig.resolve({'APP_ENV': 'nightly'}),
      throwsA(isA<ConfigException>()),
    );
  });

  test('service-role keys are rejected and discarded', () {
    final payload = base64Url.encode(utf8.encode('{"role":"service_role"}'));
    final jwt = 'eyJhbGciOiJIUzI1NiJ9.$payload.sig';
    final config = AppConfig.resolve({
      'APP_ENV': 'development',
      'SUPABASE_URL': validUrl,
      'SUPABASE_ANON_KEY': jwt,
    });

    expect(config.hasSupabaseAnonKey, isFalse);
    expect(config.isBackendConfigured, isFalse);
    expect(config.issues.join(), contains('privileged'));
    expect(config.toString(), isNot(contains(jwt)));
    expect(config.toString(), isNot(contains('service_role')));
  });

  test('toString and logs never print secrets', () {
    final records = <LogRecord>[];
    final subscription = Logger(AppLogger.name).onRecord.listen(records.add);
    addTearDown(subscription.cancel);

    final config = AppConfig.resolve({
      'APP_ENV': 'development',
      'SUPABASE_URL': validUrl,
      'SUPABASE_ANON_KEY': publishableKey,
    });

    AppLogger.info('Loaded $config');
    AppLogger.info('SUPABASE_ANON_KEY=$publishableKey');
    AppLogger.info(publishableKey);

    expect(config.toString(), isNot(contains(publishableKey)));
    expect(config.toString(), isNot(contains('test_anon_key')));
    final combined = records.map((record) => record.message).join('\n');
    expect(combined, isNot(contains(publishableKey)));
    expect(combined, contains('[redacted]'));
  });
}
