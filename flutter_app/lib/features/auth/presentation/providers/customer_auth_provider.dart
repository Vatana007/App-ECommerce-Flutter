import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/customer_user.dart';

class CustomerAuthState {
  final bool isAuthenticated;
  final CustomerUser? user;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? devCode;
  final String? unverifiedEmail;

  const CustomerAuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.devCode,
    this.unverifiedEmail,
  });

  CustomerAuthState copyWith({
    bool? isAuthenticated,
    CustomerUser? user,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    String? devCode,
    String? unverifiedEmail,
    bool clearUser = false,
    bool clearDevCode = false,
    bool clearMessages = false,
  }) {
    return CustomerAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      devCode: clearDevCode ? null : (devCode ?? this.devCode),
      unverifiedEmail: unverifiedEmail ?? this.unverifiedEmail,
    );
  }
}

class CustomerAuthNotifier extends Notifier<CustomerAuthState> {
  @override
  CustomerAuthState build() {
    _loadSavedUser();
    return const CustomerAuthState();
  }

  Future<void> _loadSavedUser() async {
    try {
      final storage = ref.read(secureStorageServiceProvider);
      final userJson = await storage.getCustomerUser();
      if (userJson != null && userJson.isNotEmpty) {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        final user = CustomerUser.fromJson(map);
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
        );
      }
    } catch (_) {}
  }

  void clearMessages() {
    state = state.copyWith(clearMessages: true);
  }

  void setUnverifiedEmail(String email, {String? devCode}) {
    state = state.copyWith(
      unverifiedEmail: email,
      devCode: devCode,
    );
  }

  // 1. Customer Login
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearMessages: true);

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/auth/customer/login',
        data: {
          'email': email.trim(),
          'password': password.trim(),
        },
      );

      final data = response.data;
      if (response.statusCode == 200 && data['success'] == true) {
        final userData = data['data'] as Map<String, dynamic>;
        final user = CustomerUser.fromJson(userData);

        final storage = ref.read(secureStorageServiceProvider);
        await storage.saveAuthToken(user.token);
        await storage.saveUserId(user.id);
        await storage.saveCustomerUser(jsonEncode(user.toJson()));

        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
          successMessage: 'ចូលប្រើប្រាស់ដោយជោគជ័យ (Login successful)',
          clearDevCode: true,
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: data['message']?.toString() ?? 'អុីមែល ឬពាក្យសម្ងាត់មិនត្រឹមត្រូវ (Invalid email or password)',
      );
      return false;
    } on DioException catch (e) {
      final respData = e.response?.data;
      if (respData is Map<String, dynamic>) {
        if (respData['requireVerification'] == true ||
            (respData['message']?.toString().toLowerCase().contains('not verified') ?? false)) {
          state = state.copyWith(
            isLoading: false,
            unverifiedEmail: email.trim(),
            devCode: respData['devCode']?.toString(),
            errorMessage: 'គណនីមិនទាន់បានផ្ទៀងផ្ទាត់ទេ។ សូមបញ្ចូលលេខកូដសម្ងាត់ ៦ ខ្ទង់',
          );
          return false;
        }
        state = state.copyWith(
          isLoading: false,
          errorMessage: respData['message']?.toString() ?? 'អុីមែល ឬពាក្យសម្ងាត់មិនត្រឹមត្រូវ',
        );
        return false;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'មិនអាចភ្ជាប់ទៅកាន់ម៉ាស៊ីនបម្រើបានទេ (Connection error)',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // 2. Customer Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String address = '',
  }) async {
    state = state.copyWith(isLoading: true, clearMessages: true);

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/auth/customer/register',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password.trim(),
          'phone': phone.trim(),
          'address': address.trim(),
        },
      );

      final data = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          unverifiedEmail: email.trim(),
          devCode: data['devCode']?.toString(),
          successMessage: 'លេខកូដសម្ងាត់ ៦ ខ្ទង់ត្រូវបានផ្ញើទៅកាន់អ៊ីមែលរបស់អ្នក (Verification code sent)',
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: data['message']?.toString() ?? 'ការចុះឈ្មោះមិនបានជោគជ័យ',
      );
      return false;
    } on DioException catch (e) {
      final respData = e.response?.data;
      final msg = respData is Map ? respData['message']?.toString() : null;
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg ?? 'ការចុះឈ្មោះមិនបានជោគជ័យ សូមព្យាយាមម្ដងទៀត',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // 3. Customer Verify OTP Code
  Future<bool> verifyCode(String email, String code) async {
    state = state.copyWith(isLoading: true, clearMessages: true);

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/auth/customer/verify',
        data: {
          'email': email.trim(),
          'code': code.trim(),
        },
      );

      final data = response.data;
      if (response.statusCode == 200 && data['success'] == true) {
        final userData = data['data'] as Map<String, dynamic>;
        final user = CustomerUser.fromJson(userData);

        final storage = ref.read(secureStorageServiceProvider);
        await storage.saveAuthToken(user.token);
        await storage.saveUserId(user.id);
        await storage.saveCustomerUser(jsonEncode(user.toJson()));

        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
          successMessage: 'គណនីត្រូវបានផ្ទៀងផ្ទាត់ដោយជោគជ័យ! (Account verified)',
          clearDevCode: true,
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: data['message']?.toString() ?? 'លេខកូដសម្ងាត់មិនត្រឹមត្រូវ ឬផុតកំណត់',
      );
      return false;
    } on DioException catch (e) {
      final respData = e.response?.data;
      final msg = respData is Map ? respData['message']?.toString() : null;
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg ?? 'លេខកូដសម្ងាត់មិនត្រឹមត្រូវ ឬផុតកំណត់ហើយ',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // 4. Customer Resend OTP Code
  Future<bool> resendCode(String email) async {
    state = state.copyWith(isLoading: true, clearMessages: true);

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/auth/customer/resend',
        data: {'email': email.trim()},
      );

      final data = response.data;
      state = state.copyWith(
        isLoading: false,
        devCode: data['devCode']?.toString(),
        successMessage: 'លេខកូដថ្មីត្រូវបានផ្ញើទៅកាន់អ៊ីមែលរបស់អ្នក (New code sent)',
      );
      return true;
    } on DioException catch (e) {
      final respData = e.response?.data;
      final msg = respData is Map ? respData['message']?.toString() : null;
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg ?? 'មិនអាចផ្ញើលេខកូដឡើងវិញបានទេ',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // 5. Customer Logout
  Future<void> logout() async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.clearCustomerUser();
    state = const CustomerAuthState();
  }
}

final customerAuthProvider = NotifierProvider<CustomerAuthNotifier, CustomerAuthState>(() {
  return CustomerAuthNotifier();
});
