import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_app/features/catalog/domain/entities/product.dart';
import 'package:flutter_app/shared/models/money.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  Color _getSpiceColor(String spice) {
    switch (spice.toLowerCase()) {
      case 'hot':
        return Colors.orange.shade700;
      case 'extra':
        return Colors.red.shade700;
      default:
        return Colors.teal.shade700;
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
  Widget build(BuildContext context, WidgetRef ref) {
    final money = Money(amount: product.price);

    return InkWell(
      onTap: onTap ?? () => context.push('/product/${product.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Spice Badge & Out-of-stock badge
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: product.primaryImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFF8FAFC),
                        child: const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(Icons.restaurant, color: Colors.grey, size: 36),
                      ),
                    ),
                  ),

                  // Spice level tag
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4),
                        ],
                      ),
                      child: Text(
                        _getSpiceLabel(product.spiceLevel),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: _getSpiceColor(product.spiceLevel),
                        ),
                      ),
                    ),
                  ),

                  // Rating badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 11),
                          const SizedBox(width: 3),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Out of stock overlay
                  if (product.isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: const Center(
                          child: Text(
                            'អស់ស្តុក (Sold Out)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content Info
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (product.displaySubtitle.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      product.displaySubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Price and Quick Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            money.format(targetCurrency: Currency.usd),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            money.format(targetCurrency: Currency.khr),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Add to Cart Button (+)
                      Material(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: product.isOutOfStock
                              ? null
                              : () {
                                  ref.read(cartProvider.notifier).addToCart(product);
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('បានបញ្ចូល ${product.displayName} ទៅក្នុងកន្ត្រក'),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
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
