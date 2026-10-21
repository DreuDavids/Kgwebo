import 'package:flutter/material.dart';

enum KgweboButtonVariant { primary, secondary, text }

/// Accessible Kgwebo button. A null [onPressed] disables the control; it
/// never fakes a completed action.
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

  @override
  Widget build(BuildContext context) {
    final child = switch (variant) {
      KgweboButtonVariant.primary => _filled(),
      KgweboButtonVariant.secondary => _outlined(),
      KgweboButtonVariant.text => _text(),
    };
    if (!expanded) {
      return child;
    }
    return SizedBox(width: double.infinity, child: child);
  }

  VoidCallback? get _onPressed => isLoading ? null : onPressed;

  Widget _label() {
    if (!isLoading) {
      return Text(label);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _filled() {
    if (icon == null || isLoading) {
      return FilledButton(onPressed: _onPressed, child: _label());
    }
    return FilledButton.icon(
      onPressed: _onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }

  Widget _outlined() {
    if (icon == null || isLoading) {
      return OutlinedButton(onPressed: _onPressed, child: _label());
    }
    return OutlinedButton.icon(
      onPressed: _onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }

  Widget _text() {
    if (icon == null || isLoading) {
      return TextButton(onPressed: _onPressed, child: _label());
    }
    return TextButton.icon(
      onPressed: _onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
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
