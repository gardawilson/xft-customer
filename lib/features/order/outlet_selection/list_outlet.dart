import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/presentation/widgets/back_button_app_bar.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/order/outlet_selection/loading_outlet.dart';
import 'package:xft/features/order/outlet_selection/outlet_notifier.dart';
import 'package:xft/features/order/outlet_selection/widgets/nearest_outlet_card.dart';
import 'package:xft/features/order/outlet_selection/widgets/other_outlet_item.dart';

class ListOutletPage extends ConsumerWidget {
  const ListOutletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final outletsAsync = ref.watch(outletListProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const BackButtonAppBar(),
      body: outletsAsync.when(
        loading: () => const LoadingOutletPage(),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off_outlined, size: 48, color: Colors.black38),
                const SizedBox(height: 16),
                Text(
                  error.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(outletListProvider.notifier).refresh(),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (result) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          Text(
                            'Yeeay!',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ada Xing Fu Tang di lokasimu',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (result.closest != null) NearestOutletCard(outlet: result.closest!),
                    if (result.others.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Opsi outlet lainnya',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.surface),
                            ),
                            Text('${result.others.length} outlet', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (int i = 0; i < result.others.length; i++) ...[
                        OtherOutletItem(outlet: result.others[i]),
                        if (i != result.others.length - 1) const Divider(height: 1, color: Colors.black12),
                      ],
                    ],
                    if (result.closest == null && result.others.isEmpty) ...[
                      const SizedBox(height: 40),
                      const Text(
                        'Belum ada outlet aktif di sekitar lokasimu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}