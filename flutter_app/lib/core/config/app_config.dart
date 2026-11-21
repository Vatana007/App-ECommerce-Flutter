import 'package:flutter/foundation.dart';

enum Environment { dev, staging, prod }

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String appName;
  final bool enableLogging;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.appName,
    this.enableLogging = true,
  });

  static AppConfig? _instance;
  static AppConfig get instance => _instance ?? devConfig;

  static void initialize(AppConfig config) {
    _instance = config;
  }

  /// Automatically picks the correct base URL based on device/platform
  static String get defaultDevBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api/v1';
    }
    // Android emulator requires 10.0.2.2 instead of localhost
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api/v1';
    }
    // Windows, macOS, Linux, iOS simulator
    return 'http://127.0.0.1:5000/api/v1';
  }

  static AppConfig get devConfig => AppConfig(
        environment: Environment.dev,
        apiBaseUrl: defaultDevBaseUrl,
        appName: 'Phum Yeung Restaurant (Dev)',
        enableLogging: true,
      );

  static const AppConfig prodConfig = AppConfig(
    environment: Environment.prod,
    apiBaseUrl: 'https://api.yourdomain.com/api/v1',
    appName: 'E-Commerce',
    enableLogging: false,
  );
}
