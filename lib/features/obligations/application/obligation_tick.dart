import 'package:flutter_riverpod/flutter_riverpod.dart';

final obligationTickProvider = StateProvider<int>((ref) => 0);

void bumpObligationTick(WidgetRef ref) {
  ref.read(obligationTickProvider.notifier).state++;
}
