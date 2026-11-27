import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/money.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final adminUser = ref.watch(adminProvider).user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset('assets/images/phum_yeung_logo.jpg', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'ផ្ទាំងគ្រប់គ្រង',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'ផ្ទុកទិន្នន័យឡើងវិញ',
            onPressed: () => ref.invalidate(dashboardStatsProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'ចាកចេញពី Admin',
            onPressed: () {
              ref.read(adminProvider.notifier).logout();
              context.go('/');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('បានចាកចេញពីផ្ទាំង Admin')),
              );
            },
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (stats) {
          final isOpen = stats['is_open'] as bool? ?? true;
          final totalRev = (stats['total_revenue'] as num?)?.toDouble() ?? 0.0;
          final totalOrders = stats['total_orders'] ?? 0;
          final pendingOrders = stats['pending_orders'] ?? 0;
          final totalDishes = stats['total_dishes'] ?? 160;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Admin Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryDark, AppTheme.primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.secondaryColor,
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adminUser?.name ?? 'Admin Portal',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              adminUser?.email ?? 'admin@phumyeung.com',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Store Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOpen ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOpen ? 'ហាងកំពុងបើក' : 'ហាងបានបិទ',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Stats Grid
                Row(
                  children: [
                    _metricCard(
                      title: 'ចំណូលសរុប',
                      value: Money(amount: totalRev).format(targetCurrency: Currency.usd),
                      subvalue: Money(amount: totalRev).format(targetCurrency: Currency.khr),
                      icon: Icons.payments,
                      color: AppTheme.secondaryColor,
                    ),
                    const SizedBox(width: 12),
                    _metricCard(
                      title: 'ការកុម្ម៉ង់',
                      value: '$totalOrders Orders',
                      subvalue: '$pendingOrders កំពុងរង់ចាំ',
                      icon: Icons.receipt_long,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _metricCard(
                      title: 'មុខម្ហូប',
                      value: '$totalDishes មុខ',
                      subvalue: '១៤ ប្រភេទមុខម្ហូប',
                      icon: Icons.restaurant_menu,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 12),
                    _metricCard(
                      title: 'ស្ថានភាពហាង',
                      value: isOpen ? 'បើកទទួលការកុម្ម៉ង់' : 'បិទបណ្តោះអាសន្ន',
                      subvalue: 'ដឹកជូនទូទាំងភ្នំពេញ',
                      icon: Icons.storefront,
                      color: isOpen ? Colors.teal : Colors.grey,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'មុខងារគ្រប់គ្រងសំខាន់ៗ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 12),

                // Management Navigation Tiles
                _navTile(
                  title: 'គ្រប់គ្រងការកុម្ម៉ង់',
                  subtitle: 'ពិនិត្យ និងប្តូរដំណាក់កាលដឹកជញ្ជូន Order (Pending ➡️ Preparing ➡️ Delivering)',
                  icon: Icons.delivery_dining,
                  iconColor: AppTheme.primaryColor,
                  badge: pendingOrders > 0 ? '$pendingOrders ថ្មី' : null,
                  onTap: () => context.push('/admin/orders'),
                ),
                const SizedBox(height: 10),

                _navTile(
                  title: 'គ្រប់គ្រងមុខម្ហូប',
                  subtitle: 'កែប្រែតម្លៃម្ហូប ប្តូរកម្រិតហិរ និងដាក់ក្នុងបញ្ជីមុខម្ហូបពិសេស',
                  icon: Icons.restaurant,
                  iconColor: AppTheme.secondaryColor,
                  badge: '$totalDishes មុខ',
                  onTap: () => context.push('/admin/dishes'),
                ),
                const SizedBox(height: 10),

                _navTile(
                  title: 'ការកំណត់ហាង',
                  subtitle: 'បិទ/បើកហាង កំណត់ថ្លៃដឹក (\$1.50) អត្រាប្តូរប្រាក់ (4,100 ៛) និងសារជូនដំណឹង',
                  icon: Icons.tune,
                  iconColor: AppTheme.accentColor,
                  onTap: () => context.push('/admin/settings'),
                ),
                const SizedBox(height: 10),

                _navTile(
                  title: 'ត្រឡប់ទៅទំព័រអតិថិជន',
                  subtitle: 'មើលទំព័រដើម និងទិញអាហារដូចអតិថិជនទូទៅ',
                  icon: Icons.shopping_bag_outlined,
                  iconColor: Colors.deepPurple,
                  onTap: () => context.go('/'),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subvalue,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
            ),
            const SizedBox(height: 2),
            Text(
              subvalue,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: iconColor.withValues(alpha: 0.1),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: iconColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
