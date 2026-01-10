import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/admin_theme.dart';
import 'core/utils/admin_router.dart';
import 'shared/providers/admin_auth_provider.dart';
import 'shared/providers/admin_dashboard_provider.dart';
import 'shared/providers/admin_orders_provider.dart';
import 'shared/providers/admin_group_orders_provider.dart';
import 'shared/providers/admin_menu_provider.dart';
import 'shared/providers/admin_reports_provider.dart';
import 'core/constants/admin_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('Firebase already initialized, continuing...');
    } else {
      debugPrint('Firebase initialization error: $e');
    }
  }

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
        ChangeNotifierProvider(create: (_) => AdminOrdersProvider()),
        ChangeNotifierProvider(create: (_) => AdminGroupOrdersProvider()),
        ChangeNotifierProvider(create: (_) => AdminMenuProvider()),
        ChangeNotifierProvider(create: (_) => AdminReportsProvider()),
      ],
      child: MaterialApp.router(
        title: AdminConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AdminTheme.lightTheme,
        routerConfig: AdminRouter.router,
      ),
    );
  }
}
