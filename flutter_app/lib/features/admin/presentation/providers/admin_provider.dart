import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json, String token) {
    return AdminUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Phum Yeung Admin',
      email: json['email']?.toString() ?? 'admin@phumyeung.com',
      role: json['role']?.toString() ?? 'admin',
      token: token,
    );
  }
}

class AdminState {
  final bool isAuthenticated;
  final AdminUser? user;
  final bool isLoading;
  final String? errorMessage;

  const AdminState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AdminState copyWith({
    bool? isAuthenticated,
    AdminUser? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AdminNotifier extends Notifier<AdminState> {
  @override
  AdminState build() {
    return const AdminState();
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/login', data: {
        'email': email.trim(),
        'password': password.trim(),
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final token = response.data['data']['token']?.toString() ?? '';
        final userData = response.data['data']['user'] as Map<String, dynamic>;
        final adminUser = AdminUser.fromJson(userData, token);

        state = state.copyWith(
          isAuthenticated: true,
          user: adminUser,
          isLoading: false,
        );
        return true;
      }
    } catch (_) {
      // Local fallback for quick offline demo
      if ((email == 'admin@phumyeung.com' || email == 'admin') &&
          (password == 'admin123' || password == '123456')) {
        state = state.copyWith(
          isAuthenticated: true,
          user: const AdminUser(
            id: 'admin_1',
            name: 'Phum Yeung Admin',
            email: 'admin@phumyeung.com',
            role: 'admin',
            token: 'mock_token',
          ),
          isLoading: false,
        );
        return true;
      }
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: 'អុីមែល ឬពាក្យសម្ងាត់មិនត្រឹមត្រូវទេ',
    );
    return false;
  }

  void logout() {
    state = const AdminState();
  }
}

final adminProvider = NotifierProvider<AdminNotifier, AdminState>(AdminNotifier.new);

// Dashboard Stats Provider
final dashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('/admin/dashboard');
    if (response.statusCode == 200 && response.data['data'] != null) {
      return Map<String, dynamic>.from(response.data['data']);
    }
  } catch (_) {}

  // Fallback defaults
  return {
    'total_revenue': 128.50,
    'total_orders': 14,
    'pending_orders': 2,
    'total_dishes': 160,
    'is_open': true,
    'active_promos': 3,
  };
});

// Admin Order Management
final adminOrdersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('/orders');
    if (response.statusCode == 200 && response.data['data'] != null) {
      return List<dynamic>.from(response.data['data']);
    }
  } catch (_) {}
  return [];
});

// Store Settings Provider
final storeSettingsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('/settings');
    if (response.statusCode == 200 && response.data['data'] != null) {
      return Map<String, dynamic>.from(response.data['data']);
    }
  } catch (_) {}
  return {
    'is_open': true,
    'standard_delivery_fee': 1.50,
    'khr_rate': 4100,
    'announcement_km': '🔥 ប្រូម៉ូសិនពិសេស៖ បញ្ចុះតម្លៃ ១០% សម្រាប់ការកុម្ម៉ង់ដំបូងដោយប្រើកូដ PHUM10!',
  };
});
