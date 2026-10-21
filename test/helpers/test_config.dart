import 'package:kgwebo/app/config/app_config.dart';

AppConfig testConfig({
  String? url = 'https://hhwxajxjmyjntxykptvs.supabase.co',
  String? anonKey,
  String appEnv = 'development',
}) {
  return AppConfig.resolve({
    'APP_ENV': appEnv,
    if (url != null) 'SUPABASE_URL': url,
    if (anonKey != null) 'SUPABASE_ANON_KEY': anonKey,
  });
}
