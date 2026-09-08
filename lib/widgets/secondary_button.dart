import 'package:flutter/material.dart';

/// Outlined counterpart to [PrimaryButton] - used where a primary and a
/// secondary action sit side by side, e.g. "Masuk" / "Daftar Akun" on
/// onboarding.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
