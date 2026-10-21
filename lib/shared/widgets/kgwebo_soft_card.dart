import 'package:flutter/material.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_elevation.dart';
import '../../app/theme/kgwebo_radii.dart';
import '../../app/theme/kgwebo_spacing.dart';

/// Extra-round white card with a soft neutral shadow.
class KgweboSoftCard extends StatelessWidget {
  const KgweboSoftCard({
    super.key,
    required this.child,
    this.color = KgweboColors.surface,
    this.padding,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(KgweboSpacing.md),
      child: child,
    );
    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: KgweboRadii.borderLg,
        boxShadow: color == KgweboColors.surface ? KgweboElevation.soft : null,
      ),
      child: content,
    );

    if (onTap == null) {
      return Semantics(container: true, label: semanticLabel, child: decorated);
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: color,
        borderRadius: KgweboRadii.borderLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: KgweboRadii.borderLg,
          child: decorated,
        ),
      ),
    );
  }
}
