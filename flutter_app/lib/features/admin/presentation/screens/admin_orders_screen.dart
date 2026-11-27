import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/money.dart';
import '../providers/admin_provider.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _selectedFilter = 'all';

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.put('/orders/$orderId/status', data: {
        'status': newStatus,
      });

      if (response.statusCode == 200) {
        ref.invalidate(adminOrdersProvider);
        ref.invalidate(dashboardStatsProvider);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('បានប្តូរស្ថានភាពវិក្កយបត្រ #$orderId ទៅជា "$newStatus" រួចរាល់!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('បរាជ័យក្នុងការប្តូរស្ថានភាព: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('គ្រប់គ្រងការកុម្ម៉ង់'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminOrdersProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('all', 'ទាំងអស់'),
                  const SizedBox(width: 8),
                  _filterChip('pending', 'រង់ចាំ'),
                  const SizedBox(width: 8),
                  _filterChip('preparing', 'កំពុងចម្អិន'),
                  const SizedBox(width: 8),
                  _filterChip('delivering', 'កំពុងដឹក'),
                  const SizedBox(width: 8),
                  _filterChip('delivered', 'បានទទួល'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Orders List
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (orders) {
                final filtered = _selectedFilter == 'all'
                    ? orders
                    : orders.where((o) => (o['status'] ?? '').toString().toLowerCase() == _selectedFilter).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('មិនមានការកុម្ម៉ង់ក្នុងប្រភេទនេះទេ', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final order = filtered[index] as Map<String, dynamic>;
                    final orderId = order['id'] ?? order['order_id'] ?? 'PY-ORD';
                    final status = (order['status'] ?? 'pending').toString().toLowerCase();
                    final total = (order['total_amount'] ?? order['total'] as num?)?.toDouble() ?? 0.0;
                    final items = order['items'] as List<dynamic>? ?? [];
                    final customerName = order['customer_name'] ?? 'អតិថិជន';
                    final phone = order['customer_phone'] ?? '';
                    final money = Money(amount: total);

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: ID and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'វិក្កយបត្រ #$orderId',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryColor),
                              ),
                              _statusBadge(status),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Customer details
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              if (phone.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.phone, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(phone, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              ],
                            ],
                          ),
                          const Divider(height: 18),

                          // Items List
                          ...items.map((i) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '• ${i['name'] ?? 'ម្ហូបខ្មែរ'} x ${i['quantity'] ?? 1}',
                                        style: const TextStyle(fontSize: 12.5),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '\$${((i['price'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )),
                          const Divider(height: 18),

                          // Total Amount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ចំនួនទឹកប្រាក់សរុប:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              Text(
                                money.formatDual(),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.primaryColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Quick Status Advancement Buttons
                          Row(
                            children: [
                              if (status == 'pending')
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.soup_kitchen, size: 16),
                                    label: const Text('ចម្អិន', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    onPressed: () => _updateStatus(orderId, 'preparing'),
                                  ),
                                ),
                              if (status == 'preparing')
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.delivery_dining, size: 16),
                                    label: const Text('ដឹកជញ្ជូន', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    onPressed: () => _updateStatus(orderId, 'delivering'),
                                  ),
                                ),
                              if (status == 'delivering')
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.check_circle, size: 16),
                                    label: const Text('រួចរាល់', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    onPressed: () => _updateStatus(orderId, 'delivered'),
                                  ),
                                ),
                              if (status != 'delivered' && status != 'cancelled') ...[
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _updateStatus(orderId, 'cancelled'),
                                  child: const Text('បោះបង់', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textDark,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _selectedFilter = key),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'pending':
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade800;
        label = 'កំពុងរង់ចាំ';
        break;
      case 'preparing':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade800;
        label = 'កំពុងចម្អិន';
        break;
      case 'delivering':
        bg = Colors.purple.shade50;
        fg = Colors.purple.shade800;
        label = 'កំពុងដឹក';
        break;
      case 'delivered':
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        label = 'បានទទួល';
        break;
      case 'cancelled':
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        label = 'បានបោះបង់';
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade800;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
