import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Small caps label used above a grouped set of fields or menu items,
/// e.g. "AKUN" or "GANTI PASSWORD".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textFaint,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}
