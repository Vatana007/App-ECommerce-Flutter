import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/shared/models/money.dart';
import 'package:flutter_app/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_app/features/orders/presentation/providers/orders_provider.dart';

class KhqrPaymentScreen extends ConsumerStatefulWidget {
  final OrderEntity order;

  const KhqrPaymentScreen({super.key, required this.order});

  @override
  ConsumerState<KhqrPaymentScreen> createState() => _KhqrPaymentScreenState();
}

class _KhqrPaymentScreenState extends ConsumerState<KhqrPaymentScreen> {
  int _secondsRemaining = 180;
  Timer? _countdownTimer;
  Timer? _pollTimer;
  bool _isAutoPolling = false; // Disabled by default per user request
  bool _isVerifying = false;
  bool _isPaid = false;
  String? _khqrPayload;
  String? _khqrMd5;

  @override
  void initState() {
    super.initState();
    _khqrPayload = widget.order.khqrString;
    _khqrMd5 = widget.order.khqrMd5;

    _startCountdown();
    _ensureKhqrString();
    // Do NOT auto poll on init
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _stopAutoPolling();
      }
    });
  }

  void _toggleAutoPolling() {
    if (_isPaid) return;
    setState(() => _isAutoPolling = !_isAutoPolling);

    if (_isAutoPolling) {
      _startAutoPolling();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('បានបើកការពិនិត្យស្វ័យប្រវត្តិ'),
          backgroundColor: Color(0xFF0284C7),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _stopAutoPolling();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('បានបិទការពិនិត្យស្វ័យប្រវត្តិ'),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _startAutoPolling() {
    _pollTimer?.cancel();
    _checkPaymentStatus(silent: true);
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!_isPaid && mounted && _secondsRemaining > 0 && _isAutoPolling) {
        _checkPaymentStatus(silent: true);
      } else {
        timer.cancel();
        if (mounted) setState(() => _isAutoPolling = false);
      }
    });
  }

  void _stopAutoPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _ensureKhqrString() async {
    if (_khqrPayload != null && _khqrPayload!.isNotEmpty) return;

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/payments/khqr/generate', data: {
        'order_id': widget.order.id,
        'currency': 'USD',
      });
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _khqrPayload = response.data['data']['qr'];
          _khqrMd5 = response.data['data']['md5'];
        });
      }
    } catch (_) {
      // Offline fallback string
      if (mounted) {
        setState(() {
          _khqrPayload =
              '00020101021229150011vatana@bkrt5204599953038405405${widget.order.totalAmount.toStringAsFixed(2)}5802KH5919Phum Yeung Online6010Phnom Penh62250107${widget.order.id}0310Phum Yeung6304';
        });
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _stopAutoPolling();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _checkPaymentStatus({bool silent = false}) async {
    if (_isPaid) return;
    if (!silent && mounted) setState(() => _isVerifying = true);

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/payments/khqr/verify', data: {
        'order_id': widget.order.id,
        'md5': _khqrMd5,
      });

      if (response.statusCode == 200 && response.data['data']['is_paid'] == true) {
        _onPaymentSuccess();
        return;
      } else if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('មិនទាន់ឃើញការទូទាត់នៅឡើយទេ។ សូមពិនិត្យមើល App ធនាគាររបស់អ្នក។'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('មិនអាចទាក់ទងម៉ាស៊ីនបម្រើបានទេ សូមព្យាយាមម្តងទៀត'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (!silent && mounted) setState(() => _isVerifying = false);
    }
  }

  void _onPaymentSuccess() {
    if (_isPaid || !mounted) return;
    setState(() {
      _isPaid = true;
      _isAutoPolling = false;
    });
    _countdownTimer?.cancel();
    _stopAutoPolling();

    ref.read(ordersProvider.notifier).markOrderAsPaid(widget.order.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 ការទូទាត់តាម Bakong KHQR ទទួលបានជោគជ័យ!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        context.go('/order-success/${widget.order.id}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final money = Money(amount: widget.order.totalAmount);
    final qrData = _khqrPayload ?? 'KHQR://PHUM_YEUNG/${widget.order.id}';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('ទូទាត់តាម Bakong KHQR'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Authentic KHQR Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Red Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE1192A),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          'KHQR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'National Bank of Cambodia (NBC)',
                          style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Merchant Details
                  const Text(
                    'ភោជនីយដ្ឋាន ភូមិយើង',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'លេខវិក្កយបត្រ: #${widget.order.id}',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 14),

                  // Dual Currency Amount
                  Text(
                    money.format(targetCurrency: Currency.usd),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE1192A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    money.format(targetCurrency: Currency.khr),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // QR Code Image Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 230.0,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF0F172A),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Countdown & Status
                  if (_isPaid)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'បានទូទាត់រួចរាល់',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined, size: 18, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(
                          'សុពលភាពនៅសល់៖ $_formattedTime នាទី',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'គាំទ្រការស្កេនជាមួយគ្រប់កម្មវិធីធនាគារ៖ ABA Mobile, ACLEDA mobile, Wing Bank, TrueMoney, Chip Mong Bank និងធនាគារ Bakong ផ្សេងៗ។',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Active Auto-Polling Banner
            if (_isAutoPolling && !_isPaid) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF93C5FD), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'កំពុងពិនិត្យស្វ័យប្រវត្តិរៀងរាល់ ៨ វិនាទីម្តង...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1D4ED8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Two Buttons: Manual Check & Auto Check
            Row(
              children: [
                // 1. Manual Check Button
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: (_isVerifying || _isPaid) ? null : () => _checkPaymentStatus(silent: false),
                      icon: _isVerifying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.touch_app_outlined, size: 20),
                      label: Text(
                        _isVerifying ? 'កំពុងឆែក...' : 'ពិនិត្យដោយដៃ\n',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 2. Auto Check Button (Toggle ON/OFF)
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAutoPolling ? const Color(0xFF0284C7) : const Color(0xFF475569),
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isPaid ? null : _toggleAutoPolling,
                      icon: Icon(
                        _isAutoPolling ? Icons.pause_circle_filled : Icons.autorenew,
                        size: 20,
                      ),
                      label: Text(
                        _isAutoPolling ? 'ស្វ័យប្រវត្តិ (បើក)\n(Auto: ON)' : 'ពិនិត្យស្វ័យប្រវត្តិ\n(Auto: OFF)',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Cancel / Back Button
            TextButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('ត្រឡប់ក្រោយ'),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
