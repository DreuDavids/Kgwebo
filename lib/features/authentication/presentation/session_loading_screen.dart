import 'package:flutter/material.dart';

import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_typography.dart';
import '../../../shared/widgets/kgwebo_loading_state.dart';

class SessionLoadingScreen extends StatelessWidget {
  const SessionLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              'Kgwebo',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontFamily: KgweboTypography.serif,
                color: KgweboColors.forest,
              ),
            ),
            const SizedBox(height: 24),
            const KgweboLoadingState(message: 'Restoring your session'),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
