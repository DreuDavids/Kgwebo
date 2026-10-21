import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../obligations/application/obligation_tick.dart';
import '../../transactions/application/transaction_tick.dart';

class SyncLifecycleHost extends ConsumerStatefulWidget {
  const SyncLifecycleHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncLifecycleHost> createState() => _SyncLifecycleHostState();
}

class _SyncLifecycleHostState extends ConsumerState<SyncLifecycleHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sync();
    }
  }

  Future<void> _sync() async {
    final session = ref.read(appSessionProvider);
    final coordinator = ref.read(syncCoordinatorProvider);
    if (session is! AppSessionReady || coordinator == null) {
      return;
    }
    await coordinator.process(
      ownerId: session.user.id,
      businessId: session.business.id,
    );
    if (!mounted) {
      return;
    }
    ref.read(transactionTickProvider.notifier).state++;
    ref.read(obligationTickProvider.notifier).state++;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
