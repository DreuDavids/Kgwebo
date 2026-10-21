import 'package:flutter/material.dart';

import '../../app/theme/kgwebo_spacing.dart';
import '../../core/responsive/responsive_layout.dart';
import 'kgwebo_empty_state.dart';

/// Shared placeholder for destinations that are not implemented yet.
/// Actions passed in must navigate or explain; they must not fake a save.
class FeaturePlaceholderPage extends StatelessWidget {
  const FeaturePlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    required this.headline,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.header,
  });

  final String title;
  final IconData icon;
  final String headline;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: KgweboContentConstraint(
                  child: KgweboPagePadding(
                    top: KgweboSpacing.md,
                    bottom: KgweboSpacing.lg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (header != null) ...[
                          header!,
                          const SizedBox(height: KgweboSpacing.lg),
                        ],
                        KgweboEmptyState(
                          icon: icon,
                          title: headline,
                          message: message,
                          actionLabel: actionLabel,
                          onAction: onAction,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
