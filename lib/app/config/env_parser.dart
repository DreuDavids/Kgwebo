import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Parses dotenv-formatted text using the project's `flutter_dotenv` parser.
class EnvParser {
  const EnvParser();

  Map<String, String> parse(String source) {
    final lines = source.split(RegExp(r'\r?\n'));
    return const Parser().parse(lines);
  }
}
