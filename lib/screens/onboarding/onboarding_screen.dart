import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage.dart';
import '../../core/theme.dart';

class _Slide {
  final IconData icon;
  final String title;
  final String highlight;
  final String description;

  const _Slide({
    required this.icon,
    required this.title,
    required this.highlight,
    required this.description,
  });
}

const _slides = [
  _Slide(
    icon: Icons.travel_explore_outlined,
    title: 'Temukan Tempat Billiard',
    highlight: 'Terbaik',
    description: 'Cari venue billiard di kotamu, lihat meja yang tersedia, dan jam operasionalnya.',
  ),
  _Slide(
    icon: Icons.event_available_outlined,
    title: 'Booking Meja',
    highlight: 'Tanpa Ribet',
    description: 'Pilih tanggal dan jam, cek meja yang masih kosong, langsung booking dari HP.',
  ),
  _Slide(
    icon: Icons.emoji_events_outlined,
    title: 'Lebih dari Sekadar',
    highlight: 'Permainan',
    description: 'Bayar aman lewat berbagai metode, pantau riwayat booking kamu kapan saja.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  Future<void> _finish() async {
    await OnboardingPreference().markSeen();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Lewati', style: TextStyle(color: AppColors.textMuted)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 140,
                          width: 140,
                          decoration: const BoxDecoration(
                            color: AppColors.primarySoft,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(slide.icon, size: 64, color: AppColors.primary),
                        ),
                        const SizedBox(height: 40),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text),
                            children: [
                              TextSpan(text: '${slide.title}\n'),
                              TextSpan(text: slide.highlight, style: const TextStyle(color: AppColors.primary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  Row(
                    children: List.generate(_slides.length, (i) {
                      final active = i == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: active ? 20 : 8,
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  FloatingActionButton(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    onPressed: () {
                      if (isLast) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: Icon(isLast ? Icons.check : Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
