import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isSubmitting = false;
  String? _formError;
  Map<String, List<String>> _fieldErrors = {};

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  String? _serverError(String field) => _fieldErrors[field]?.first;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _passwordConfirmController.text) {
      setState(() => _formError = 'Konfirmasi password tidak cocok.');
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
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(labelText: 'Nama', errorText: _serverError('name')),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    labelText: 'Nomor HP',
                    hintText: '081234567890',
                    errorText: _serverError('phone'),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Nomor HP wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(labelText: 'Email (opsional)', errorText: _serverError('email')),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(labelText: 'Password', errorText: _serverError('password')),
                  validator: (value) =>
                      (value == null || value.length < 8) ? 'Password minimal 8 karakter' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordConfirmController,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(labelText: 'Konfirmasi Password'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Daftar', isLoading: _isSubmitting, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
