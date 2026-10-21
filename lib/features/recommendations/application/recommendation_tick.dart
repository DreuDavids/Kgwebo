import 'package:flutter_riverpod/flutter_riverpod.dart';

final recommendationTickProvider = StateProvider<int>((ref) => 0);

void bumpRecommendationTick(WidgetRef ref) {
  ref.read(recommendationTickProvider.notifier).state++;
}
