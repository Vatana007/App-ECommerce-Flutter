import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_dishes_screen.dart';
import '../../features/admin/presentation/screens/admin_orders_screen.dart';
import '../../features/admin/presentation/screens/admin_settings_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/catalog/presentation/screens/catalog_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/checkout/presentation/screens/khqr_payment_screen.dart';
import '../../features/checkout/presentation/screens/order_success_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/orders/domain/entities/order_entity.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/product_detail/presentation/screens/product_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/scan/presentation/screens/product_scan_screen.dart';
import '../../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../../shared/widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ShellRoute with BottomNavigationBar (Home, Catalog, Scan, Wishlist, Profile)
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/catalog',
          name: 'catalog',
          builder: (context, state) => const CatalogScreen(),
        ),
        GoRoute(
          path: '/scan',
          name: 'scan',
          builder: (context, state) => const ProductScanScreen(),
        ),
        GoRoute(
          path: '/wishlist',
          name: 'wishlist',
          builder: (context, state) => const WishlistScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    // Track order alias & routes (Track order accessible from Profile)
    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) => const OrdersScreen(),
    ),
    GoRoute(
      path: '/track-order',
      redirect: (context, state) => '/orders',
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/menu',
      redirect: (context, state) => '/catalog',
    ),

    // Admin Portal Routes (All-in-One)
    GoRoute(
      path: '/admin/dashboard',
      name: 'admin_dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/orders',
      name: 'admin_orders',
      builder: (context, state) => const AdminOrdersScreen(),
    ),
    GoRoute(
      path: '/admin/dishes',
      name: 'admin_dishes',
      builder: (context, state) => const AdminDishesScreen(),
    ),
    GoRoute(
      path: '/admin/settings',
      name: 'admin_settings',
      builder: (context, state) => const AdminSettingsScreen(),
    ),

    // Fullscreen Feature Routes
    GoRoute(
      path: '/product/:id',
      name: 'product_detail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ProductDetailScreen(productId: id);
      },
    ),
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/khqr-payment',
      name: 'khqr_payment',
      builder: (context, state) {
        final order = state.extra as OrderEntity;
        return KhqrPaymentScreen(order: order);
      },
    ),
    GoRoute(
      path: '/order-success/:id',
      name: 'order_success',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return OrderSuccessScreen(orderId: id);
      },
    ),
    GoRoute(
      path: '/order-detail/:id',
      name: 'order_detail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return OrderDetailScreen(orderId: id);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('ទំព័ររកមិនឃើញ: ${state.error}'),
    ),
  ),
);
