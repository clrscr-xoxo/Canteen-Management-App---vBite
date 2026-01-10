import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/admin_theme.dart';
import '../../core/constants/admin_constants.dart';

class DashboardSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const DashboardSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<DashboardSidebar> {
  final List<SidebarItem> _menuItems = [
    SidebarItem(
      icon: Icons.dashboard_outlined,
      label: 'Dashboard',
      route: '/dashboard',
      index: 0,
    ),
    SidebarItem(
      icon: Icons.shopping_bag_outlined,
      label: 'Orders',
      route: '/orders',
      index: 1,
    ),
    SidebarItem(
      icon: Icons.restaurant_menu_outlined,
      label: 'Menu',
      route: '/menu',
      index: 2,
    ),
    SidebarItem(
      icon: Icons.group_outlined,
      label: 'Group Orders',
      route: '/group-orders',
      index: 3,
    ),
    SidebarItem(
      icon: Icons.analytics_outlined,
      label: 'Reports',
      route: '/reports',
      index: 4,
    ),
    SidebarItem(
      icon: Icons.settings_outlined,
      label: 'Settings',
      route: '/settings',
      index: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AdminConstants.sidebarWidth,
      color: AdminTheme.surfaceColor,
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(AdminConstants.defaultPadding),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AdminTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'VBite Admin',
                  style: TextStyle(
                    color: AdminTheme.textOnDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AdminTheme.textOnDark, height: 1),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = widget.selectedIndex == item.index;

                return _buildMenuItem(item, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(SidebarItem item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            widget.onItemSelected(item.index);
            context.go(item.route);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminConstants.defaultPadding,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AdminTheme.primaryColor.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected
                      ? AdminTheme.primaryColor
                      : AdminTheme.textOnDark.withValues(alpha: 0.7),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    color: isSelected
                        ? AdminTheme.primaryColor
                        : AdminTheme.textOnDark.withValues(alpha: 0.7),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SidebarItem {
  final IconData icon;
  final String label;
  final String route;
  final int index;

  SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.index,
  });
}

