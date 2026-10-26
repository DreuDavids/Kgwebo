import 'package:flutter/material.dart';

/// Bundled scene art used to fill empty canvas on short auth screens.
abstract final class KgweboIllustrationAssets {
  static const authScene = 'assets/illustrations/auth-scene.jpg';
  static const welcomeHero = 'assets/illustrations/welcome-hero.jpg';
}

/// Decorative raster scene. Hidden from assistive tech.
class KgweboIllustration extends StatelessWidget {
  const KgweboIllustration({
    super.key,
    required this.asset,
    this.maxHeight = 220,
    this.alignment = Alignment.center,
  });

  final String asset;
  final double maxHeight;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ClipRect(
        child: Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Image.asset(
              asset,
              width: double.infinity,
              fit: BoxFit.contain,
              alignment: alignment,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
    );
  }
}
