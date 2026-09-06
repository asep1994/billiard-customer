import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/storage.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideNextRoute());
  }

  Future<void> _decideNextRoute() async {
    final auth = context.read<AuthProvider>();
    final onboarding = OnboardingPreference();

    final results = await Future.wait([
      auth.bootstrap(),
      onboarding.hasSeenOnboarding(),
    ]);
    final hasSeenOnboarding = results[1] as bool;

    if (!mounted) return;

    if (auth.status == AuthStatus.authenticated) {
      context.go('/home');
    } else if (!hasSeenOnboarding) {
      context.go('/onboarding');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(child: AppLogo(size: 120)),
    );
  }
}
