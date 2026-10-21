import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/app_environment.dart';
import 'package:kgwebo/app/config/compile_time_env.dart';
import 'package:kgwebo/app/config/env_loader.dart';
import 'package:kgwebo/app/config/env_parser.dart';

void main() {
  test('parser reads dotenv lines and ignores comments', () {
    const source = '''
# comment
SUPABASE_URL=https://hhwxajxjmyjntxykptvs.supabase.co
APP_ENV=development
EMPTY=
''';
    final values = const EnvParser().parse(source);
    expect(values['SUPABASE_URL'], 'https://hhwxajxjmyjntxykptvs.supabase.co');
    expect(values['APP_ENV'], 'development');
    expect(values['EMPTY'], '');
  });

  test('example file loads and dart-define overrides win', () async {
    final bundle = FakeAssetBundle({
      '.env.example': '''
SUPABASE_URL=https://hhwxajxjmyjntxykptvs.supabase.co
SUPABASE_ANON_KEY=
APP_ENV=development
''',
    });

    final config = await const EnvLoader().load(
      bundle: bundle,
      compileTime: const CompileTimeEnv(
        supabaseAnonKey: 'sb_publishable_from_define',
        appEnv: 'staging',
      ),
    );

    expect(config.environment, AppEnvironment.staging);
    expect(config.supabaseUrl, 'https://hhwxajxjmyjntxykptvs.supabase.co');
    expect(config.hasSupabaseAnonKey, isTrue);
    expect(config.toString(), isNot(contains('from_define')));
  });

  test('missing env files still resolve with a clear local mode', () async {
    final config = await const EnvLoader().load(bundle: FakeAssetBundle({}));

    expect(config.runtimeMode, AppRuntimeMode.local);
    expect(config.issues, isNotEmpty);
  });
}

class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final source = assets[key];
    if (source == null) {
      throw FlutterError('Unable to load asset: $key');
    }
    final encoded = utf8.encode(source);
    return ByteData.view(Uint8List.fromList(encoded).buffer);
  }
}
