import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app_config.dart';
import 'compile_time_env.dart';
import 'env_parser.dart';

/// Loads env files from the Flutter asset bundle, then applies dart-define
/// overrides. Missing optional files are ignored; required validation lives
/// in [AppConfig.resolve].
class EnvLoader {
  const EnvLoader({
    this.parser = const EnvParser(),
    this.exampleAsset = '.env.example',
    this.localAsset = '.env',
  });

  final EnvParser parser;
  final String exampleAsset;
  final String localAsset;

  /// Merge order: `.env.example`, then `.env` if bundled, then dart-define.
  Future<AppConfig> load({
    AssetBundle? bundle,
    CompileTimeEnv compileTime = const CompileTimeEnv(),
  }) async {
    final values = <String, String>{};
    final assetBundle = bundle ?? rootBundle;

    final example = await _tryLoad(assetBundle, exampleAsset);
    if (example != null) {
      values.addAll(parser.parse(example));
    }

    final local = await _tryLoad(assetBundle, localAsset);
    if (local != null) {
      values.addAll(parser.parse(local));
    }

    values.addAll(compileTime.nonemptyValues);
    return AppConfig.resolve(values);
  }

  Future<String?> _tryLoad(AssetBundle bundle, String key) async {
    try {
      final source = await bundle.loadString(key);
      if (source.trim().isEmpty) {
        return null;
      }
      return source;
    } on FlutterError {
      return null;
    }
  }
}
