import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';

class LoaderPage extends StatelessWidget {
  const LoaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: GestureDetector(
          onTap: () => context.go('/login'),
          child: SizedBox(
            width: 180,
            height: 180,
            child: Lottie.asset(
              'assets/images/ic_loader.json',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
