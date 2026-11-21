import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Config (can be swapped for flavors: dev, staging, prod)
  AppConfig.initialize(AppConfig.devConfig);

  runApp(
    const ProviderScope(
      child: EcommerceApp(),
    ),
  );
}
