import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/constants/admin_constants.dart';
import '../../../shared/widgets/dashboard_sidebar.dart';
import '../../../shared/widgets/dashboard_topbar.dart';
import '../../../shared/widgets/dashboard_stat_card.dart';
import '../../../shared/widgets/recent_activity_list.dart';
import '../../../shared/providers/admin_dashboard_provider.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load dashboard data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminDashboardProvider>(context, listen: false);
      provider.loadDashboardData();
      provider.setupRealtimeListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.backgroundColor,
      body: Row(
        children: [
          // Sidebar
          DashboardSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Topbar
                const DashboardTopbar(),

                // Content
                Expanded(
                  child: Container(
                    color: AdminTheme.contentBackground,
                    padding: const EdgeInsets.all(AdminConstants.defaultPadding * 2),
                    child: _buildDashboardContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Consumer<AdminDashboardProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          color: AdminTheme.primaryColor,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to Admin Dashboard',
                            style: AdminTheme.heading1.copyWith(
                              color: AdminTheme.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage your canteen operations from here',
                            style: AdminTheme.bodyLarge.copyWith(
                              color: AdminTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => provider.refresh(),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Stats Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 4;
                    if (constraints.maxWidth < 1200) crossAxisCount = 2;
                    if (constraints.maxWidth < 600) crossAxisCount = 1;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: AdminConstants.defaultPadding,
                      mainAxisSpacing: AdminConstants.defaultPadding,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.5,
                      children: [
                        DashboardStatCard(
                          title: 'Total Orders Today',
                          value: provider.totalOrdersToday.toString(),
                          icon: Icons.shopping_bag,
                          color: AdminTheme.primaryColor,
                          isLoading: provider.isLoadingStats,
                        ),
                        DashboardStatCard(
                          title: 'Active Orders',
                          value: provider.activeOrdersCount.toString(),
                          icon: Icons.assignment,
                          color: AdminTheme.warningColor,
                          isLoading: provider.isLoadingStats,
                        ),
                        DashboardStatCard(
                          title: 'Revenue Today',
                          value: '₹${provider.revenueToday.toStringAsFixed(2)}',
                          icon: Icons.currency_rupee,
                          color: AdminTheme.successColor,
                          isLoading: provider.isLoadingStats,
                        ),
                        DashboardStatCard(
                          title: 'Popular Items',
                          value: provider.popularItems.isEmpty
                              ? '0'
                              : provider.popularItems.length.toString(),
                          icon: Icons.restaurant,
                          color: AdminTheme.secondaryColor,
                          isLoading: provider.isLoadingStats,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Popular Items Detail (if available)
                if (provider.popularItems.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AdminConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Popular Items Today',
                            style: AdminTheme.heading3,
                          ),
                          const SizedBox(height: 16),
                          ...provider.popularItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AdminTheme.primaryColor.withValues(alpha: 0.1),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: AdminTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                item['name'] ?? 'Unknown Item',
                                style: AdminTheme.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: Text(
                                '${item['count']} orders',
                                style: AdminTheme.bodyMedium.copyWith(
                                  color: AdminTheme.textSecondaryColor,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Recent Activity
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AdminConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Activity',
                              style: AdminTheme.heading3,
                            ),
                            if (provider.recentOrders.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  // TODO: Navigate to orders screen (Phase 4)
                                },
                                child: const Text('View All'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        RecentActivityList(
                          orders: provider.recentOrders,
                          userNames: provider.userNames,
                          isLoading: provider.isLoadingRecentOrders,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

