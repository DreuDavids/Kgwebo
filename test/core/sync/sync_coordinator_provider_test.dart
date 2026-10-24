import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/supabase/kgwebo_supabase.dart';
import 'package:kgwebo/core/persistence/kgwebo_database.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';

import '../../helpers/test_config.dart';

void main() {
  test('live config does not construct a coordinator before supabase init', () {
    expect(kgweboSupabaseIsInitialized, isFalse);
    final database = KgweboDatabase.memory();
    addTearDown(database.close);
    final container = ProviderContainer(
      overrides: [
        kgweboDatabaseProvider.overrideWith((ref) => database),
        appConfigProvider.overrideWithValue(
          testConfig(anonKey: 'sb_publishable_test'),
        ),
      ],
    );
    addTearDown(container.dispose);
    expect(container.read(appConfigProvider).connectsToBackend, isTrue);
    expect(container.read(syncCoordinatorProvider), isNull);
  });
}
