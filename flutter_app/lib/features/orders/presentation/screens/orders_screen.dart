import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/shared/models/money.dart';
import 'package:flutter_app/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_app/features/orders/presentation/providers/orders_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      // 1. Check local orders state first
      final orders = ref.read(ordersProvider);
      final foundLocal = orders.where((o) => o.id.toLowerCase() == query.toLowerCase()).firstOrNull;

      if (foundLocal != null) {
        if (mounted) {
          context.push('/order-detail/${foundLocal.id}');
        }
        return;
      }

      // 2. Fetch from Node.js API backend
      final dio = ref.read(dioProvider);
      final response = await dio.get('/orders/$query');

      if (response.statusCode == 200 && response.data['data'] != null) {
        final orderData = response.data['data'];
        final fetchedOrder = OrderEntity.fromJson(orderData);
        ref.read(ordersProvider.notifier).addOrder(fetchedOrder);

        if (mounted) {
          context.push('/order-detail/${fetchedOrder.id}');
        }
      } else {
        _showNotFoundToast(query);
      }
    } catch (_) {
      _showNotFoundToast(query);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _showNotFoundToast(String query) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('រកមិនឃើញវិក្កយបត្រ "$query" ឡើយ។ សូមពិនិត្យលេខសម្គាល់ម្តងទៀត។'),
        backgroundColor: Colors.orange.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'តាមដានការកុម្ម៉ង់ (Track Order)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Order ID Box (Matching E-Restaurant TrackOrder.jsx)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.search, color: AppTheme.primaryColor, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'ស្វែងរកការកុម្ម៉ង់របស់អ្នក (Track by ID)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'បញ្ចូលលេខសម្គាល់វិក្កយបត្រ (Order ID) ដើម្បីពិនិត្យមើលស្ថានភាពនៃការដឹកជញ្ជូន។',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _handleSearch(),
                          decoration: InputDecoration(
                            hintText: 'ឧ. PY-ORD-6286',
                            prefixIcon: const Icon(Icons.receipt, color: AppTheme.secondaryColor, size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.borderColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSearching ? null : _handleSearch,
                        child: _isSearching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('តាមដាន', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Order History Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ការកុម្ម៉ង់ថ្មីៗ (${orders.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                ),
                if (orders.isNotEmpty)
                  TextButton(
                    onPressed: () => context.push('/catalog'),
                    child: const Text('កុម្ម៉ង់បន្ថែម +'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (orders.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text('មិនទាន់មានការកុម្ម៉ង់ទេ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text(
                        'រាល់ការកុម្ម៉ង់របស់អ្នកនឹងបង្ហាញនៅទីនេះ។',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => context.go('/catalog'),
                        icon: const Icon(Icons.restaurant_menu),
                        label: const Text('ចាប់ផ្ដើមកុម្ម៉ង់អាហារ'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final money = Money(amount: order.totalAmount);

                  return InkWell(
                    onTap: () => context.push('/order-detail/${order.id}'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'វិក្កយបត្រ #${order.id}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryColor),
                              ),
                              _buildStatusBadge(order.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'កាលបរិច្ឆេទ: ${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}-${order.createdAt.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.shopping_bag_outlined, size: 18, color: AppTheme.secondaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${order.items.length} មុខម្ហូប (${order.items.fold(0, (sum, i) => sum + i.quantity)} ចាន)',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                money.formatDual(),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.primaryColor),
                              ),
                              Row(
                                children: const [
                                  Text('មើលព័ត៌មានលម្អិត', style: TextStyle(color: AppTheme.secondaryDark, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Icon(Icons.chevron_right, size: 16, color: AppTheme.secondaryDark),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade800;
        label = 'កំពុងរង់ចាំ';
        icon = Icons.schedule;
        break;
      case OrderStatus.preparing:
      case OrderStatus.processing:
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade800;
        label = 'ផ្ទះបាយកំពុងចម្អិន';
        icon = Icons.soup_kitchen;
        break;
      case OrderStatus.delivering:
      case OrderStatus.shipped:
        bg = Colors.purple.shade50;
        fg = Colors.purple.shade800;
        label = 'កំពុងដឹកជញ្ជូន';
        icon = Icons.delivery_dining;
        break;
      case OrderStatus.delivered:
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        label = 'បានទទួលជោគជ័យ';
        icon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        label = 'បានបោះបង់';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
