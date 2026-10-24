import 'package:flutter/material.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_radii.dart';
import '../../app/theme/kgwebo_spacing.dart';

enum KgweboButtonVariant { primary, secondary, text }

/// Accessible Kgwebo pill button. Drawn by us, not by Material 3.
/// A null [onPressed] disables the control; it never fakes a completed action.
class KgweboButton extends StatelessWidget {
  const KgweboButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = KgweboButtonVariant.primary,
    this.icon,
    this.expanded = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final KgweboButtonVariant variant;
  final IconData? icon;
  final bool expanded;
  final bool isLoading;

  bool get enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = switch (variant) {
      KgweboButtonVariant.primary => (
        background: enabled ? KgweboColors.lime : KgweboColors.surfaceMuted,
        foreground: enabled ? KgweboColors.onLime : KgweboColors.inkFaint,
      ),
      KgweboButtonVariant.secondary => (
        background: enabled ? KgweboColors.ink : KgweboColors.surfaceMuted,
        foreground: enabled ? KgweboColors.onInk : KgweboColors.inkFaint,
      ),
      KgweboButtonVariant.text => (
        background: Colors.transparent,
        foreground: enabled ? KgweboColors.ink : KgweboColors.inkFaint,
      ),
    };

    final child = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.foreground,
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 20, color: colors.foreground),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge?.copyWith(color: colors.foreground),
          ),
        ),
      ],
    );

    final button = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 52,
        minWidth: expanded ? double.infinity : 48,
      ),
      child: Material(
        color: colors.background,
        elevation: 0,
        shadowColor: Colors.transparent,
        borderRadius: KgweboRadii.borderPill,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: KgweboRadii.borderPill,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KgweboSpacing.lg,
              vertical: KgweboSpacing.sm,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (!expanded) {
      return button;
    }
    return SizedBox(width: double.infinity, child: button);
  }
}

/// Icon-only control with a required accessible name.
class KgweboIconButton extends StatelessWidget {
  const KgweboIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, tooltip: tooltip, icon: Icon(icon));
  }
}
