/// Base type for recoverable Kgwebo failures that can be shown to a user.
class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => code == null ? message : '$code: $message';
}

/// Configuration that is missing, invalid, or unsafe (for example a
/// service-role key). Messages must never include secret values.
class ConfigException extends AppException {
  const ConfigException(super.message, {super.code = 'config'});
}
