import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logging/app_logger.dart';
import 'app.dart';
import 'config/app_config.dart';
import 'config/compile_time_env.dart';
import 'config/config_providers.dart';
import 'config/env_loader.dart';
import 'supabase/kgwebo_supabase.dart';
import 'theme/kgwebo_colors.dart';

Future<void> bootstrap({
  AssetBundle? bundle,
  CompileTimeEnv compileTime = CompileTimeEnv.fromPlatform,
  EnvLoader loader = const EnvLoader(),
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.configure();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: KgweboColors.canvas,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final config = await loader.load(bundle: bundle, compileTime: compileTime);
  AppLogger.info('Starting Kgwebo with $config');

  if (config.connectsToBackend) {
    await initializeKgweboSupabase(config);
  }

  runApp(KgweboRoot(config: config));
}

class KgweboRoot extends StatelessWidget {
  const KgweboRoot({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const KgweboApp(),
    );
  }
}
