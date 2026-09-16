import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/auth/presentation/auth_notifier.dart';
import 'package:xft/features/auth/domain/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:xft/features/notification/presentation/notification_page.dart';

class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.xftAccent,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Image.asset(
          'assets/images/ic_logo.png',
          fit: BoxFit.fitWidth,
          height: 36,
          width: 128,
        ),
      ),
      leadingWidth: 160.0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: authState.when(
            data: (auth) => _UserAvatar(user: auth?.data?.user),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _UserAvatar extends ConsumerWidget {
  final UserModel? user;
  const _UserAvatar({this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return GestureDetector(
      onTap: () => context.push('/notification'),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 0,
              ),
            ),
            child: ClipOval(
              child: user?.avatarUrl != null
                  ? Image.network(
                      user!.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _fallbackAvatar(context),
                    )
                  : _fallbackAvatar(context),
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              bottom: -2,
              left: -2,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.xftPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 0,
                  ),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Center(
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallbackAvatar(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Icon(
        Icons.person_rounded,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
        size: 24,
      ),
    );
  }
}
