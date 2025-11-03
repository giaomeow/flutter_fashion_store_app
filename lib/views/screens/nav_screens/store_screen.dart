import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app_new/controllers/product_controller.dart';
import 'package:mac_store_app_new/models/product.dart';
import 'package:mac_store_app_new/views/detail/screens/product_detail_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/widgets/product_item_widget.dart';

class StoreScreen extends StatefulWidget {
  final String? initialSearchQuery;
  
  const StoreScreen({
    super.key,
    this.initialSearchQuery,
  });

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final ProductController _productController = ProductController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'New'; // New, Popular, Recommend
  String _selectedSort =
      'Newest'; // Newest, PriceLow, PriceHigh, NameAZ, NameZA
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    // Nếu có initialSearchQuery, set vào search controller và load products
    if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
      _searchController.text = widget.initialSearchQuery!;
      _loadProducts(_selectedFilter, searchQuery: widget.initialSearchQuery);
    } else {
      _loadProducts(_selectedFilter);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts(String filterType, {String? searchQuery}) async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Product> products;

      // Nếu có search query, gọi API search (có thể kết hợp với type)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        products = await _productController.searchProducts(
          searchQuery,
          type: filterType.toLowerCase(), // new, popular, recommend
        );
      } else {
        // Nếu không có search, gọi API theo filter type
        switch (filterType) {
          case 'New':
            products = await _productController.getNewProducts();
            break;
          case 'Popular':
            products = await _productController.getPopularProducts();
            break;
          case 'Recommend':
            products = await _productController.getRecommendedProducts();
            break;
          default:
            products = await _productController.getNewProducts();
        }
      }

      setState(() {
        _allProducts = products;
        _isLoading = false;
      });
      // Apply sort after loading
      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading products: $e');
    }
  }

  void _applyFilters() {
    if (_allProducts.isEmpty) {
      setState(() {
        _filteredProducts = [];
      });
      return;
    }

    // Data đã được filter từ API, chỉ cần sort
    List<Product> filtered = List.from(_allProducts);

    // Apply sort
    switch (_selectedSort) {
      case 'PriceLow':
        filtered.sort((a, b) {
          final priceA =
              double.tryParse(a.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          final priceB =
              double.tryParse(b.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'PriceHigh':
        filtered.sort((a, b) {
          final priceA =
              double.tryParse(a.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          final priceB =
              double.tryParse(b.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'NameAZ':
        filtered.sort(
          (a, b) => a.productName.toLowerCase().compareTo(
            b.productName.toLowerCase(),
          ),
        );
        break;
      case 'NameZA':
        filtered.sort(
          (a, b) => b.productName.toLowerCase().compareTo(
            a.productName.toLowerCase(),
          ),
        );
        break;
      case 'Newest':
      default:
        // Giữ nguyên thứ tự từ API
        break;
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadProducts(_selectedFilter),
          child: CustomScrollView(
            slivers: [
              // Search bar and filters
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Search bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: GoogleFonts.quicksand(
                              color: Colors.grey.shade600,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade600,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey.shade600,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                      });
                                      // Reload products không có search
                                      _loadProducts(_selectedFilter);
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: GoogleFonts.quicksand(),
                          onChanged: (value) {
                            setState(() {});
                            // Debounce search để tránh gọi API quá nhiều
                            _searchDebounce?.cancel();
                            _searchDebounce = Timer(
                              const Duration(milliseconds: 500),
                              () {
                                // Gọi API search
                                _loadProducts(
                                  _selectedFilter,
                                  searchQuery: value.trim(),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Filter tabs (bên phải)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildFilterTab('New'),
                                _buildFilterTab('Popular'),
                                _buildFilterTab('Recommend'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Products grid
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_filteredProducts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'No products found'
                              : 'No products available',
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.52,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = _filteredProducts[index];
                      return ProductItemWidget(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(productId: product.id),
                            ),
                          );
                        },
                      );
                    }, childCount: _filteredProducts.length),
                  ),
                ),
              // Results count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      '${_filteredProducts.length} products found',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
        // Gọi API tương ứng khi click tab
        _loadProducts(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
