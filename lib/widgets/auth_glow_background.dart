import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Decorative radial-gradient glow behind the auth screens' content,
/// standing in for the mockup's photographic backgrounds - this app has no
/// photo assets (see [EightBallIcon] for the same code-drawn approach).
class AuthGlowBackground extends StatelessWidget {
  const AuthGlowBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: _Glow(size: 260, opacity: 0.25),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: _Glow(size: 280, opacity: 0.15),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [AppColors.primary.withValues(alpha: opacity), Colors.transparent],
          ),
        ),
      ),
    );
  }
}
