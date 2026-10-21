import 'dart:convert';

import '../../core/errors/app_exception.dart';
import 'app_environment.dart';

/// Resolved, testable application configuration.
///
/// The anon/publishable key is never included in [toString] or issue text.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.runtimeMode,
    required this.supabaseUrl,
    required this.issues,
    required this.isBackendConfigured,
    required this.shouldBlockStartup,
    String? supabaseAnonKey,
  }) : _supabaseAnonKey = supabaseAnonKey;

  final AppEnvironment environment;
  final AppRuntimeMode runtimeMode;
  final String? supabaseUrl;
  final List<String> issues;
  final bool isBackendConfigured;
  final bool shouldBlockStartup;
  final String? _supabaseAnonKey;

  String? get supabaseAnonKey => _supabaseAnonKey;

  bool get hasSupabaseAnonKey {
    final key = _supabaseAnonKey;
    return key != null && key.isNotEmpty;
  }

  /// Live mode with a valid publishable/anon key. Demo never connects, even
  /// when credentials are present. Local preview never connects.
  bool get connectsToBackend =>
      runtimeMode == AppRuntimeMode.live && isBackendConfigured;

  factory AppConfig.localPreview() {
    return const AppConfig(
      environment: AppEnvironment.development,
      runtimeMode: AppRuntimeMode.local,
      supabaseUrl: 'https://hhwxajxjmyjntxykptvs.supabase.co',
      issues: [
        'SUPABASE_ANON_KEY is missing. Add the publishable key to a gitignored '
            '.env or pass --dart-define-from-file=.env.',
      ],
      isBackendConfigured: false,
      shouldBlockStartup: false,
    );
  }

  /// Precedence is applied by the caller. This method only validates and
  /// classifies a fully merged key/value map.
  static AppConfig resolve(Map<String, String> values) {
    final environment = _parseEnvironment(values['APP_ENV']);
    final url = _nonEmpty(values['SUPABASE_URL']);
    var key = _nonEmpty(values['SUPABASE_ANON_KEY']);
    final issues = <String>[];

    if (url == null) {
      issues.add(
        'SUPABASE_URL is missing. Copy .env.example to .env or pass '
        '--dart-define=SUPABASE_URL=...',
      );
    } else if (!_isHttpsSupabaseUrl(url)) {
      issues.add('SUPABASE_URL must be an https Supabase URL.');
    }

    if (key != null && _looksLikeServiceRoleKey(key)) {
      issues.add(
        'A privileged Supabase key was provided. Remove it. Kgwebo only '
        'accepts a publishable or anon client key.',
      );
      key = null;
    } else if (key == null) {
      issues.add(
        'SUPABASE_ANON_KEY is missing. Add the publishable/anon key to local '
        '.env or dart-define. Never use a service-role key.',
      );
    }

    final backendReady =
        url != null &&
        _isHttpsSupabaseUrl(url) &&
        key != null &&
        !_looksLikeServiceRoleKey(key);

    final runtimeMode = switch (environment) {
      AppEnvironment.demo => AppRuntimeMode.demo,
      AppEnvironment.development ||
      AppEnvironment.staging ||
      AppEnvironment.production =>
        backendReady ? AppRuntimeMode.live : AppRuntimeMode.local,
    };

    final shouldBlock = switch (environment) {
      AppEnvironment.production || AppEnvironment.staging => !backendReady,
      AppEnvironment.development || AppEnvironment.demo => false,
    };

    return AppConfig(
      environment: environment,
      runtimeMode: runtimeMode,
      supabaseUrl: url,
      supabaseAnonKey: key,
      issues: List<String>.unmodifiable(issues),
      isBackendConfigured: backendReady,
      shouldBlockStartup: shouldBlock,
    );
  }

  static AppEnvironment _parseEnvironment(String? raw) {
    final value = (raw ?? 'development').trim().toLowerCase();
    return switch (value) {
      'development' || 'dev' => AppEnvironment.development,
      'staging' || 'stage' => AppEnvironment.staging,
      'production' || 'prod' => AppEnvironment.production,
      'demo' => AppEnvironment.demo,
      _ =>
        throw ConfigException(
          'Unknown APP_ENV "$value". Use development, staging, production, or demo.',
        ),
    };
  }

  static String? _nonEmpty(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static bool _isHttpsSupabaseUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isScheme('https') || uri.host.isEmpty) {
      return false;
    }
    return uri.host.endsWith('.supabase.co') || uri.host == 'supabase.co';
  }

  static bool _looksLikeServiceRoleKey(String key) {
    final lower = key.toLowerCase();
    if (lower.startsWith('sb_secret_') || lower.contains('service_role')) {
      return true;
    }
    if (!key.startsWith('eyJ')) {
      return false;
    }
    final parts = key.split('.');
    if (parts.length < 2) {
      return false;
    }
    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      return payload.contains('service_role');
    } on FormatException {
      return false;
    }
  }

  @override
  String toString() {
    return 'AppConfig('
        'environment: $environment, '
        'runtimeMode: $runtimeMode, '
        'supabaseUrl: ${supabaseUrl == null ? 'missing' : 'set'}, '
        'hasSupabaseAnonKey: $hasSupabaseAnonKey, '
        'isBackendConfigured: $isBackendConfigured, '
        'shouldBlockStartup: $shouldBlockStartup, '
        'issueCount: ${issues.length}'
        ')';
  }
}
