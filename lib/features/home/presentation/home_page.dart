import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/features/home/presentation/home_tab.dart';
import 'package:xft/features/home/presentation/orders_tab.dart' show OrdersTab;
import 'package:xft/features/home/presentation/promos_tab.dart';
import 'package:xft/features/home/presentation/settings_tab.dart';
import 'package:xft/core/presentation/widgets/main_app_bar.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/notification/presentation/notification_notifier.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  Timer? _notificationPollTimer;

  // Badge lonceng di MainAppBar tampil terus selama app dibuka (bukan cuma
  // pas tab Pesanan aktif), jadi timer-nya dipasang di sini -- level
  // HomePage -- bukan di dalam OrdersTab, supaya tetap jalan di tab manapun.
  static const _kNotificationPollInterval = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    _notificationPollTimer = Timer.periodic(_kNotificationPollInterval, (_) {
      ref.read(notificationListProvider.notifier).silentRefresh();
    });
  }

  @override
  void dispose() {
    _notificationPollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeTab(),
      const OrdersTab(),
      const PromosTab(),
      const SettingsTab(),
    ];

    return Scaffold(
      appBar: const MainAppBar(),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.xftAccent,
        indicatorColor: AppColors.xftPrimary,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.house),
            selectedIcon: Icon(LucideIcons.house, color: Colors.white),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.cup_soda),
            selectedIcon: Icon(LucideIcons.cup_soda, color: Colors.white),
            label: 'Pesanan',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.tags),
            selectedIcon: Icon(LucideIcons.tags, color: Colors.white),
            label: 'Promo',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.user_round),
            selectedIcon: Icon(LucideIcons.user_round, color: Colors.white),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
