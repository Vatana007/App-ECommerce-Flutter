import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../admin/presentation/providers/admin_provider.dart';
import '../../../admin/presentation/screens/admin_login_dialog.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final wishlist = ref.watch(wishlistProvider);
    final cart = ref.watch(cartProvider);
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('គណនី និងព័ត៌មានហាង (Account & Store)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Restaurant Header Card with Phum Yeung Authentic Logo
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.secondaryColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/phum_yeung_logo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppTheme.primaryColor,
                          child: const Icon(Icons.restaurant, color: Colors.white, size: 32),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ភោជនីយដ្ឋាន ភូមិយើង',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textDark),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Phum Yeung Restaurant Online',
                          style: TextStyle(color: AppTheme.secondaryDark, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '☎️ 012 345 678 / 098 765 432',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Stats Row
            Row(
              children: [
                _statCard(
                  title: 'ការកុម្ម៉ង់',
                  count: '${orders.length}',
                  icon: Icons.receipt_long,
                  iconColor: AppTheme.primaryColor,
                  onTap: () => context.push('/orders'),
                ),
                const SizedBox(width: 10),
                _statCard(
                  title: 'ទំនិញពេញចិត្ត',
                  count: '${wishlist.length}',
                  icon: Icons.favorite,
                  iconColor: Colors.red,
                  onTap: () => context.push('/wishlist'),
                ),
                const SizedBox(width: 10),
                _statCard(
                  title: 'ក្នុងកន្ត្រក',
                  count: '${cart.totalItemCount}',
                  icon: Icons.shopping_bag,
                  iconColor: AppTheme.secondaryColor,
                  onTap: () => context.push('/cart'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Track Order Highlight Card (Primary Access to Track Order)
            InkWell(
              onTap: () => context.push('/orders'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primarySubtle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delivery_dining, color: AppTheme.primaryColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'តាមដានការកុម្ម៉ង់ (Track Orders)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppTheme.textDark),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'ពិនិត្យមើលស្ថានភាពចម្អិន ការដឹកជញ្ជូន និងប្រវត្តិទិញ',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // All-in-One Admin Portal Access Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryDark, AppTheme.primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.admin_panel_settings, color: AppTheme.secondaryLight, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'ផ្ទាំងគ្រប់គ្រងហាង (Admin Portal)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          adminState.isAuthenticated ? 'LOGGED IN' : 'MANAGER',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'គ្រប់គ្រងការកុម្ម៉ង់ផ្ទាល់ (Live Orders), កែប្រែតម្លៃមុខម្ហូប (Dishes) និងការកំណត់ហាង (Store Settings) ក្នុង App តែមួយ។',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      if (adminState.isAuthenticated) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.dashboard, size: 18),
                            label: const Text('បើកផ្ទាំង Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            onPressed: () => context.push('/admin/dashboard'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            ref.read(adminProvider.notifier).logout();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('បានចាកចេញពី Admin')),
                            );
                          },
                          child: const Text('ចាកចេញ', style: TextStyle(fontSize: 12)),
                        ),
                      ] else ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.login, size: 18),
                            label: const Text(
                              'ចូលគ្រប់គ្រង (Admin Login)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: () => AdminLoginDialog.show(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Store Info & Actions Menu
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  _menuItem(
                    icon: Icons.delivery_dining,
                    iconColor: AppTheme.primaryColor,
                    title: 'តាមដានការកុម្ម៉ង់ (Track Order)',
                    subtitle: 'ពិនិត្យមើលស្ថានភាពនៃការដឹកជញ្ជូនអាហារ',
                    onTap: () => context.push('/orders'),
                  ),
                  const Divider(height: 1, indent: 56),
                  _menuItem(
                    icon: Icons.restaurant_menu,
                    iconColor: AppTheme.secondaryColor,
                    title: 'បញ្ជីមុខម្ហូបខ្មែរទាំងអស់ (Full Menu)',
                    subtitle: '១៦០ មុខម្ហូបបុរាណខ្មែរឈ្ងុយឆ្ងាញ់',
                    onTap: () => context.push('/catalog'),
                  ),
                  const Divider(height: 1, indent: 56),
                  _menuItem(
                    icon: Icons.store_mall_directory,
                    iconColor: AppTheme.accentColor,
                    title: 'អំពីភោជនីយដ្ឋាន ភូមិយើង (About Us)',
                    subtitle: 'ផ្ទះបាយខ្មែរអនឡាញ បម្រើរសជាតិខ្មែរពិតៗ',
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _menuItem(
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.redAccent,
                    title: 'ទីតាំងផ្ទះបាយ (Location)',
                    subtitle: 'ផ្លូវ 271 កែងផ្លូវ 371 សង្កាត់បឹងទំពុន រាជធានីភ្នំពេញ',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📍 ទីតាំង៖ ផ្លូវ 271 កែងផ្លូវ 371 សង្កាត់បឹងទំពុន ខណ្ឌមានជ័យ រាជធានីភ្នំពេញ'),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _menuItem(
                    icon: Icons.headset_mic_outlined,
                    iconColor: Colors.teal,
                    title: 'ផ្នែកបម្រើអតិថិជន (Customer Support)',
                    subtitle: 'Telegram: @phum_yeung_support | ទូរស័ព្ទ: 012 345 678',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('💬 ផ្នែកសេវាកម្មអតិថិជនបើករៀងរាល់ថ្ងៃពីម៉ោង 7:00 ព្រឹក - 9:00 យប់'),
                          backgroundColor: Colors.teal,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Footer branding
            const Text(
              'ភោជនីយដ្ឋាន ភូមិយើង (Phum Yeung Restaurant)',
              style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 2),
            const Text(
              'កំណែប្រែ App Version 1.0.0 (All-in-One Customer & Admin App)',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.restaurant, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('អំពីភោជនីយដ្ឋាន ភូមិយើង', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'ភោជនីយដ្ឋាន ភូមិយើង ជាផ្ទះបាយខ្មែរអនឡាញដែលបង្កើតឡើងដើម្បីផ្តល់នូវភាពងាយស្រួលដល់លោកអ្នកក្នុងការទទួលទានម្ហូបខ្មែរបុរាណពិតប្រាកដ ដោយមិនចាំបាច់ចេញពីផ្ទះ ឬការិយាល័យ។\n\nរាល់មុខម្ហូបទាំងអស់ត្រូវបានចម្អិនភ្លាមៗក្រោយពេលទទួលបានការកុម្ម៉ង់ វេចខ្ចប់ដោយប្រអប់រក្សាកម្ដៅដែលមិនប៉ះពាល់ដល់បរិស្ថាន និងដឹកជញ្ជូនរហ័សទាន់ចិត្ត។',
              style: TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textDark),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context),
            child: const Text('បិទ'),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String count,
    required IconData icon,
    Color iconColor = Colors.blue,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(height: 6),
              Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
              const SizedBox(height: 2),
              Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    Color? iconColor,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: (iconColor ?? AppTheme.primaryColor).withValues(alpha: 0.1),
        child: Icon(icon, color: iconColor ?? AppTheme.primaryColor, size: 20),
      ),
      title: Text(title, style: TextStyle(color: textColor ?? AppTheme.textDark, fontSize: 13.5, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted)) : null,
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }
}
