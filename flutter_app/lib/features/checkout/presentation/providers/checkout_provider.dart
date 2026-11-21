import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:flutter_app/features/auth/presentation/providers/customer_auth_provider.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_app/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_app/features/orders/presentation/providers/orders_provider.dart';
import 'package:flutter_app/features/checkout/domain/models/checkout_models.dart';

class CheckoutNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    final customerAuth = ref.watch(customerAuthProvider);
    if (customerAuth.isAuthenticated && customerAuth.user != null) {
      final user = customerAuth.user!;
      return CheckoutState(
        address: ShippingAddress(
          name: user.name,
          phone: user.phone.isNotEmpty ? user.phone : '012 889 977',
          street: user.address.isNotEmpty ? user.address : 'ផ្ទះលេខ ១២, ផ្លូវ ២៧១',
          city: 'Phnom Penh',
        ),
      );
    }
    return const CheckoutState();
  }

  void updateAddress(ShippingAddress address) {
    state = state.copyWith(address: address);
  }

  void selectShippingOption(ShippingOption option) {
    state = state.copyWith(shippingOption: option);
  }

  void selectPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setPromoCode(String? code, double discount) {
    state = state.copyWith(promoCode: code, discountAmount: discount);
  }

  Future<OrderEntity?> placeOrder({
    required List<OrderItemEntity> items,
    required double subtotal,
    required double discount,
    String? promoCode,
  }) async {
    state = state.copyWith(isSubmitting: true);

    try {
      final dio = ref.read(dioProvider);

      final payload = {
        'user_id': ref.read(customerAuthProvider).user?.id ?? 'guest',
        'items': items
            .map((item) => {
                  'product_id': item.productId,
                  'quantity': item.quantity,
                })
            .toList(),
        'shipping_address': {
          'name': state.address.name,
          'phone': state.address.phone,
          'city': state.address.city,
          'district': 'Khan Boeng Keng Kang (BKK)',
          'street': state.address.street,
          'notes': state.address.note,
        },
        'payment_method': state.paymentMethod.name,
        'delivery_type': state.shippingOption.id == 'pickup' ? 'pickup' : 'delivery',
        'promo_code': promoCode ?? state.promoCode,
      };

      final response = await dio.post('/orders', data: payload);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final orderData = response.data['data'];
        final newOrder = OrderEntity.fromJson(orderData);

        ref.read(ordersProvider.notifier).addOrder(newOrder);
        ref.read(cartProvider.notifier).clearCart();

        state = state.copyWith(isSubmitting: false);
        return newOrder;
      }
    } catch (e) {
      // Local fallback in case server was stopped or network is temporarily offline
    }

    // Local fallback
    final orderId = 'PY-ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final total = (subtotal - discount + state.shippingOption.fee) > 0
        ? (subtotal - discount + state.shippingOption.fee)
        : 0.0;

    final fallbackOrder = OrderEntity(
      id: orderId,
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      items: items,
      subtotal: subtotal,
      discount: discount,
      shippingFee: state.shippingOption.fee,
      totalAmount: total,
      status: state.paymentMethod == PaymentMethod.khqr
          ? OrderStatus.pending
          : OrderStatus.preparing,
      paymentStatus: state.paymentMethod == PaymentMethod.cod
          ? PaymentStatus.unpaid
          : (state.paymentMethod == PaymentMethod.khqr
              ? PaymentStatus.unpaid
              : PaymentStatus.paid),
      paymentMethod: state.paymentMethod,
      shippingAddress: state.address.toJson(),
      createdAt: DateTime.now(),
    );

    ref.read(ordersProvider.notifier).addOrder(fallbackOrder);
    ref.read(cartProvider.notifier).clearCart();

    state = state.copyWith(isSubmitting: false);
    return fallbackOrder;
  }
}

final checkoutProvider =
    NotifierProvider<CheckoutNotifier, CheckoutState>(CheckoutNotifier.new);
