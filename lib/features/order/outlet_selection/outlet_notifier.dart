import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/features/order/outlet_selection/data/outlet_service.dart';
import 'package:xft/features/order/outlet_selection/models/outlet_model.dart';

class OutletListNotifier extends AsyncNotifier<OutletListResult> {
  @override
  Future<OutletListResult> build() {
    return ref.read(outletServiceProvider).fetchNearestOutlets();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final outletListProvider =
AsyncNotifierProvider<OutletListNotifier, OutletListResult>(OutletListNotifier.new);