import 'package:flutter/material.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_radii.dart';
import '../../app/theme/kgwebo_spacing.dart';

enum KgweboBannerTone { info, warning, preview, success }

class KgweboStatusBanner extends StatelessWidget {
  const KgweboStatusBanner({
    super.key,
    required this.message,
    this.tone = KgweboBannerTone.info,
    this.icon,
  });

  final String message;
  final KgweboBannerTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      KgweboBannerTone.info => (
        background: KgweboColors.tealSoft,
        foreground: KgweboColors.forest,
        accent: KgweboColors.teal,
      ),
      KgweboBannerTone.warning => (
        background: KgweboColors.amberSoft,
        foreground: KgweboColors.ink,
        accent: KgweboColors.amber,
      ),
      KgweboBannerTone.preview => (
        background: KgweboColors.amberSoft,
        foreground: KgweboColors.ink,
        accent: KgweboColors.amber,
      ),
      KgweboBannerTone.success => (
        background: KgweboColors.forestContainer,
        foreground: KgweboColors.forest,
        accent: KgweboColors.success,
      ),
    };

    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: KgweboRadii.borderMd,
          border: Border(left: BorderSide(color: colors.accent, width: 3)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            KgweboSpacing.md,
            KgweboSpacing.sm,
            KgweboSpacing.md,
            KgweboSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon ??
                    switch (tone) {
                      KgweboBannerTone.info => Icons.info_outline,
                      KgweboBannerTone.warning => Icons.warning_amber_outlined,
                      KgweboBannerTone.preview => Icons.visibility_outlined,
                      KgweboBannerTone.success => Icons.check_circle_outline,
                    },
                color: colors.foreground,
                size: 20,
              ),
              const SizedBox(width: KgweboSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: colors.foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
