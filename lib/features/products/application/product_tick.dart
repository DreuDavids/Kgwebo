import 'package:flutter_riverpod/flutter_riverpod.dart';

final productTickProvider = StateProvider<int>((ref) => 0);

void bumpProductTick(WidgetRef ref) {
  ref.read(productTickProvider.notifier).state++;
}
