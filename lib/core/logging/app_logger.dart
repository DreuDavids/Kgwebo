import 'package:logging/logging.dart';

/// Application logger that redacts secrets before they reach the console.
abstract final class AppLogger {
  static const String name = 'kgwebo';
  static final Logger _log = Logger(name);
  static bool _configured = false;

  static void configure({Level level = Level.INFO}) {
    hierarchicalLoggingEnabled = true;
    Logger.root.level = level;
    _log.level = level;
    if (_configured) {
      return;
    }
    _configured = true;
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print(_format(record));
    });
  }

  static void info(String message) => _log.info(redactSecrets(message));

  static void warning(String message) => _log.warning(redactSecrets(message));

  static void severe(String message, [Object? error, StackTrace? stackTrace]) {
    _log.severe(
      redactSecrets(message),
      error == null ? null : redactSecrets('$error'),
      stackTrace,
    );
  }

  static String _format(LogRecord record) {
    final buffer = StringBuffer(
      '${record.level.name} [${record.loggerName}] ${redactSecrets(record.message)}',
    );
    if (record.error != null) {
      buffer.write(' error=${redactSecrets('${record.error}')}');
    }
    return buffer.toString();
  }

  /// Strips publishable keys, JWTs, service-role keys and common secret
  /// assignments so they cannot appear in test or debug output.
  static String redactSecrets(String input) {
    var output = input;
    output = output.replaceAll(
      RegExp(r'sb_publishable_[A-Za-z0-9_-]+'),
      '[redacted]',
    );
    output = output.replaceAll(
      RegExp(r'sb_secret_[A-Za-z0-9_-]+'),
      '[redacted]',
    );
    output = output.replaceAll(
      RegExp(r'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+'),
      '[redacted]',
    );
    output = output.replaceAllMapped(
      RegExp(
        r'(SUPABASE_ANON_KEY|ANON_KEY|SERVICE_ROLE_KEY|ACCESS_TOKEN|REFRESH_TOKEN|PASSWORD|TOKEN|SECRET)\s*[:=]\s*\S+',
        caseSensitive: false,
      ),
      (match) => '[redacted]',
    );
    return output;
  }
}
