import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'config/config_providers.dart';
import 'router.dart';
import 'theme/kgwebo_theme.dart';
import 'widgets/config_error_screen.dart';

class KgweboApp extends ConsumerWidget {
  const KgweboApp({super.key, this.router});

  /// Optional override so widget tests can supply a fresh [GoRouter].
  final GoRouter? router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final theme = KgweboTheme.light();

    if (config.shouldBlockStartup) {
      return MaterialApp(
        title: 'Kgwebo',
        debugShowCheckedModeBanner: false,
        theme: theme,
        locale: const Locale('en', 'BW'),
        supportedLocales: const [Locale('en', 'BW'), Locale('en')],
        localizationsDelegates: _delegates,
        home: const ConfigErrorScreen(),
      );
    }

    final appRouter = router ?? ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Kgwebo',
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: const Locale('en', 'BW'),
      supportedLocales: const [Locale('en', 'BW'), Locale('en')],
      localizationsDelegates: _delegates,
      routerConfig: appRouter,
    );
  }
}

const _delegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
