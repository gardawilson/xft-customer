import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/order/cart/presentation/cart_notifier.dart';
import 'package:xft/features/order/cart/domain/models/cart_item_model.dart';

import 'menu_notifier.dart';
import 'models/product_model.dart';
import 'widgets/shake_widget.dart';
import 'widgets/sticky_tab_bar_delegate.dart';
import 'widgets/product_card.dart';
import 'widgets/top_pick_product_card.dart';
import 'widgets/sticky_cart_bar.dart';

class ListProductPage extends ConsumerStatefulWidget {
  final int outletId;
  final String outletName;
  final String outletAddress;

  const ListProductPage({
    super.key,
    required this.outletId,
    required this.outletName,
    required this.outletAddress,
  });

  @override
  ConsumerState<ListProductPage> createState() => ListProductPageState();
}

class ListProductPageState extends ConsumerState<ListProductPage>
    with TickerProviderStateMixin {
  bool _isSearching = false;
  late final TextEditingController _searchController;
  TabController? _tabController;
  late final ScrollController _scrollController;
  List<GlobalKey> _categoryKeys = [];
  int _activeTabIndex = 0;
  bool _isTabTapping = false;

  List<Category> _allCategories = [];
  List<Category> _displayCategories = [];

  final GlobalKey<ShakeWidgetState> _cartFabShakeKey =
  GlobalKey<ShakeWidgetState>();

  void _updateProductQuantity(Product product, int addedQuantity) async {
    await ref.read(cartProvider.notifier).addItem(
      outletId: widget.outletId,
      productId: product.id,
      quantity: addedQuantity,
    );
    if (mounted) {
      _cartFabShakeKey.currentState?.shake();
    }
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

  String _buildCartSummaryText(CartData? cart) {
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
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  /// Terapkan filter pencarian ke `_allCategories`, lalu sinkronkan
  /// `_displayCategories`, `_categoryKeys`, dan `_tabController` mengikuti
  /// hasilnya. Dipanggil dari dalam build() (data pertama kali datang) atau
  /// dari dalam setState() (perubahan pencarian / data refresh).
  void _applyCategories(List<Category> categories) {
    _allCategories = categories;
    final query = _searchController.text.trim().toLowerCase();

    final List<Category> filtered;
    if (query.isEmpty) {
      filtered = categories;
    } else {
      filtered = categories
          .map((c) => Category(
        id: c.id,
        name: c.name,
        products:
        c.products.where((p) => p.name.toLowerCase().contains(query)).toList(),
      ))
          .where((c) => c.products.isNotEmpty)
          .toList();
    }

    _displayCategories = filtered;
    _categoryKeys = List.generate(_displayCategories.length, (_) => GlobalKey());

    final newLength = _displayCategories.isEmpty ? 1 : _displayCategories.length;
    if (_tabController == null || newLength != _tabController!.length) {
      final oldController = _tabController;
      _tabController = TabController(length: newLength, vsync: this, initialIndex: 0);
      _activeTabIndex = 0;
      if (oldController != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => oldController.dispose());
      }
    } else if (_activeTabIndex >= newLength) {
      _activeTabIndex = 0;
      _tabController!.index = 0;
    }
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {
        _applyCategories(_allCategories);
      });
    }
  }

  void _onScroll() {
    if (_isTabTapping || _displayCategories.isEmpty || _tabController == null) return;

    double threshold = 122.0;
    int newIndex = 0;
    for (int i = 0; i < _categoryKeys.length; i++) {
      if (i >= _categoryKeys.length) break;
      final categoryContext = _categoryKeys[i].currentContext;
      if (categoryContext != null) {
        final box = categoryContext.findRenderObject() as RenderBox?;
        if (box != null) {
          final RenderViewport? viewport =
          categoryContext.findAncestorRenderObjectOfType<RenderViewport>();
          if (viewport != null) {
            final position = box.localToGlobal(Offset.zero, ancestor: viewport);
            if (position.dy <= threshold) {
              newIndex = i;
            }
          }
        }
      }
    }

    if (newIndex != _activeTabIndex && newIndex < _tabController!.length) {
      setState(() {
        _activeTabIndex = newIndex;
      });
      _tabController!.animateTo(newIndex);
    }
  }

  void _onTabTapped(int index) {
    if (_displayCategories.isEmpty || _tabController == null) return;
    _isTabTapping = true;
    _tabController!.animateTo(index);
    setState(() {
      _activeTabIndex = index;
    });

    if (index < _categoryKeys.length) {
      final context = _categoryKeys[index].currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ).then((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _isTabTapping = false;
          });
        });
      } else {
        _isTabTapping = false;
      }
    } else {
      _isTabTapping = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final menuAsync = ref.watch(menuListProvider(widget.outletId));
    final cartAsync = ref.watch(cartProvider);

    final cartData = cartAsync.value;
    final cartTotalItems = cartData?.totalItems ?? 0;
    final cartTotalPrice = cartData?.totalPrice ?? 0;
    final cartSummaryText = _buildCartSummaryText(cartData);
    final cartIsEmpty = cartData == null || cartData.items.isEmpty;

    ref.listen<AsyncValue<List<Category>>>(menuListProvider(widget.outletId), (previous, next) {
      next.whenData((categories) {
        if (mounted) {
          setState(() {
            _applyCategories(categories);
          });
        }
      });
    });

    // Kalau data ternyata sudah tersedia saat build pertama (mis. sudah pernah
    // dimuat sebelumnya), sinkronkan langsung tanpa menunggu perubahan state.
    if (menuAsync.hasValue && _tabController == null) {
      _applyCategories(menuAsync.value!);
    }

    return PopScope(
      canPop: !_isSearching && context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isSearching && mounted) {
          setState(() {
            _isSearching = false;
            _searchController.clear();
          });
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                floating: false,
                pinned: true,
                backgroundColor: colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                leading: GestureDetector(
                  onTap: () {
                    if (_isSearching) {
                      if (mounted) {
                        setState(() {
                          _isSearching = false;
                          _searchController.clear();
                        });
                      }
                    } else {
                      if (context.canPop()) {
                        context.pop();
                      }
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      _isSearching ? LucideIcons.x : LucideIcons.chevron_left,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
                title: _isSearching
                    ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Cari produk...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.black38),
                  ),
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.outletName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.xftSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.outletAddress,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                actions: [
                  if (!_isSearching)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSearching = true;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 56,
                          height: 56,
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.xftAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.search, color: AppColors.xftSurface, size: 28),
                        ),
                      ),
                    ),
                ],
              ),
              if (menuAsync.isLoading && _tabController == null)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (menuAsync.hasError && _tabController == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.circle_alert, size: 40, color: Colors.black38),
                          const SizedBox(height: 12),
                          Text(
                            menuAsync.error.toString().replaceFirst('Exception: ', ''),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                ref.read(menuListProvider(widget.outletId).notifier).refresh(),
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                  if (_displayCategories.isNotEmpty && _tabController != null)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: StickyTabBarDelegate(
                        child: Container(
                          transform: Matrix4.translationValues(0, -2, 0),
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          color: colorScheme.surface,
                          child: TabBar(
                            key: ValueKey(_displayCategories.length),
                            controller: _tabController,
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            dividerColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            indicator: BoxDecoration(
                              color: AppColors.xftSurface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: AppColors.xftAccent,
                            unselectedLabelColor: Colors.black54,
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            tabs: _displayCategories.map((cat) => Tab(text: cat.name)).toList(),
                            onTap: _onTabTapped,
                          ),
                        ),
                      ),
                    ),
                  if (_displayCategories.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final category = _displayCategories[index];
                        final isTopPick = category.name == 'Top Pick';
                        return Column(
                          key: _categoryKeys[index],
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category.name,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.xftSurface,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${category.products.length} item',
                                    style: TextStyle(
                                      color: AppColors.xftSurface.withValues(alpha: 0.7),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (isTopPick)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.65,
                                  ),
                                  itemCount: category.products.length,
                                  itemBuilder: (context, gridIndex) {
                                    final product = category.products[gridIndex];
                                    return TopPickProductCard(
                                      product: product,
                                      outletId: widget.outletId,
                                      onProductAdded: _updateProductQuantity,
                                    );
                                  },
                                ),
                              )
                            else
                              ...category.products.map(
                                    (product) => ProductCard(
                                  product: product,
                                  outletId: widget.outletId,
                                  onProductAdded: _updateProductQuantity,
                                ),
                              ),
                          ],
                        );
                      }, childCount: _displayCategories.length),
                    )
                  else
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.xftAccent.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.search, size: 40, color: AppColors.xftSurface),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSearching ? 'Produk tidak ditemukan' : 'Menu belum tersedia',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.xftSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isSearching ? 'Coba cari dengan nama produk lain' : 'Cek kembali beberapa saat lagi',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
            ],
          ),
        ),
        bottomNavigationBar: cartIsEmpty
            ? null
            : ShakeWidget(
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
    );
  }
}