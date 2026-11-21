import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/shared/models/money.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_app/features/wishlist/presentation/providers/wishlist_provider.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    final wishlistNotifier = ref.read(wishlistProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ទំនិញដែលបានរក្សាទុក (Wishlist)'),
        actions: [
          if (wishlist.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'សម្អាតទាំងអស់',
              onPressed: () => wishlistNotifier.clearWishlist(),
            ),
        ],
      ),
      body: wishlist.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 72, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('មិនទាន់មានទំនិញរក្សាទុកទេ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('ចុចលើរូបបេះដូងដើម្បីរក្សាទុកទំនិញដែលអ្នកចូលចិត្ត', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/catalog'),
                    child: const Text('ទៅកាន់ទំនិញទាំងអស់'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: wishlist.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final product = wishlist[index];
                final money = Money(amount: product.price);

                return InkWell(
                  onTap: () => context.push('/product/${product.id}'),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: product.primaryImage,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              money.format(targetCurrency: Currency.usd),
                              style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.isOutOfStock ? 'អស់ស្តុក' : 'នៅសល់: ${product.stock}',
                              style: TextStyle(
                                fontSize: 11,
                                color: product.isOutOfStock ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_shopping_cart, color: AppTheme.primaryColor),
                            onPressed: product.isOutOfStock
                                ? null
                                : () {
                                    ref.read(cartProvider.notifier).addToCart(product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('បានបន្ថែម ${product.name} ទៅក្នុងកន្ត្រក'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () => wishlistNotifier.removeFromWishlist(product.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
