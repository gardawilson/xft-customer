import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xft/core/api/api_client.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/auth/presentation/auth_notifier.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.asData?.value?.data?.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.xftBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Ups, kamu belum login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Yuk login dulu biar bisa atur profil dan pengaturan akunmu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Login Sekarang',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.xftBackground,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profile header ───────────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                user.fullName,
                style: const TextStyle(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: AppColors.surface,
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                    ),
                  ),
                  if (user.email.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Text(
                      user.googleId ?? '',
                      style: const TextStyle(
                        color: AppColors.surface,
                        fontWeight: FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Account settings ─────────────────────────────────────────────
          _SectionTitle(title: 'Pengaturan akun'),
          const SizedBox(height: 8),
          _MenuContainer(
            children: [
              _MenuItem(
                title: 'Edit Profil',
                icon: Icons.person_outline,
                onTap: () => context.push('/edit-profile'),
              ),
              const _MenuDivider(),
              _MenuItem(
                title: 'Ubah Password',
                icon: Icons.lock_outline,
                onTap: () => context.push('/edit-password'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Info & help ──────────────────────────────────────────────────
          _SectionTitle(title: 'Informasi dan bantuan'),
          const SizedBox(height: 8),
          _MenuContainer(
            children: [
              _MenuItem(
                title: 'Hubungi Kami',
                icon: Icons.headset_mic_outlined,
                onTap: () => context.push('/contact-us'),
              ),
              const _MenuDivider(),
              _MenuItem(
                title: 'Syarat & Ketentuan',
                icon: Icons.description_outlined,
                onTap: () {
                  final baseUrl = ref.read(apiBaseUrlProvider);
                  final url = Uri.encodeComponent(
                    '$baseUrl/terms-and-conditions',
                  );
                  final title = Uri.encodeComponent('Syarat & Ketentuan');
                  context.push('/web-view?url=$url&title=$title');
                },
              ),
              const _MenuDivider(),
              _MenuItem(
                title: 'Kebijakan Privasi',
                icon: Icons.privacy_tip_outlined,
                onTap: () {
                  final baseUrl = ref.read(apiBaseUrlProvider);
                  final url = Uri.encodeComponent('$baseUrl/privacy-policy');
                  final title = Uri.encodeComponent('Kebijakan Privasi');
                  context.push('/web-view?url=$url&title=$title');
                },
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Logout ───────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showLogoutSheet(context, ref),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.background,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Keluar Aplikasi',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showLogoutSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Keluar Aplikasi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kamu akan keluar dari aplikasi dan perlu login kembali untuk masuk',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ya, Keluar dari aplikasi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }
}

class _MenuContainer extends StatelessWidget {
  final List<Widget> children;
  const _MenuContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _MenuItem({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.surface),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.surface,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.grey.shade300,
    );
  }
}
