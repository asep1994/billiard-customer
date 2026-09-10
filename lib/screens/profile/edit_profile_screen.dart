import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isSubmitting = false;
  String? _formError;
  Map<String, List<String>> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    final customer = context.read<AuthProvider>().customer;
    _nameController = TextEditingController(text: customer?.name ?? '');
    _emailController = TextEditingController(text: customer?.email ?? '');
    _phoneController = TextEditingController(text: customer?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _serverError(String field) => _fieldErrors[field]?.first;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text.isNotEmpty && _passwordController.text != _confirmController.text) {
      setState(() => _formError = 'Konfirmasi password baru tidak cocok.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _formError = null;
      _fieldErrors = {};
    });

    try {
      await context.read<AuthProvider>().updateProfile(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            currentPassword: _currentPasswordController.text,
            password: _passwordController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui.')),
        );
        Navigator.of(context).pop();
      }
    } on ApiException catch (error) {
      setState(() {
        _formError = error.message;
        _fieldErrors = error.errors;
      });
    } catch (_) {
      setState(() => _formError = 'Gagal memperbarui profil. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                  keyboardType: TextInputType.phone,
                  errorText: _serverError('phone'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Nomor HP wajib diisi' : null,
                ),
                const SizedBox(height: 28),
                const Text(
                  'Ganti Password (opsional)',
                  style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kosongkan kalau tidak ingin mengganti password.',
                  style: TextStyle(color: AppColors.textFaint, fontSize: 12),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _currentPasswordController,
                  icon: Icons.lock_outline,
                  label: 'Password Saat Ini',
                  obscureText: true,
                  errorText: _serverError('current_password'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordController,
                  icon: Icons.lock_outline,
                  label: 'Password Baru',
                  obscureText: true,
                  errorText: _serverError('password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
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
                ),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Simpan Perubahan', isLoading: _isSubmitting, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
