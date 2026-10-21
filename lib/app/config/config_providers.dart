import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';

/// Overridden in [bootstrap] and in widget tests. Reading the default throws
/// so missing wiring is obvious.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw StateError(
    'appConfigProvider must be overridden in bootstrap() or tests.',
  );
});
