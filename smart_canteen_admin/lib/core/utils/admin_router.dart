import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/admin_auth_provider.dart';
import '../../features/auth/screens/admin_login_screen.dart';
import '../../features/dashboard/screens/dashboard_home_screen.dart';
import '../../features/orders/screens/admin_orders_screen.dart';
import '../../features/group_orders/screens/admin_group_orders_screen.dart';
import '../../features/menu/screens/admin_menu_screen.dart';
import '../../features/reports/screens/admin_reports_screen.dart';

class AdminRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      try {
        final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.isAuthenticated;
        final isOnLoginScreen = state.uri.path == '/login';

        // If user is not authenticated and not on login screen, redirect to login
        if (!isAuthenticated && !isOnLoginScreen) {
          return '/login';
        }

        // If user is authenticated and on login screen, redirect to dashboard
        if (isAuthenticated && isOnLoginScreen) {
          return '/dashboard';
        }

        return null; // No redirect needed
      } catch (e) {
        // Provider not available yet - allow navigation to proceed
        // The auth check will happen in the screen itself
        return null;
      }
    },
    routes: [
      // Login Route
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),

      // Dashboard Route
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardHomeScreen(),
      ),

      // Orders Route
      GoRoute(
        path: '/orders',
        builder: (context, state) => const AdminOrdersScreen(),
      ),

      // Menu Route
      GoRoute(
        path: '/menu',
        builder: (context, state) => const AdminMenuScreen(),
      ),

      // Group Orders Route
      GoRoute(
        path: '/group-orders',
        builder: (context, state) => const AdminGroupOrdersScreen(),
      ),

      // Reports Route
      GoRoute(
        path: '/reports',
        builder: (context, state) => const AdminReportsScreen(),
      ),

      // Settings Route (Placeholder for Phase 7)
      GoRoute(
        path: '/settings',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text('Coming in Phase 7'),
              ],
            ),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;
}

