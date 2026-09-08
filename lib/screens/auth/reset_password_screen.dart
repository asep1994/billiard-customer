import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/theme.dart';
import '../../repositories/auth_repository.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_glow_background.dart';
import '../../widgets/primary_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _repository = AuthRepository();

  bool _isSubmitting = false;
  String? _formError;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      await _repository.resetPassword(
        email: widget.email,
        code: _codeController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil direset. Silakan masuk.')),
        );
        context.go('/login');
      }
    } on ApiException catch (error) {
      setState(() => _formError = error.message);
    } catch (_) {
      setState(() => _formError = 'Gagal mereset password. Coba lagi.');
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
                      child: const Icon(Icons.mark_email_read_outlined, size: 40, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Masukkan Kode',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cek email ${widget.email} untuk kode reset password, lalu buat password baru.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMuted),
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
                    controller: _codeController,
                    icon: Icons.pin_outlined,
                    label: 'Kode dari Email',
                    hintText: '123456',
                    keyboardType: TextInputType.number,
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Kode wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    icon: Icons.lock_outline,
                    label: 'Password Baru',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Password baru wajib diisi';
                      if (value.length < 8) return 'Password minimal 8 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _confirmController,
                    icon: Icons.lock_outline,
                    label: 'Konfirmasi Password Baru',
                    obscureText: true,
                    validator: (value) =>
                        value != _passwordController.text ? 'Konfirmasi password tidak cocok' : null,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Reset Password',
                    icon: Icons.arrow_forward,
                    isLoading: _isSubmitting,
                    onPressed: _submit,
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
