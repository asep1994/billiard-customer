import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/theme.dart';
import '../../repositories/auth_repository.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_glow_background.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _repository = AuthRepository();

  bool _isSubmitting = false;
  String? _formError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    final email = _emailController.text.trim();

    try {
      await _repository.forgotPassword(email);
      if (mounted) context.push('/reset-password', extra: email);
    } on ApiException catch (error) {
      setState(() => _formError = error.message);
    } catch (_) {
      setState(() => _formError = 'Gagal mengirim kode. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: AppColors.bg),
      body: SafeArea(
        child: AuthGlowBackground(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Icon(Icons.lock_outline, size: 40, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Lupa Password?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Masukkan email kamu, kami akan mengirimkan kode reset password ke email tersebut.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 32),
                  if (_formError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dangerSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                      ),
                      child: Text(_formError!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  AppTextField(
                    controller: _emailController,
                    icon: Icons.mail_outline,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Email wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Kirim Kode Reset',
                    icon: Icons.arrow_forward,
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
                      child: const Text('Kembali ke halaman login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
