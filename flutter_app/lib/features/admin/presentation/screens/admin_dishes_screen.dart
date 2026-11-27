import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/presentation/providers/catalog_provider.dart';

class AdminDishesScreen extends ConsumerStatefulWidget {
  const AdminDishesScreen({super.key});

  @override
  ConsumerState<AdminDishesScreen> createState() => _AdminDishesScreenState();
}

class _AdminDishesScreenState extends ConsumerState<AdminDishesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditDishDialog(Product product) {
    final priceController = TextEditingController(text: product.price.toStringAsFixed(2));
    bool isFeatured = product.isFeatured;
    String spiceLevel = product.spiceLevel;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'កែប្រែ: ${product.nameKm}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'តម្លៃជាដុល្លារ (\$ Price USD)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('មុខម្ហូបពិសេស:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Switch(
                    value: isFeatured,
                    activeThumbColor: AppTheme.primaryColor,
                    onChanged: (val) => setDialogState(() => isFeatured = val),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('កម្រិតហិរ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  DropdownButton<String>(
                    value: spiceLevel,
                    items: const [
                      DropdownMenuItem(value: 'mild', child: Text('🌿 ហិរតិច')),
                      DropdownMenuItem(value: 'hot', child: Text('🌶️ ហិរ')),
                      DropdownMenuItem(value: 'extra', child: Text('🌶️🌶️ ហិរខ្លាំង')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => spiceLevel = val);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('បោះបង់'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () async {
                final newPrice = double.tryParse(priceController.text.trim()) ?? product.price;

                try {
                  final dio = ref.read(dioProvider);
                  final response = await dio.put('/products/${product.id}', data: {
                    'price': newPrice,
                    'featured': isFeatured,
                    'spice_level': spiceLevel,
                  });

                  if (response.statusCode == 200) {
                    ref.invalidate(productsProvider);
                    ref.invalidate(featuredDishesProvider);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('បានកែប្រែមុខម្ហូប ${product.nameKm} ដោយជោគជ័យ!')),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('បរាជ័យក្នុងការកែប្រែ: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('រក្សាទុក'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('គ្រប់គ្រងមុខម្ហូប'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(productsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'ស្វែងរកមុខម្ហូបតាមឈ្មោះ...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Dishes List
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (products) {
                final list = _searchQuery.isEmpty
                    ? products
                    : products.where((p) =>
                        p.nameKm.toLowerCase().contains(_searchQuery) ||
                        p.nameEn.toLowerCase().contains(_searchQuery)).toList();

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final product = list[index];

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: product.primaryImage,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorWidget: (c, u, e) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.restaurant, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product.nameKm,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (product.isFeatured) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  product.nameEn,
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)} | ៛${(product.price * 4100).round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppTheme.secondaryDark),
                            tooltip: 'កែប្រែ',
                            onPressed: () => _showEditDishDialog(product),
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
}
