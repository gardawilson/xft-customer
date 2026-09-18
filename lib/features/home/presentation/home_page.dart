import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xft/features/home/presentation/home_tab.dart';
import 'package:xft/features/home/presentation/orders_tab.dart' show OrdersTab;
import 'package:xft/features/home/presentation/promos_tab.dart';
import 'package:xft/features/home/presentation/settings_tab.dart';
import 'package:xft/core/presentation/widgets/main_app_bar.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/notification/presentation/notification_notifier.dart';
import 'package:xft/features/order/cart/presentation/cart_notifier.dart';
import 'package:xft/features/order/product/widgets/sticky_cart_bar.dart';
import 'package:xft/features/order/product/widgets/shake_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  Timer? _notificationPollTimer;

  static const _kNotificationPollInterval = Duration(seconds: 60);

  final GlobalKey<ShakeWidgetState> _cartFabShakeKey =
      GlobalKey<ShakeWidgetState>();

  String _formatPrice(int price) {
    final priceStr = price.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = priceStr.length - 1; i >= 0; i--) {
      buffer.write(priceStr[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  String _buildCartSummaryText(dynamic cart) {
    if (cart == null || cart.items.isEmpty) return '';
    final firstItem = cart.items.first;
    final firstText = '${firstItem.quantity} ${firstItem.productName}';

    if (cart.items.length == 1) {
      return firstText;
    } else {
      final othersCount = cart.items.length - 1;
      final othersText = othersCount == 1 ? '1 other' : '$othersCount others';
      return '$firstText and $othersText';
    }
  }

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

    final cartAsync = ref.watch(cartProvider);
    final cartData = cartAsync.value;
    final cartIsEmpty = cartData == null || cartData.items.isEmpty;
    final cartTotalItems = cartData?.totalItems ?? 0;
    final cartTotalPrice = cartData?.totalPrice ?? 0;
    final cartSummaryText = _buildCartSummaryText(cartData);

    return Scaffold(
      appBar: const MainAppBar(),
      body: Stack(
        children: [
          pages[_selectedIndex],
          if (!cartIsEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ShakeWidget(
                key: _cartFabShakeKey,
                child: StickyCartBar(
                  totalItems: cartTotalItems,
                  totalPrice: cartTotalPrice,
                  summaryText: cartSummaryText,
                  formatPrice: _formatPrice,
                  onTap: () {
                    context.push('/cart');
                  },
                ),
              ),
            ),
        ],
      ),
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
