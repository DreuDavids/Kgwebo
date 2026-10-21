import 'package:flutter/material.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_spacing.dart';
import '../../core/responsive/responsive_layout.dart';

/// Cool canvas page with optional header and pinned footer.
class KgweboWashScaffold extends StatelessWidget {
  const KgweboWashScaffold({
    super.key,
    required this.body,
    this.header,
    this.footer,
    this.safeBottom = true,
  });

  final Widget? header;
  final Widget body;
  final Widget? footer;
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KgweboColors.canvas,
      body: ColoredBox(
        color: KgweboColors.canvas,
        child: SafeArea(
          bottom: safeBottom,
          child: KgweboContentConstraint(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (header != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KgweboSpacing.md,
                      KgweboSpacing.lg,
                      KgweboSpacing.md,
                      KgweboSpacing.md,
                    ),
                    child: header,
                  ),
                Expanded(child: body),
                if (footer != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      KgweboSpacing.md,
                      KgweboSpacing.sm,
                      KgweboSpacing.md,
                      KgweboSpacing.md +
                          (safeBottom
                              ? 0
                              : MediaQuery.paddingOf(context).bottom),
                    ),
                    child: footer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
