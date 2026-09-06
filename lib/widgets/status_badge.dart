import 'package:flutter/material.dart';

import '../core/theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.status});

  final String label;
  final String status;

  static const _colors = {
    'pending': AppColors.warning,
    'confirmed': AppColors.primary,
    'ongoing': AppColors.info,
    'completed': AppColors.primary,
    'cancelled': AppColors.danger,
    'unpaid': AppColors.danger,
    'partial': AppColors.warning,
    'paid': AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status] ?? AppColors.textFaint;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
