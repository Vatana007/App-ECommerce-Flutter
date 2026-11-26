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

  /// Hosted Cloud Backend URL (connected to MongoDB Atlas & serving authentic images)
  static const String cloudApiBaseUrl = 'https://e-restaurant-uk4w.onrender.com/api';

  /// Automatically picks the cloud base URL for all devices (Web, Emulator, Physical Android, iOS)
  static String get defaultDevBaseUrl {
    return cloudApiBaseUrl;
  }

  static AppConfig get devConfig => AppConfig(
        environment: Environment.dev,
        apiBaseUrl: defaultDevBaseUrl,
        appName: 'ភោជនីយដ្ឋាន ភូមិយើង (Phum Yeung)',
        enableLogging: true,
      );

  static const AppConfig prodConfig = AppConfig(
    environment: Environment.prod,
    apiBaseUrl: cloudApiBaseUrl,
    appName: 'ភោជនីយដ្ឋាន ភូមិយើង (Phum Yeung)',
    enableLogging: false,
  );
}
