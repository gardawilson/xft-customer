import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/features/auth/presentation/forgot_password_page.dart';
import 'package:xft/features/auth/presentation/login_page.dart';
import 'package:xft/features/auth/presentation/register_page.dart';
import 'package:xft/features/auth/presentation/reset_password_page.dart';
import 'package:xft/features/auth/presentation/fallback_phone_page.dart';
import 'package:xft/core/presentation/pages/web_view_page.dart';
import 'package:xft/features/notification/presentation/notification_page.dart';
import 'package:xft/features/home/presentation/home_page.dart';
import 'package:xft/features/onboarding/presentation/loader_page.dart';
import 'package:xft/core/presentation/pages/empty_page.dart';
import 'package:xft/core/presentation/pages/session_off_page.dart';
import 'package:xft/core/presentation/pages/gps_inactive.dart';
import 'package:xft/features/order/outlet_selection/loading_outlet.dart';
import 'package:xft/features/order/outlet_selection/list_outlet.dart';
import 'package:xft/features/order/product/list_product.dart';
import 'package:xft/features/setting/presentation/contact_us_page.dart';
import 'package:xft/features/setting/presentation/password_edit_page.dart';
import 'package:xft/features/setting/presentation/profile_edit_page.dart';
import 'package:xft/features/promo/domain/models/promo_model.dart';
import 'package:xft/features/promo/presentation/promo_detail_page.dart';
import 'package:xft/features/order/outlet_selection/models/outlet_model.dart';
import 'package:xft/features/order/cart/presentation/cart_page.dart';
import 'package:xft/features/order/payment/presentation/payment_webview_page.dart';
import 'package:xft/features/order/payment/presentation/espay_va_page.dart';
import 'package:xft/features/order/payment/data/order_service.dart';
import 'package:xft/features/order/payment/presentation/payment_result_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<bool>(false);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/notification',
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: '/promo-detail',
        builder: (context, state) {
          final promoId = state.extra as int;
          return PromoDetailPage(promoId: promoId);
        },
      ),
      GoRoute(
        path: '/loading-outlet',
        builder: (context, state) => const LoadingOutletPage(),
      ),
      GoRoute(
        path: '/list-outlet',
        builder: (context, state) => const ListOutletPage(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/payment-webview',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return PaymentWebviewPage(
            paymentUrl: extra['payment_url']!,
            orderNumber: extra['order_number']!,
          );
        },
      ),
      GoRoute(
        path: '/payment-espay-va',
        builder: (context, state) {
          final result = state.extra as CheckoutResult;
          return EspayVaPage(checkoutResult: result);
        },
      ),
      GoRoute(
        path: '/payment-result',
        builder: (context, state) {
          final status = state.uri.queryParameters['status'] ?? 'pending';
          final orderNumber = state.uri.queryParameters['order_number'] ?? '';
          return PaymentResultPage(status: status, orderNumber: orderNumber);
        },
      ),

      // GoRoute(
      //   path: '/list-product',
      //   builder: (context, state) => const ListProductPage(),
      // ),
      GoRoute(
        path: '/list-product',
        builder: (context, state) {
          final outlet = state.extra as OutletModel;
          return ListProductPage(
            outletId: outlet.id,
            outletName: outlet.name,
            outletAddress: outlet.address,
          );
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/edit-password',
        builder: (context, state) => const EditPasswordPage(),
      ),
      GoRoute(
        path: '/session-off',
        builder: (context, state) => const SessionOffPage(),
      ),
      GoRoute(
        path: '/empty',
        builder: (context, state) => const EmptyPage(),
      ),
      GoRoute(
        path: '/inactive-gps',
        builder: (context, state) => const GpsInactivePage(),
      ),
      GoRoute(
        path: '/loader',
        builder: (context, state) => const LoaderPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final otp = state.uri.queryParameters['otp'] ?? '';
          return ResetPasswordPage(otp: otp);
        },
      ),
      GoRoute(
        path: '/fallback-phone',
        builder: (context, state) => const FallbackPhonePage(),
      ),
      GoRoute(
        path: '/contact-us',
        builder: (context, state) => const ContactUsPage(),
      ),
      GoRoute(
        path: '/web-view',
        builder: (context, state) {
          final url = state.uri.queryParameters['url'] ?? '';
          final title = state.uri.queryParameters['title'] ?? '';
          return WebViewPage(url: url, title: title);
        },
      ),
    ],
  );
});
