import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'package:xft/core/router/router.dart';
import 'package:xft/core/theme/app_theme.dart';
import 'package:xft/features/order/history/presentation/order_history_notifier.dart';
import 'package:xft/features/notification/presentation/notification_notifier.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase hanya diinisialisasi di Android/iOS, skip untuk web/desktop
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  final useDevicePreview = kIsWeb;

  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: useDevicePreview,
        builder: (context) => const XftApp(),
      ),
    ),
  );
}

/// Root application widget.
class XftApp extends ConsumerStatefulWidget {
  const XftApp({super.key});

  @override
  ConsumerState<XftApp> createState() => _XftAppState();
}

class _XftAppState extends ConsumerState<XftApp> {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      _initFCM();
    }
  }

  Future<void> _initFCM() async {
    final messaging = FirebaseMessaging.instance;

    // Cek apakah aplikasi dibuka dari notifikasi background (cold start)
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      final data = initialMessage.data;
      final orderId = data['order_id']?.toString();
      final category = data['category']?.toString();
      if (orderId != null && category == 'Pesanan') {
        await ref.read(orderHistoryProvider.notifier).refresh();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(routerProvider).push('/order-detail?order_id=$orderId');
        });
      }
    }

    // Listen for foreground messages — daftarkan SEBELUM permission
    // supaya tidak ada message yang terlewat.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        '[FCM foreground] title=${message.notification?.title} body=${message.notification?.body}',
      );
      if (!mounted) return;
      final notification = message.notification;
      if (notification == null) return;

      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(notification.body ?? notification.title ?? ''),
          duration: const Duration(seconds: 4),
        ),
      );

      ref.read(orderHistoryProvider.notifier).silentRefresh();
      ref.read(notificationListProvider.notifier).silentRefresh();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (!mounted) return;

      await ref.read(orderHistoryProvider.notifier).refresh();
      ref.read(notificationListProvider.notifier).silentRefresh();

      final data = message.data;
      final orderId = data['order_id']?.toString();
      final category = data['category']?.toString();

      if (orderId != null && category == 'Pesanan') {
        ref.read(routerProvider).push('/order-detail?order_id=$orderId');
      } else {
        ref.read(routerProvider).go('/');
      }
    });

    // Request permission (required for Android 13+)
    try {
      await messaging.requestPermission(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('[FCM] requestPermission error: $e');
    }

    // Ambil token untuk debugging
    final token = await messaging.getToken();
    debugPrint('[FCM] token: $token');
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      scaffoldMessengerKey: _scaffoldKey,
      title: 'Xing Fu Tang Indonesia',
      debugShowCheckedModeBanner: false,
      locale: kIsWeb ? DevicePreview.locale(context) : null,
      builder: kIsWeb ? DevicePreview.appBuilder : null,
      routerConfig: router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
    );
  }
}
