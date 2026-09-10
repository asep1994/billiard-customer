import 'package:flutter/material.dart';

import '../../core/theme.dart';

class LegalSection {
  const LegalSection(this.heading, this.body);

  final String heading;
  final String body;
}

/// Generic scrollable reader for a titled document made of heading/body
/// sections - shared by the Terms & Conditions and Privacy Policy screens
/// so both read consistently instead of each hand-rolling its own layout.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.updatedAt,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String updatedAt;
  final String intro;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Berlaku sejak $updatedAt',
              style: const TextStyle(color: AppColors.textFaint, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Text(intro, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5)),
            const SizedBox(height: 24),
            for (final section in sections) ...[
              Text(
                section.heading,
                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(section.body, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5)),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
