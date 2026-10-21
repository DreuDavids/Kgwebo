import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../shared/widgets/kgwebo_brand_mark.dart';
import '../../../../shared/widgets/kgwebo_greeting_header.dart';
import '../../../authentication/application/session_controller.dart';
import '../../../authentication/domain/app_session.dart';

class DashboardBrandBar extends StatelessWidget {
  const DashboardBrandBar({super.key});

  static const double height = 64;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        KgweboSpacing.sm,
        KgweboSpacing.md,
        KgweboSpacing.sm,
      ),
      child: Align(alignment: Alignment.centerLeft, child: KgweboBrandMark()),
    );
  }
}

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final businessName =
        session is AppSessionReady ? session.business.name : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        KgweboSpacing.xs,
        KgweboSpacing.md,
        KgweboSpacing.md,
      ),
      child: KgweboGreetingHeader(businessName: businessName),
    );
  }
}
