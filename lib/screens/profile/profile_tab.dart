import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_logo.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Keluar', style: TextStyle(color: AppColors.text)),
        content: const Text('Yakin mau keluar dari akun ini?', style: TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<AuthProvider>().customer;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Profil', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const AppLogo(size: 56, borderRadius: 14),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer?.name ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.text),
                      ),
                      const SizedBox(height: 4),
                      Text(customer?.phone ?? '-', style: const TextStyle(color: AppColors.textMuted)),
                      if (customer?.email != null)
                        Text(customer!.email!, style: const TextStyle(color: AppColors.textFaint, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined, color: AppColors.textMuted),
            title: const Text('Edit Profil', style: TextStyle(color: AppColors.text)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textFaint),
            onTap: () => context.push('/profile/edit'),
          ),
          const Divider(height: 1, color: AppColors.border),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text('Keluar', style: TextStyle(color: AppColors.danger)),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }
}
