import 'package:flutter/widgets.dart';

import 'breakpoints.dart';
import 'window_size_class.dart';

/// Horizontal page inset that follows [KgweboBreakpoints].
class KgweboPagePadding extends StatelessWidget {
  const KgweboPagePadding({
    super.key,
    required this.child,
    this.top,
    this.bottom,
  });

  final Widget child;
  final double? top;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    final sizeClass = KgweboBreakpoints.of(context);
    final horizontal = KgweboBreakpoints.pagePadding(sizeClass);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontal,
        top ?? 0,
        horizontal,
        bottom ?? 0,
      ),
      child: child,
    );
  }
}

/// Centers content and caps width on expansive layouts without fixing card size.
/// Gives [child] the incoming height so a [ListView] can sit inside an
/// aligned, width-capped column without receiving unbounded constraints.
class KgweboFilledBody extends StatelessWidget {
  const KgweboFilledBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight =
            constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : MediaQuery.sizeOf(context).height;
        final maxWidth = switch (KgweboBreakpoints.of(context)) {
          WindowSizeClass.compact => constraints.maxWidth,
          WindowSizeClass.medium ||
          WindowSizeClass.expanded => KgweboBreakpoints.maxContentWidth,
        };
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              minHeight: maxHeight,
              maxHeight: maxHeight,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class KgweboContentConstraint extends StatelessWidget {
  const KgweboContentConstraint({
    super.key,
    required this.child,
    this.maxWidth = KgweboBreakpoints.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final sizeClass = KgweboBreakpoints.of(context);
    final width = switch (sizeClass) {
      WindowSizeClass.compact => double.infinity,
      WindowSizeClass.medium => maxWidth,
      WindowSizeClass.expanded => maxWidth,
    };
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: child,
      ),
    );
  }
}

/// Wraps children into a width-aware grid. Item width is computed from
/// available space so cards reflow instead of overflowing.
class KgweboResponsiveGrid extends StatelessWidget {
  const KgweboResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 12,
    this.runSpacing = 12,
    this.columnsForWidth,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int Function(double width)? columnsForWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = (columnsForWidth ?? KgweboBreakpoints.metricColumns)(
          width,
        );
        final gaps = spacing * (columns - 1);
        final itemWidth = columns == 1 ? width : (width - gaps) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
