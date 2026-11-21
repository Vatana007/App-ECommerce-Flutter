import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/money.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/presentation/providers/catalog_provider.dart';

class ProductScanScreen extends ConsumerStatefulWidget {
  const ProductScanScreen({super.key});

  @override
  ConsumerState<ProductScanScreen> createState() => _ProductScanScreenState();
}

class _ProductScanScreenState extends ConsumerState<ProductScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  final TextEditingController _codeController = TextEditingController();
  bool _isTorchOn = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _processScanCode(String rawCode, List<Product> products) {
    final query = rawCode.trim().toLowerCase();
    if (query.isEmpty) return;

    // Check by ID exact/partial, or by name
    Product? matched;
    try {
      matched = products.firstWhere(
        (p) =>
            p.id.toLowerCase() == query ||
            query.contains(p.id.toLowerCase()) ||
            p.nameKm.toLowerCase().contains(query) ||
            p.nameEn.toLowerCase().contains(query),
      );
    } catch (_) {
      matched = null;
    }

    setState(() {
      if (matched != null) {
        _errorMessage = null;
      } else {
        _errorMessage = 'រកមិនឃើញមុខម្ហូបជាមួយលេខកូដ "$rawCode" ទេ!';
      }
    });

    if (matched != null) {
      _showProductResultModal(matched);
    }
  }

  void _showProductResultModal(Product product) {
    final money = Money(amount: product.price);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Success Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
                ),
                const SizedBox(width: 10),
                const Text(
                  'ស្កេនឃើញមុខម្ហូបជោគជ័យ!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Product Detail Card
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: product.primaryImage,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey.shade100),
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: AppTheme.primarySubtle,
                      child: const Icon(Icons.restaurant, color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.nameKm,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        product.nameEn,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            money.format(targetCurrency: Currency.usd),
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${money.format(targetCurrency: Currency.khr)})',
                            style: const TextStyle(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/product/${product.id}');
                    },
                    child: const Text('មើលមុខម្ហូប (View Detail)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ref.read(cartProvider.notifier).addToCart(product);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('បានបន្ថែម ${product.nameKm} ទៅកន្ត្រក!'),
                          backgroundColor: AppTheme.primaryColor,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('+ ដាក់ក្នុងកន្ត្រក'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ស្កេនស្វែងរកមុខម្ហូប (Scan Food Code)',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? AppTheme.secondaryColor : Colors.white70,
            ),
            tooltip: 'Flashlight',
            onPressed: () => setState(() => _isTorchOn = !_isTorchOn),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor)),
        error: (err, _) => Center(
          child: Text('Error loading products: $err', style: const TextStyle(color: Colors.white)),
        ),
        data: (products) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  'ដាក់ QR Code ឬលេខកូដម្ហូបក្នុងប្រអប់ដើម្បីស្វែងរក',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Scanner Viewfinder Box
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12, width: 1.5),
                    ),
                    child: Stack(
                      children: [
                        // Four Corner Brackets (Angkor Gold)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AppTheme.secondaryColor, width: 4),
                                left: BorderSide(color: AppTheme.secondaryColor, width: 4),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AppTheme.secondaryColor, width: 4),
                                right: BorderSide(color: AppTheme.secondaryColor, width: 4),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppTheme.secondaryColor, width: 4),
                                left: BorderSide(color: AppTheme.secondaryColor, width: 4),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppTheme.secondaryColor, width: 4),
                                right: BorderSide(color: AppTheme.secondaryColor, width: 4),
                              ),
                            ),
                          ),
                        ),

                        // Center Target Graphic
                        Center(
                          child: Icon(
                            Icons.qr_code_2_rounded,
                            size: 100,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),

                        // Animated Sweeping Laser Line
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Positioned(
                              top: 20 + (_animation.value * 210),
                              left: 20,
                              right: 20,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppTheme.secondaryColor,
                                      Colors.white,
                                      AppTheme.secondaryColor,
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.secondaryColor.withValues(alpha: 0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Error Message if not found
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade400, width: 1),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),

                // Manual Input Field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code, color: Colors.white70, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          style: const TextStyle(color: Colors.white, fontSize: 13.5),
                          decoration: const InputDecoration(
                            hintText: 'បញ្ចូលលេខកូដ ឬឈ្មោះម្ហូប...',
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 12.5),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (val) => _processScanCode(val, products),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: AppTheme.secondaryColor),
                        onPressed: () => _processScanCode(_codeController.text, products),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Scan Simulator / Sample Foods
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '⚡ តេស្តស្កេនរហ័ស (Quick Demo Codes):',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _demoChip(
                      label: '🐸 កង្កែបចំបើង',
                      code: 'cmt1krpbt00180aj7e18d2xp6',
                      onTap: () {
                        _codeController.text = 'cmt1krpbt00180aj7e18d2xp6';
                        _processScanCode('cmt1krpbt00180aj7e18d2xp6', products);
                      },
                    ),
                    _demoChip(
                      label: '🍗 ឡាបសាច់មាន់',
                      code: 'cmst1x5c200060akgz6pjzvxr',
                      onTap: () {
                        _codeController.text = 'cmst1x5c200060akgz6pjzvxr';
                        _processScanCode('cmst1x5c200060akgz6pjzvxr', products);
                      },
                    ),
                    _demoChip(
                      label: '🥤 ទឹកក្រូចដប',
                      code: 'clsb4k064000013jvbscd287s',
                      onTap: () {
                        _codeController.text = 'clsb4k064000013jvbscd287s';
                        _processScanCode('clsb4k064000013jvbscd287s', products);
                      },
                    ),
                    _demoChip(
                      label: '🍲 សម្លកកូរ',
                      code: 'កកូរ',
                      onTap: () {
                        _codeController.text = 'កកូរ';
                        _processScanCode('កកូរ', products);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _demoChip({required String label, required String code, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_scanner, color: AppTheme.secondaryColor, size: 14),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}
