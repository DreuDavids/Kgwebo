import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Initialises the publishable-key client. Call only when
/// [AppConfig.connectsToBackend] is true.
Future<void> initializeKgweboSupabase(AppConfig config) async {
  if (!config.connectsToBackend) {
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
}

SupabaseClient get kgweboSupabase => Supabase.instance.client;
