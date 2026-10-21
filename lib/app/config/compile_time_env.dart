/// Values supplied with `--dart-define` / `--dart-define-from-file`.
///
/// `fromPlatform` must stay `const` so `String.fromEnvironment` is resolved
/// at compile time. Tests pass an explicit instance instead.
class CompileTimeEnv {
  const CompileTimeEnv({
    this.supabaseUrl = '',
    this.supabaseAnonKey = '',
    this.appEnv = '',
  });

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String appEnv;

  static const fromPlatform = CompileTimeEnv(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
    appEnv: String.fromEnvironment('APP_ENV'),
  );

  Map<String, String> get nonemptyValues => {
    if (supabaseUrl.isNotEmpty) 'SUPABASE_URL': supabaseUrl,
    if (supabaseAnonKey.isNotEmpty) 'SUPABASE_ANON_KEY': supabaseAnonKey,
    if (appEnv.isNotEmpty) 'APP_ENV': appEnv,
  };
}
