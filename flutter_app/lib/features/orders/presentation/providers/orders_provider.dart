import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:flutter_app/features/orders/domain/entities/order_entity.dart';

class OrdersNotifier extends Notifier<List<OrderEntity>> {
  @override
  List<OrderEntity> build() {
    _fetchOrders();
    return [];
  }

  Future<void> _fetchOrders() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/orders');
      if (response.statusCode == 200) {
        final List raw = response.data['data'] ?? [];
        final orders = raw.map((json) => OrderEntity.fromJson(json)).toList();
        if (orders.isNotEmpty) {
          state = orders;
        }
      }
    } catch (_) {
      // Use fallback if offline
    }
  }

  void addOrder(OrderEntity order) {
    state = [order, ...state.where((o) => o.id != order.id)];
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    state = [
      for (final o in state)
        if (o.id == orderId) o.copyWith(status: status) else o
    ];
  }

  void markOrderAsPaid(String orderId) {
    state = [
      for (final o in state)
        if (o.id == orderId)
          o.copyWith(
            paymentStatus: PaymentStatus.paid,
            status: OrderStatus.preparing,
            paidAt: DateTime.now(),
          )
        else
          o
    ];
  }

  OrderEntity? findById(String orderId) {
    try {
      return state.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }
}

final ordersProvider =
    NotifierProvider<OrdersNotifier, List<OrderEntity>>(OrdersNotifier.new);

final orderDetailProvider =
    Provider.family<OrderEntity?, String>((ref, orderId) {
  final orders = ref.watch(ordersProvider);
  try {
    return orders.firstWhere((o) => o.id == orderId);
  } catch (_) {
    return null;
  }
});
