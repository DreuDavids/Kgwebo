import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

bool _kgweboSupabaseInitialized = false;

/// True only after [initializeKgweboSupabase] completed for a live config.
bool get kgweboSupabaseIsInitialized => _kgweboSupabaseInitialized;

/// Initialises the publishable-key client. Call only when
/// [AppConfig.connectsToBackend] is true.
Future<void> initializeKgweboSupabase(AppConfig config) async {
  if (!config.connectsToBackend || _kgweboSupabaseInitialized) {
    return;
  }
  await Supabase.initialize(
    url: config.supabaseUrl!,
    publishableKey: config.supabaseAnonKey!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      detectSessionInUri: true,
    ),
    debug: false,
  );
  _kgweboSupabaseInitialized = true;
}

SupabaseClient get kgweboSupabase {
  if (!_kgweboSupabaseInitialized) {
    throw StateError(
      'Supabase is not initialised. Offline and live writes cannot be sent.',
    );
  }
  return Supabase.instance.client;
}
