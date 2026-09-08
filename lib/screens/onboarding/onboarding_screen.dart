import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage.dart';
import '../../core/theme.dart';
import '../../widgets/auth_glow_background.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

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
    title: 'More Than A Game',
    highlight: "It's A Community",
    description: 'Temukan tempat billiard terbaik di kotamu, pesan meja dengan mudah, dan main kapan saja.',
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

  Future<void> _markSeen() => OnboardingPreference().markSeen();

  Future<void> _skip() async {
    await _markSeen();
    if (mounted) context.go('/login');
  }

  Future<void> _goToLogin() async {
    await _markSeen();
    if (mounted) context.push('/login');
  }

  Future<void> _goToRegister() async {
    await _markSeen();
    if (mounted) context.push('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: AuthGlowBackground(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _skip,
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
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (i) {
                        final active = i == _index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 8,
                          width: active ? 20 : 8,
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(label: 'Masuk', icon: Icons.arrow_forward, onPressed: _goToLogin),
                    const SizedBox(height: 12),
                    SecondaryButton(label: 'Daftar Akun', onPressed: _goToRegister),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
