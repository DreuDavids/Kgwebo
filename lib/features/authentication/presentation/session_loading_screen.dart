import 'package:flutter/material.dart';

import '../../../shared/widgets/kgwebo_brand_mark.dart';
import '../../../shared/widgets/kgwebo_loading_state.dart';

class SessionLoadingScreen extends StatelessWidget {
  const SessionLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Spacer(),
            Center(child: KgweboBrandMark()),
            SizedBox(height: 24),
            KgweboLoadingState(message: 'Restoring your session'),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
