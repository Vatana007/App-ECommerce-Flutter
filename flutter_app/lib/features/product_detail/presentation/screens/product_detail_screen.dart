import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/shared/models/money.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:flutter_app/features/wishlist/presentation/providers/wishlist_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  Color _getSpiceColor(String spice) {
    switch (spice.toLowerCase()) {
      case 'hot':
        return Colors.orange.shade800;
      case 'extra':
        return Colors.red.shade800;
      default:
        return Colors.teal.shade800;
    }
  }

  String _getSpiceLabel(String spice) {
    switch (spice.toLowerCase()) {
      case 'hot':
        return '🌶️ ហិរ (Hot)';
      case 'extra':
        return '🌶️🌶️ ហិរខ្លាំង (Extra)';
      default:
        return '🌿 ហិរតិច (Mild)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    ref.watch(wishlistProvider); // listen for updates
    final wishlistNotifier = ref.read(wishlistProvider.notifier);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Scaffold(
          appBar: AppBar(title: const Text('ព័ត៌មានលម្អិតមុខម្ហូប')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text('មិនអាចទាញទិន្នន័យបាន: $err'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(productDetailProvider(widget.productId)),
                  child: const Text('ព្យាយាមម្តងទៀត'),
                ),
              ],
            ),
          ),
        ),
        data: (product) {
          final isFavorite = wishlistNotifier.isInWishlist(product.id);
          final money = Money(amount: product.price);

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    leading: CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.85),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    actions: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.85),
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.black87,
                          ),
                          onPressed: () => wishlistNotifier.toggleWishlist(product),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.85),
                        child: IconButton(
                          icon: const Icon(Icons.share_outlined, color: Colors.black87),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('បានចម្លងតំណភ្ជាប់មុខម្ហូប (Copied link)')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: CachedNetworkImage(
                        imageUrl: product.primaryImage,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.restaurant, color: Colors.grey, size: 64),
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    money.format(targetCurrency: Currency.usd),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    money.format(targetCurrency: Currency.khr),
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getSpiceColor(product.spiceLevel).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getSpiceLabel(product.spiceLevel),
                                      style: TextStyle(
                                        color: _getSpiceColor(product.spiceLevel),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: product.isOutOfStock ? Colors.red.shade50 : Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      product.isOutOfStock ? 'អស់ស្តុក' : 'មានស្រាប់',
                                      style: TextStyle(
                                        color: product.isOutOfStock ? Colors.red : Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Text(
                            product.displayName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
                          ),
                          if (product.displaySubtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              product.displaySubtitle,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                            ),
                          ],

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${product.rating}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(${product.reviewCount} ការវាយតម្លៃ)',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(width: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  product.categoryId.toUpperCase(),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 32),

                          // Quantity Selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ចំនួនកុម្ម៉ង់ (Quantity):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text(
                                    '$_quantity',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() => _quantity++),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Description
                          const Text(
                            'ការពិពណ៌នាមុខម្ហូប (Description)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.descKm.isNotEmpty ? product.descKm : product.description,
                            style: const TextStyle(color: Color(0xFF334155), fontSize: 14, height: 1.5),
                          ),
                          if (product.descEn.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              product.descEn,
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                            ),
                          ],

                          const SizedBox(height: 100), // padding for bottom bar
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('តម្លៃសរុប:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            Money(amount: product.price * _quantity).format(targetCurrency: Currency.usd),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: product.isOutOfStock
                                ? null
                                : () {
                                    cartNotifier.addToCart(product, quantity: _quantity);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('បានបញ្ចូល ${product.displayName} x$_quantity ទៅក្នុងកន្ត្រក'),
                                        duration: const Duration(seconds: 2),
                                        action: SnackBarAction(
                                          label: 'មើលកន្ត្រក',
                                          textColor: Colors.yellow,
                                          onPressed: () => context.push('/cart'),
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.add_shopping_cart, size: 20),
                            label: const Text(
                              'បញ្ចូលទៅក្នុងកន្ត្រក (Add to Cart)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
