import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/auth/presentation/auth_notifier.dart';

class EmailVerificationCard extends ConsumerStatefulWidget {
  const EmailVerificationCard({super.key});

  @override
  ConsumerState<EmailVerificationCard> createState() =>
      _EmailVerificationCardState();
}

class _EmailVerificationCardState
    extends ConsumerState<EmailVerificationCard> {
  bool _isSending = false;

  Future<void> _resendVerification() async {
    if (_isSending) return;
    setState(() => _isSending = true);

    try {
      await ref.read(authProvider.notifier).resendVerificationEmail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Link verifikasi telah dikirim ke email Anda'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isSending ? null : _resendVerification,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.xftPrimary, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verifikasi Email',
                    style: TextStyle(
                      color: AppColors.xftPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isSending
                        ? 'Mengirim link verifikasi...'
                        : 'Verifikasi email untuk mulai oder minuman favoritmu',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[700]
                          : Colors.grey[400],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.xftPrimary,
                    ),
                  )
                : const Icon(
                    LucideIcons.chevron_right,
                    color: AppColors.xftPrimary,
                  ),
          ],
        ),
      ),
    );
  }
}
