import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/home/domain/models/order_model.dart';
import 'package:xft/features/order/history/presentation/order_history_notifier.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String formatOrderDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  final hh = date.hour.toString().padLeft(2, '0');
  final mm = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${months[date.month - 1]} ${date.year} $hh:$mm';
}

String formatOrderCurrency(int amount) {
  final s = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}

// ── Accordion Card ─────────────────────────────────────────────────────────────

/// Expandable card showing all details of a single [Order].
class OrderAccordionCard extends ConsumerStatefulWidget {
  final Order order;

  const OrderAccordionCard({super.key, required this.order});

  @override
  ConsumerState<OrderAccordionCard> createState() => _OrderAccordionCardState();
}

class _OrderAccordionCardState extends ConsumerState<OrderAccordionCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  bool _isConfirmingPickup = false;

  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0, // start fully expanded
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    _isExpanded ? _controller.forward() : _controller.reverse();
  }

  Future<void> _confirmPickup(Order order) async {
    setState(() => _isConfirmingPickup = true);
    try {
      await ref.read(orderHistoryProvider.notifier).confirmPickup(order.orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terima kasih! Pesanan sudah dikonfirmasi diambil.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isConfirmingPickup = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          InkWell(
            onTap: _toggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderId,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surface,
                      letterSpacing: 0.2,
                    ),
                  ),
                  RotationTransition(
                    turns: _rotateAnimation,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 18,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                  Text(
                    formatOrderDate(order.orderDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Collapsible body ─────────────────────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kDivider,

                // Items
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: order.items.asMap().entries.map((e) {
                      return OrderItemRow(
                        item: e.value,
                        index: e.key,
                        isLast: e.key == order.items.length - 1,
                      );
                    }).toList(),
                  ),
                ),

                _kDivider,

                // Payment summary
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    children: [
                      OrderSummaryRow(
                        label: 'Sub Total',
                        value: formatOrderCurrency(order.subTotal),
                      ),
                      if (order.promoDiscount != null) ...[
                        const SizedBox(height: 6),
                        OrderSummaryRow(
                          label:
                              'Promo (${order.promoLabel ?? 'Diskon'})',
                          value: formatOrderCurrency(order.promoDiscount!),
                          isDiscount: true,
                        ),
                      ],
                      const SizedBox(height: 6),
                      OrderSummaryRow(
                        label: 'Total Pembayaran',
                        value: formatOrderCurrency(order.totalPayment),
                        isBold: true,
                      ),
                      const SizedBox(height: 6),
                      OrderSummaryRow(
                        label: 'Metode Pembayaran',
                        value: order.paymentMethod,
                        isBold: true,
                        isTextValue: true,
                      ),
                    ],
                  ),
                ),

                _kDivider,

                // Pickup location
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi Pick Up',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.pickupLocationName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.surface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.pickupLocationAddress,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.15),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: Colors.black.withValues(alpha: 0.5),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                _kDivider,

                // Status stepper
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OrderStatusStepper(status: order.status),
                ),

                // Konfirmasi pickup -- cuma muncul kalau pesanan sudah "Siap Diambil"
                if (order.status == OrderStatus.readyForPickup)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isConfirmingPickup ? null : () => _confirmPickup(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isConfirmingPickup
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Pickup Pesanan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Divider constant ──────────────────────────────────────────────────────────

final _kDivider = Divider(
  height: 1,
  thickness: 1,
  color: Colors.black.withValues(alpha: 0.06),
);

// ── Order Item Row ─────────────────────────────────────────────────────────────

class OrderItemRow extends StatelessWidget {
  final OrderItem item;
  final int index;
  final bool isLast;

  const OrderItemRow({
    super.key,
    required this.item,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 56,
              height: 56,
              color: AppColors.background,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.local_drink_outlined,
                  color: AppColors.surface,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.modifierSummary ?? '#${index + 1}  ${item.size} • ${item.ice} • ${item.sugar}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
                if (item.addOns.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  ...item.addOns.map(
                    (a) => Text(
                      '+ ${a.name}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Price
          Text(
            formatOrderCurrency(item.price),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary Row ───────────────────────────────────────────────────────────────

class OrderSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final bool isDiscount;
  final bool isTextValue;

  const OrderSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.isDiscount = false,
    this.isTextValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black.withValues(alpha: isBold ? 0.85 : 0.55),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: isDiscount
                ? AppColors.primary
                : (isBold ? AppColors.surface : Colors.black87),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ── Status Stepper ─────────────────────────────────────────────────────────────

class OrderStatusStepper extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusStepper({super.key, required this.status});

  static const _steps = [
    (label: 'Waiting', status: OrderStatus.waiting),
    (label: 'Preparing', status: OrderStatus.preparing),
    (label: 'Ready for Pick Up', status: OrderStatus.readyForPickup),
  ];

  @override
  Widget build(BuildContext context) {
    // Pesanan batal/ditolak bukan bagian dari alur 3 langkah normal —
    // tampilkan label status saja, bukan stepper yang bisa menyesatkan.
    if (status == OrderStatus.canceled || status == OrderStatus.rejected) {
      final isCanceled = status == OrderStatus.canceled;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isCanceled ? 'Pesanan Dibatalkan' : 'Pesanan Ditolak',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      );
    }

    // Pesanan yang sudah selesai diambil -- tampilkan banner sukses,
    // bukan stepper 3 langkah (yang seharusnya cuma untuk pesanan aktif).
    if (status == OrderStatus.completed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Pesanan Selesai',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      );
    }

    final currentIndex = _steps.indexWhere((s) => s.status == status);

    return Row(
      children: _steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final isDone = i <= currentIndex;
        final isActive = i == currentIndex;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppColors.primary
                            : Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isDone
                            ? AppColors.primary
                            : Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              if (i < _steps.length - 1)
                Expanded(
                  child: Container(
                    height: 1.5,
                    margin: const EdgeInsets.only(bottom: 18),
                    color: i < currentIndex
                        ? AppColors.primary
                        : Colors.black.withValues(alpha: 0.15),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
