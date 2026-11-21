import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:flutter_app/features/catalog/domain/entities/product.dart';
import 'package:flutter_app/features/cart/domain/entities/cart_item.dart';

class CartState {
  final Map<String, CartItem> items;
  final String? promoCode;
  final double discountPercent; // e.g. 0.10 for 10%
  final double fixedDiscount;   // e.g. 2.00 for $2

  const CartState({
    this.items = const {},
    this.promoCode,
    this.discountPercent = 0.0,
    this.fixedDiscount = 0.0,
  });

  List<CartItem> get itemList => items.values.toList();
  int get totalItemCount => items.values.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.values.fold(0.0, (sum, item) => sum + item.subtotal);
  double get discountAmount => (subtotal * discountPercent) + fixedDiscount;
  double get totalPrice => (subtotal - discountAmount) > 0 ? (subtotal - discountAmount) : 0.0;
  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    Map<String, CartItem>? items,
    String? promoCode,
    double? discountPercent,
    double? fixedDiscount,
  }) {
    return CartState(
      items: items ?? this.items,
      promoCode: promoCode ?? this.promoCode,
      discountPercent: discountPercent ?? this.discountPercent,
      fixedDiscount: fixedDiscount ?? this.fixedDiscount,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  void addToCart(Product product, {int quantity = 1}) {
    final currentMap = Map<String, CartItem>.from(state.items);
    if (currentMap.containsKey(product.id)) {
      final existing = currentMap[product.id]!;
      currentMap[product.id] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      currentMap[product.id] = CartItem(product: product, quantity: quantity);
    }
    state = state.copyWith(items: currentMap);
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final currentMap = Map<String, CartItem>.from(state.items);
    if (currentMap.containsKey(productId)) {
      currentMap[productId] = currentMap[productId]!.copyWith(quantity: newQuantity);
      state = state.copyWith(items: currentMap);
    }
  }

  void removeFromCart(String productId) {
    final currentMap = Map<String, CartItem>.from(state.items);
    currentMap.remove(productId);
    state = state.copyWith(items: currentMap);
  }

  Future<bool> applyPromoCode(String code) async {
    final clean = code.trim().toUpperCase();

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/promos/validate', data: {
        'code': clean,
        'subtotal': state.subtotal,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final discountType = data['discount_type']?.toString();
        final rate = (data['rate'] as num?)?.toDouble() ?? 0.0;

        if (discountType == 'percentage') {
          state = state.copyWith(
            promoCode: clean,
            discountPercent: rate / 100.0,
            fixedDiscount: 0.0,
          );
        } else {
          state = state.copyWith(
            promoCode: clean,
            discountPercent: 0.0,
            fixedDiscount: rate,
          );
        }
        return true;
      }
    } catch (_) {
      // Offline fallback
    }

    if (clean == 'PHUM10' || clean == 'DISCOUNT10' || clean == 'PROMO10') {
      state = state.copyWith(promoCode: clean, discountPercent: 0.10, fixedDiscount: 0.0);
      return true;
    } else if (clean == 'KHMER20' || clean == 'VIP20') {
      state = state.copyWith(promoCode: clean, discountPercent: 0.20, fixedDiscount: 0.0);
      return true;
    } else if (clean == 'FREESHIP') {
      state = state.copyWith(promoCode: clean, discountPercent: 0.0, fixedDiscount: 1.50);
      return true;
    }
    return false;
  }

  void removePromoCode() {
    state = state.copyWith(promoCode: null, discountPercent: 0.0, fixedDiscount: 0.0);
  }

  void clearCart() {
    state = const CartState();
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);
