import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/theme/app_colors.dart';
import '../models/product_model.dart';
import 'product_badge_widget.dart';
import '../../cart/presentation/cart_notifier.dart';

class ProductDetailSheet extends ConsumerStatefulWidget {
  final Product product;
  final int outletId;
  final int? initialQuantity;
  final bool isEdit;

  const ProductDetailSheet({
    super.key,
    required this.product,
    required this.outletId,
    this.initialQuantity,
    this.isEdit = false,
  });

  @override
  ConsumerState<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends ConsumerState<ProductDetailSheet> {
  late int _quantity;
  bool _isSubmitting = false;
  ProductVariant? _selectedVariant;
  final Map<String, dynamic> _selectedModifiers = {};

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity ?? 1;
    if (widget.product.hasVariants && widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.variants.first;
    }
    for (final group in widget.product.modifierGroups) {
      if (group.isSingleSelect && group.options.isNotEmpty) {
        _selectedModifiers[group.name] = group.options.first.name;
      } else {
        _selectedModifiers[group.name] = <String>[];
      }
    }
  }

  int _getUnitPrice() {
    if (_selectedVariant != null) {
      return _selectedVariant!.price;
    }
    return int.tryParse(
          widget.product.price.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
  }

  int _calculateTotal() {
    int modifierExtra = 0;
    for (final group in widget.product.modifierGroups) {
      final selected = _selectedModifiers[group.name];
      if (selected is String) {
        final opt = group.options.where((o) => o.name == selected).toList();
        if (opt.isNotEmpty) modifierExtra += opt.first.additionalPrice;
      } else if (selected is List<String>) {
        for (final name in selected) {
          final opt = group.options.where((o) => o.name == name).toList();
          if (opt.isNotEmpty) modifierExtra += opt.first.additionalPrice;
        }
      }
    }
    return (_getUnitPrice() + modifierExtra) * _quantity;
  }

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

  bool get _canConfirm {
    if (widget.product.hasVariants && _selectedVariant == null) {
      return false;
    }
    for (final group in widget.product.modifierGroups) {
      if (group.isRequired) {
        final selected = _selectedModifiers[group.name];
        if (selected is String && selected.isEmpty) return false;
        if (selected is List && selected.length < group.minSelect) return false;
      }
    }
    return true;
  }

  Future<void> _handleConfirm() async {
    if (!_canConfirm) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref
          .read(cartProvider.notifier)
          .addItem(
            outletId: widget.outletId,
            productId: widget.product.id,
            quantity: _quantity,
            variantId: _selectedVariant?.id,
            selectedModifiers: _selectedModifiers.isNotEmpty
                ? _selectedModifiers
                : null,
          );

      if (!mounted) {
        return;
      }
      Navigator.pop(context, {'success': true, 'quantity': _quantity});
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();
    final hasVariants = widget.product.hasVariants;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.xftAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Center(
                        child: Image.network(
                          widget.product.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            LucideIcons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.product.badge != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: ProductBadgeWidget(
                                badge: widget.product.badge!,
                                showLabel: true,
                              ),
                            ),
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.xftSurface,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedVariant != null
                                ? _formatPrice(_selectedVariant!.price)
                                : hasVariants
                                    ? _formatPrice(widget.product.minPrice)
                                    : widget.product.price,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.xftPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Colors.black12),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              children: [
                if (hasVariants) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ukuran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.xftSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: widget.product.variants.map((variant) {
                      final isSelected = _selectedVariant?.id == variant.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedVariant = variant;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.xftSurface
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.xftSurface
                                  : Colors.black26,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            variant.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.xftSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                for (final group in widget.product.modifierGroups) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.xftSurface,
                        ),
                      ),
                      if (group.isRequired)
                        Text(
                          'Wajib',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.xftPrimary.withValues(alpha: 0.6),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (group.maxSelect > 1)
                    Text(
                      'Maks. ${group.maxSelect} pilihan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: group.options.map((option) {
                      final selected = _selectedModifiers[group.name];
                      final isSelected = selected is String
                          ? selected == option.name
                          : selected is List<String> &&
                              selected.contains(option.name);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (group.isSingleSelect) {
                              _selectedModifiers[group.name] = option.name;
                            } else {
                              final list =
                                  _selectedModifiers[group.name] as List<String>;
                              if (list.contains(option.name)) {
                                list.remove(option.name);
                              } else if (list.length < group.maxSelect) {
                                list.add(option.name);
                              }
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.xftSurface
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.xftSurface
                                  : Colors.black26,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!group.isSingleSelect) ...[
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.xftSurface,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          LucideIcons.check,
                                          size: 12,
                                          color: AppColors.xftSurface,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                option.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.xftSurface,
                                ),
                              ),
                              if (option.additionalPrice > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '(+${_formatPrice(option.additionalPrice)})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Jumlah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.xftSurface,
                      ),
                    ),
                    Row(
                      children: [
                        _QuantityButton(
                          icon: LucideIcons.minus,
                          onTap: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '$_quantity',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.xftSurface,
                            ),
                          ),
                        ),
                        _QuantityButton(
                          icon: LucideIcons.plus,
                          onTap: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 32,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.xftSurface,
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Batalkan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: (_isSubmitting || !_canConfirm)
                        ? null
                        : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.xftSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatPrice(total),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.xftAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.isEdit
                                      ? LucideIcons.check
                                      : LucideIcons.plus,
                                  color: AppColors.xftSurface,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return Material(
      color: isDisabled ? Colors.black12 : AppColors.xftSurface,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            color: isDisabled ? Colors.black38 : AppColors.xftAccent,
            size: 16,
          ),
        ),
      ),
    );
  }
}
