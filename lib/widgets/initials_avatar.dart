import 'package:flutter/material.dart';

/// Circular avatar showing a person's initials - used in place of a photo
/// since customer accounts don't have one.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 84});

  final String? name;
  final double size;

  String get _initials {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    final first = parts.first.substring(0, 1);
    final last = parts.length > 1 ? parts.last.substring(0, 1) : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(fontSize: size * 0.36, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
