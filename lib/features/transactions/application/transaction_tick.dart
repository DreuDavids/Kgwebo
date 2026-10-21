import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incremented after a confirmed create, update or delete so lists and
/// dashboard totals reload the same records.
final transactionTickProvider = StateProvider<int>((ref) => 0);

void bumpTransactionTick(WidgetRef ref) {
  ref.read(transactionTickProvider.notifier).state++;
}
