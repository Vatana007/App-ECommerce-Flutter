import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/shared/models/money.dart';
import 'package:flutter_app/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_app/features/orders/presentation/providers/orders_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderDetailProvider(orderId));

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ព័ត៌មានការកុម្ម៉ង់')),
        body: const Center(child: Text('រកមិនឃើញការកុម្ម៉ង់នេះទេ')),
      );
    }

    final money = Money(amount: order.totalAmount);

    return Scaffold(
      appBar: AppBar(
        title: Text('វិក្កយបត្រ #${order.id}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'ត្រឡប់ក្រោយ',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTrackingTimeline(order.status),

            const SizedBox(height: 20),

            _sectionHeader('មុខទំនិញ (${order.items.length})'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: order.items.length,
                separatorBuilder: (context, index) => const Divider(height: 20),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.image != null
                            ? CachedNetworkImage(
                                imageUrl: item.image!,
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover,
                              )
                            : Container(width: 55, height: 55, color: Colors.grey.shade200),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${item.price.toStringAsFixed(2)} x ${item.quantity}',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${item.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            _sectionHeader('អាសយដ្ឋានដឹកជញ្ជូន'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order.shippingAddress['name']} (${order.shippingAddress['phone']})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.shippingAddress['street']}, ${order.shippingAddress['city']}',
                    style: const TextStyle(color: Color(0xFF475569), fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionHeader('ព័ត៌មានទូទាត់ប្រាក់'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _infoRow('វិធីសាស្រ្ត:', order.paymentMethodDisplay),
                  const Divider(height: 20),
                  _infoRow(
                    'ស្ថានភាពបង់ប្រាក់:',
                    order.paymentStatus == PaymentStatus.paid ? 'បានបង់ប្រាក់រួច (PAID)' : 'មិនទាន់បង់ប្រាក់ (UNPAID)',
                    textColor: order.paymentStatus == PaymentStatus.paid ? Colors.green : Colors.orange,
                  ),
                  const Divider(height: 20),
                  _infoRow('តម្លៃទំនិញ (Subtotal):', '\$${order.subtotal.toStringAsFixed(2)}'),
                  if (order.discount > 0) ...[
                    const SizedBox(height: 8),
                    _infoRow('បញ្ចុះតម្លៃ (Discount):', '-\$${order.discount.toStringAsFixed(2)}', textColor: Colors.green),
                  ],
                  const SizedBox(height: 8),
                  _infoRow('ថ្លៃដឹកជញ្ជូន:', '\$${order.shippingFee.toStringAsFixed(2)}'),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ទឹកប្រាក់សរុប:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(
                        money.format(targetCurrency: Currency.usd),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (order.paymentStatus == PaymentStatus.unpaid && order.paymentMethod == PaymentMethod.khqr) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE1192A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('បង់ប្រាក់ជាមួយ Bakong KHQR ឥឡូវនេះ', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => context.push('/khqr-payment', extra: order),
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text(
                  'ត្រឡប់ទៅទំព័រដើម (Back to Home)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
    );
  }

  Widget _infoRow(String label, String value, {Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor ?? Colors.black87, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTrackingTimeline(OrderStatus currentStatus) {
    final steps = [
      {'status': OrderStatus.pending, 'label': 'បញ្ជាក់'},
      {'status': OrderStatus.processing, 'label': 'រៀបចំ'},
      {'status': OrderStatus.shipped, 'label': 'ដឹកជញ្ជូន'},
      {'status': OrderStatus.delivered, 'label': 'បានទទួល'},
    ];

    int currentIndex = steps.indexWhere((s) => s['status'] == currentStatus);
    if (currentIndex == -1) currentIndex = 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ដំណាក់កាលដឹកជញ្ជូន (Tracking Progress)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final isPassed = (i ~/ 2) < currentIndex;
                return Expanded(
                  child: Container(
                    height: 3,
                    color: isPassed ? AppTheme.primaryColor : Colors.grey.shade300,
                  ),
                );
              } else {
                final stepIndex = i ~/ 2;
                final isDone = stepIndex <= currentIndex;
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isDone ? AppTheme.primaryColor : Colors.grey.shade300,
                      child: Icon(
                        isDone ? Icons.check : Icons.circle,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[stepIndex]['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                        color: isDone ? AppTheme.primaryColor : Colors.grey,
                      ),
                    ),
                  ],
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
