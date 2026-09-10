import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/initials_avatar.dart';
import '../../widgets/section_label.dart';

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

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.bg],
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Profil',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                InitialsAvatar(name: customer?.name, size: 84),
                const SizedBox(height: 14),
                Text(
                  customer?.name ?? '-',
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  customer?.phone ?? '-',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
                ),
                if (customer?.email != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    customer!.email!,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Akun'),
              const SizedBox(height: 10),
              _MenuCard(
                children: [
                  _MenuTile(
                    icon: Icons.edit_outlined,
                    iconColor: AppColors.primary,
                    label: 'Edit Profil',
                    onTap: () => context.push('/profile/edit'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionLabel('Lainnya'),
              const SizedBox(height: 10),
              _MenuCard(
                children: [
                  _MenuTile(
                    icon: Icons.description_outlined,
                    iconColor: AppColors.info,
                    label: 'Syarat & Ketentuan',
                    onTap: () => context.push('/legal/terms'),
                  ),
                  const Divider(height: 1, color: AppColors.border, indent: 66),
                  _MenuTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: AppColors.info,
                    label: 'Kebijakan Privasi',
                    onTap: () => context.push('/legal/privacy'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout, color: AppColors.danger, size: 18),
                  label: const Text('Keluar', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.dangerSoft),
                    backgroundColor: AppColors.dangerSoft.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.iconColor, required this.label, required this.onTap});

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textFaint, size: 20),
          ],
        ),
      ),
    );
  }
}
