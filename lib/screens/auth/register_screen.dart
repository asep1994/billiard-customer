import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_glow_background.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isSubmitting = false;
  bool _acceptedTerms = false;
  String? _formError;
  Map<String, List<String>> _fieldErrors = {};

  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = () => context.push('/legal/terms');
    _privacyTap = TapGestureRecognizer()..onTap = () => context.push('/legal/privacy');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  String? _serverError(String field) => _fieldErrors[field]?.first;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _passwordConfirmController.text) {
      setState(() => _formError = 'Konfirmasi password tidak cocok.');
      return;
    }

    if (!_acceptedTerms) {
      setState(() => _formError = 'Kamu harus menyetujui Syarat & Ketentuan dan Kebijakan Privasi.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _formError = null;
      _fieldErrors = {};
    });

    try {
      await context.read<AuthProvider>().register(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) context.go('/home');
    } on ApiException catch (error) {
      setState(() {
        _formError = error.message;
        _fieldErrors = error.errors;
      });
    } catch (_) {
      setState(() => _formError = 'Gagal mendaftar. Coba lagi.');
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
                  const Text(
                    'Buat Akun Baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Daftar sekarang dan mulai pengalaman bermain billiard yang lebih mudah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 28),
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
                    controller: _nameController,
                    icon: Icons.person_outline,
                    label: 'Nama Lengkap',
                    errorText: _serverError('name'),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _emailController,
                    icon: Icons.mail_outline,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    errorText: _serverError('email'),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Email wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    label: 'Nomor HP',
                    hintText: '081234567890',
                    keyboardType: TextInputType.phone,
                    errorText: _serverError('phone'),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Nomor HP wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    icon: Icons.lock_outline,
                    label: 'Password',
                    obscureText: true,
                    errorText: _serverError('password'),
                    validator: (value) =>
                        (value == null || value.length < 8) ? 'Password minimal 8 karakter' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordConfirmController,
                    icon: Icons.lock_outline,
                    label: 'Konfirmasi Password',
                    obscureText: true,
                    validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text.rich(
                              TextSpan(
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                children: [
                                  const TextSpan(text: 'Saya menyetujui '),
                                  TextSpan(
                                    text: 'Syarat & Ketentuan',
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                                    recognizer: _termsTap,
                                  ),
                                  const TextSpan(text: ' dan '),
                                  TextSpan(
                                    text: 'Kebijakan Privasi',
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                                    recognizer: _privacyTap,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Daftar Akun',
                    icon: Icons.arrow_forward,
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun?', style: TextStyle(color: AppColors.textMuted)),
                      TextButton(
                        onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
                        child: const Text('Masuk Sekarang'),
                      ),
                    ],
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
