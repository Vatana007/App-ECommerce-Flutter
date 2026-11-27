import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/shared/models/money.dart';
import 'package:flutter_app/features/orders/presentation/providers/orders_provider.dart';

class OrderSuccessScreen extends ConsumerWidget {
  final String orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 70,
                  color: Color(0xFF16A34A),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'ការបញ្ជាទិញបានជោគជ័យ!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'សូមអរគុណសម្រាប់ការគាំទ្រ។ យើងខ្ញុំកំពុងរៀបចំទំនិញដើម្បីដឹកជញ្ជូនជូនអ្នក។',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.5),
              ),

              const SizedBox(height: 28),

              if (order != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _rowInfo('លេខបញ្ជាទិញ:', '#${order.id}'),
                      const Divider(height: 20),
                      _rowInfo('វិធីសាស្រ្តទូទាត់:', order.paymentMethodDisplay),
                      const Divider(height: 20),
                      _rowInfo(
                        'ចំនួនទឹកប្រាក់សរុប:',
                        Money(amount: order.totalAmount).format(targetCurrency: Currency.usd),
                        isHighlight: true,
                      ),
                      const Divider(height: 20),
                      _rowInfo('ស្ថានភាពទូទាត់:', order.paymentStatus.name.toUpperCase()),
                    ],
                  ),
                ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => context.push('/order-detail/$orderId'),
                  child: const Text('តាមដានការកុម្ម៉ង់', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => context.go('/'),
                  child: const Text('បន្តការទិញទំនិញ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? AppTheme.primaryColor : Colors.black87,
            fontSize: isHighlight ? 15 : 13,
          ),
        ),
      ],
    );
  }
}
