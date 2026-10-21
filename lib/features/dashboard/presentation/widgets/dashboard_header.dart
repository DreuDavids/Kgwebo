import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../shared/widgets/kgwebo_brand_mark.dart';
import '../../../../shared/widgets/kgwebo_greeting_header.dart';
import '../../../authentication/application/session_controller.dart';
import '../../../authentication/domain/app_session.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final businessName =
        session is AppSessionReady ? session.business.name : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KgweboBrandMark(),
        const SizedBox(height: KgweboSpacing.lg),
        KgweboGreetingHeader(businessName: businessName),
      ],
    );
  }
}
