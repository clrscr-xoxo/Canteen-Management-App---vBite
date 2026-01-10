import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/admin_theme.dart';
import '../../core/constants/admin_constants.dart';
import '../../shared/providers/admin_auth_provider.dart';

class DashboardTopbar extends StatelessWidget {
  const DashboardTopbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(
        horizontal: AdminConstants.defaultPadding * 2,
      ),
      decoration: BoxDecoration(
        color: AdminTheme.contentBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page Title (will be dynamic based on route)
          Text(
            'Dashboard',
            style: AdminTheme.heading3.copyWith(
              color: AdminTheme.textPrimaryColor,
            ),
          ),

          // User Info & Actions
          Consumer<AdminAuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.currentUser;
              final userName = user?['name'] ?? 'Admin';
              final userEmail = user?['email'] ?? '';

              return Row(
                children: [
                  // User Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AdminTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // User Info
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: AdminTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AdminTheme.textPrimaryColor,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: AdminTheme.bodySmall.copyWith(
                          color: AdminTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Logout Button
                  IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: AdminTheme.textPrimaryColor,
                    ),
                    tooltip: 'Logout',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AdminTheme.errorColor,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await authProvider.signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}









