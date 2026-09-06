import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  String? _formError;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      await context.read<AuthProvider>().login(
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) context.go('/home');
    } on ApiException catch (error) {
      setState(() => _formError = error.message);
    } catch (_) {
      setState(() => _formError = 'Gagal masuk. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AppLogo(size: 80)),
                const SizedBox(height: 20),
                const Text(
                  'Selamat Datang',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Masuk untuk booking meja billiard favoritmu',
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
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(labelText: 'Nomor HP', hintText: '081234567890'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Nomor HP wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Password wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Masuk', isLoading: _isSubmitting, onPressed: _submit),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun?', style: TextStyle(color: AppColors.textMuted)),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Daftar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
