import 'package:flutter/material.dart';

/// A simple decorative "8-ball" mark used wherever we'd otherwise show a
/// venue photo we don't have (the API doesn't store venue images yet).
class EightBallIcon extends StatelessWidget {
  const EightBallIcon({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Container(
        height: size * 0.56,
        width: size * 0.56,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(
          '8',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.32,
            height: 1,
          ),
        ),
      ),
    );
  }
}
