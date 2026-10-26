import 'package:flutter/material.dart';

import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_soft_card.dart';
import '../application/privacy_copy.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text(PrivacyCopy.cardTitle)),
      body: SafeArea(
        child: KgweboFilledBody(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              KgweboSpacing.md,
              KgweboSpacing.md,
              KgweboSpacing.md,
              KgweboSpacing.xl,
            ),
            children: [
              KgweboSoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (
                      var index = 0;
                      index < PrivacyCopy.paragraphs.length;
                      index++
                    ) ...[
                      if (index > 0) const SizedBox(height: KgweboSpacing.md),
                      Text(
                        PrivacyCopy.paragraphs[index],
                        style: textTheme.bodyLarge?.copyWith(
                          color: KgweboColors.ink,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
