import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _deliveryFeeController = TextEditingController();
  final _khrRateController = TextEditingController();
  final _announcementController = TextEditingController();
  bool _isOpen = true;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _deliveryFeeController.dispose();
    _khrRateController.dispose();
    _announcementController.dispose();
    super.dispose();
  }

  void _initFields(Map<String, dynamic> settings) {
    if (_initialized) return;
    _isOpen = settings['is_open'] as bool? ?? true;
    _deliveryFeeController.text = (settings['standard_delivery_fee'] ?? 1.50).toString();
    _khrRateController.text = (settings['khr_rate'] ?? 4100).toString();
    _announcementController.text = settings['announcement_km'] ?? '';
    _initialized = true;
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.put('/settings', data: {
        'is_open': _isOpen,
        'standard_delivery_fee': double.tryParse(_deliveryFeeController.text) ?? 1.50,
        'khr_rate': int.tryParse(_khrRateController.text) ?? 4100,
        'announcement_km': _announcementController.text.trim(),
      });

      if (response.statusCode == 200) {
        ref.invalidate(storeSettingsProvider);
        ref.invalidate(dashboardStatsProvider);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 បានរក្សាទុកការកំណត់ហាងដោយជោគជ័យ!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('បរាជ័យក្នុងការរក្សាទុក: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(storeSettingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('ការកំណត់ហាង (Store Settings)'),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (settings) {
          _initFields(settings);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Open / Close Toggle Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: _isOpen ? Colors.green.shade50 : Colors.red.shade50,
                            child: Icon(
                              _isOpen ? Icons.storefront : Icons.store_mall_directory_outlined,
                              color: _isOpen ? Colors.green : Colors.red,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isOpen ? 'ហាងកំពុងបើកដំណើរការ (Store Open)' : 'ហាងបានបិទបណ្តោះអាសន្ន (Store Closed)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isOpen ? 'ទទួលការកុម្ម៉ង់ធម្មតា' : 'ផ្អាកទទួលការកុម្ម៉ង់ជាបណ្តោះអាសន្ន',
                                style: TextStyle(color: _isOpen ? Colors.green : Colors.red, fontSize: 11.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _isOpen,
                        activeThumbColor: Colors.green,
                        onChanged: (val) => setState(() => _isOpen = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Delivery Fee & Currency Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'តម្លៃសេវា និងអត្រារូបិយប័ណ្ណ (Fees & Currency)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _deliveryFeeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'ថ្លៃដឹកជញ្ជូនស្តង់ដារ (\$ Delivery Fee USD)',
                          prefixIcon: Icon(Icons.delivery_dining, color: AppTheme.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _khrRateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'អត្រាប្តូរប្រាក់រៀល (KHR Exchange Rate 1 USD = ? ៛)',
                          prefixIcon: Icon(Icons.currency_exchange, color: AppTheme.secondaryColor),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Announcement Banner Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'សារជូនដំណឹងប្រូម៉ូសិន (Announcement Banner)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'សារនេះនឹងបង្ហាញនៅលើកំពូលនៃអេក្រង់ទំព័រដើមរបស់អតិថិជន។',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _announcementController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'អត្ថបទជូនដំណឹង (Banner Text)',
                          prefixIcon: Icon(Icons.campaign, color: AppTheme.secondaryDark),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isSaving ? null : _saveSettings,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: const Text(
                      'រក្សាទុកការកំណត់ (Save Settings)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
