import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/catalog/domain/entities/product.dart';

class WishlistNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() => [];

  bool isInWishlist(String productId) {
    return state.any((product) => product.id == productId);
  }

  void toggleWishlist(Product product) {
    if (isInWishlist(product.id)) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [...state, product];
    }
  }

  void removeFromWishlist(String productId) {
    state = state.where((p) => p.id != productId).toList();
  }

  void clearWishlist() {
    state = [];
  }
}

final wishlistProvider =
    NotifierProvider<WishlistNotifier, List<Product>>(WishlistNotifier.new);
