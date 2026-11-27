import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/shared/models/money.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_app/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_app/features/checkout/domain/models/checkout_models.dart';
import 'package:flutter_app/features/checkout/presentation/providers/checkout_provider.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutProvider);
    final checkoutNotifier = ref.read(checkoutProvider.notifier);

    final subtotal = cartState.subtotal;
    final discount = cartState.discountAmount;
    final shippingFee = checkoutState.shippingOption.fee;
    final finalTotal = (subtotal - discount + shippingFee) > 0 ? (subtotal - discount + shippingFee) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ការទូទាត់ប្រាក់'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('១. អាសយដ្ឋានដឹកជញ្ជូន'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            checkoutState.address.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${checkoutState.address.phone})',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => _showEditAddressDialog(context, ref, checkoutState.address),
                        child: const Text('កែប្រែ'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${checkoutState.address.street}, ${checkoutState.address.city}',
                    style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle('២. ជម្រើសសេវាដឹក'),
            const SizedBox(height: 8),
            _shippingOptionTile(
              context: context,
              ref: ref,
              option: const ShippingOption(
                id: 'standard',
                title: 'សេវាធម្មតា',
                description: 'ដឹកជញ្ជូនរហ័សទូទាំងប្រទេស (1 - 2 ថ្ងៃ)',
                fee: 0.00,
                estimatedTime: '1 - 2 ថ្ងៃ',
              ),
              isSelected: checkoutState.shippingOption.id == 'standard',
            ),
            const SizedBox(height: 8),
            _shippingOptionTile(
              context: context,
              ref: ref,
              option: const ShippingOption(
                id: 'express',
                title: 'សេវាបន្ទាន់',
                description: 'ដឹកជូនក្នុងរាជធានីភ្នំពេញ ក្រោម 2 ម៉ោង',
                fee: 3.00,
                estimatedTime: '2 ម៉ោង',
              ),
              isSelected: checkoutState.shippingOption.id == 'express',
            ),

            const SizedBox(height: 20),

            _sectionTitle('៣. វិធីសាស្រ្តទូទាត់ប្រាក់'),
            const SizedBox(height: 8),

            _paymentMethodTile(
              ref: ref,
              method: PaymentMethod.khqr,
              icon: Icons.qr_code_scanner,
              iconColor: const Color(0xFFE1192A),
              title: 'Bakong KHQR (ABA, ACLEDA, Wing, etc.)',
              subtitle: 'ស្កេនទូទាត់ភ្លាមៗជាមួយគ្រប់ App ធនាគារក្នុងស្រុក',
              isRecommended: true,
              isSelected: checkoutState.paymentMethod == PaymentMethod.khqr,
            ),
            const SizedBox(height: 8),

            _paymentMethodTile(
              ref: ref,
              method: PaymentMethod.cod,
              icon: Icons.local_shipping_outlined,
              iconColor: Colors.teal,
              title: 'ទូទាត់ប្រាក់ពេលទំនិញមកដល់',
              subtitle: 'ពិនិត្យទំនិញរួច ទើបប្រគល់ប្រាក់ជូនអ្នកដឹកជញ្ជូន',
              isSelected: checkoutState.paymentMethod == PaymentMethod.cod,
            ),
            const SizedBox(height: 8),

            _paymentMethodTile(
              ref: ref,
              method: PaymentMethod.card,
              icon: Icons.credit_card,
              iconColor: Colors.blueAccent,
              title: 'កាតធនាគារ',
              subtitle: 'ទូទាត់តាមកាតឥណទាន ឬឥណពន្ធ',
              isSelected: checkoutState.paymentMethod == PaymentMethod.card,
            ),

            const SizedBox(height: 20),

            _sectionTitle('៤. សង្ខេបការចំណាយ'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _summaryRow('តម្លៃទំនិញសរុប:', Money(amount: subtotal).format(targetCurrency: Currency.usd)),
                  if (discount > 0) ...[
                    const SizedBox(height: 8),
                    _summaryRow(
                      'បញ្ចុះតម្លៃ (${cartState.promoCode}):',
                      '-${Money(amount: discount).format(targetCurrency: Currency.usd)}',
                      color: Colors.green,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _summaryRow(
                    'ថ្លៃដឹកជញ្ជូន:',
                    Money(amount: shippingFee).format(targetCurrency: Currency.usd),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ទឹកប្រាក់សរុបត្រូវបង់:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Money(amount: finalTotal).format(targetCurrency: Currency.usd),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                          Text(
                            Money(amount: finalTotal).format(targetCurrency: Currency.khr),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: checkoutState.isSubmitting
                    ? null
                    : () async {
                        final orderItems = cartState.itemList
                            .map((item) => OrderItemEntity(
                                  productId: item.product.id,
                                  name: item.product.name,
                                  price: item.product.price,
                                  image: item.product.primaryImage,
                                  quantity: item.quantity,
                                  subtotal: item.subtotal,
                                ))
                            .toList();

                        final order = await checkoutNotifier.placeOrder(
                          items: orderItems,
                          subtotal: subtotal,
                          discount: discount,
                          promoCode: cartState.promoCode,
                        );

                        if (order != null && context.mounted) {
                          if (order.paymentMethod == PaymentMethod.khqr) {
                            context.push('/khqr-payment', extra: order);
                          } else {
                            context.go('/order-success/${order.id}');
                          }
                        }
                      },
                child: checkoutState.isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            checkoutState.paymentMethod == PaymentMethod.khqr
                                ? 'បន្តទៅកាន់ការទូទាត់ KHQR (\$${finalTotal.toStringAsFixed})'
                                : 'បញ្ជាក់ការកុម្ម៉ង់ (\$${finalTotal.toStringAsFixed})',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, color: color ?? Colors.black87, fontSize: 13),
        ),
      ],
    );
  }

  Widget _shippingOptionTile({
    required BuildContext context,
    required WidgetRef ref,
    required ShippingOption option,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => ref.read(checkoutProvider.notifier).selectShippingOption(option),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(option.description, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            Text(
              '\$${option.fee.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodTile({
    required WidgetRef ref,
    required PaymentMethod method,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isRecommended = false,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => ref.read(checkoutProvider.notifier).selectPaymentMethod(method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 12),
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ពេញនិយម',
                            style: TextStyle(color: Color(0xFFE1192A), fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAddressDialog(BuildContext context, WidgetRef ref, ShippingAddress current) {
    final nameCtrl = TextEditingController(text: current.name);
    final phoneCtrl = TextEditingController(text: current.phone);
    final cityCtrl = TextEditingController(text: current.city);
    final streetCtrl = TextEditingController(text: current.street);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('កែប្រែអាសយដ្ឋានដឹកជញ្ជូន'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'ឈ្មោះអ្នកទទួល'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'លេខទូរស័ព្ទ'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: 'រាជធានី / ខេត្ត'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: streetCtrl,
                decoration: const InputDecoration(labelText: 'ផ្ទះលេខ / ផ្លូវ'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('បោះបង់'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(checkoutProvider.notifier).updateAddress(
                    ShippingAddress(
                      name: nameCtrl.text,
                      phone: phoneCtrl.text,
                      city: cityCtrl.text,
                      street: streetCtrl.text,
                    ),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('រក្សាទុក'),
          ),
        ],
      ),
    );
  }
}
