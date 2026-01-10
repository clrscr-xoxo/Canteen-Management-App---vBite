import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/constants/admin_constants.dart';
import '../../../shared/widgets/dashboard_sidebar.dart';
import '../../../shared/widgets/dashboard_topbar.dart';
import '../../../shared/widgets/order_card.dart';
import '../../../shared/widgets/animated_order_card.dart';
import '../../../shared/providers/admin_group_orders_provider.dart';

class AdminGroupOrdersScreen extends StatefulWidget {
  const AdminGroupOrdersScreen({super.key});

  @override
  State<AdminGroupOrdersScreen> createState() => _AdminGroupOrdersScreenState();
}

class _AdminGroupOrdersScreenState extends State<AdminGroupOrdersScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 3; // Group Orders is index 3 in sidebar
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Setup listeners when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminGroupOrdersProvider>(context, listen: false);
      provider.setupListeners();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                    child: Column(
                      children: [
                        // Tab Bar
                        Container(
                          color: AdminTheme.contentBackground,
                          child: TabBar(
                            controller: _tabController,
                            labelColor: AdminTheme.primaryColor,
                            unselectedLabelColor: AdminTheme.textSecondaryColor,
                            indicatorColor: AdminTheme.primaryColor,
                            tabs: const [
                              Tab(
                                icon: Icon(Icons.assignment),
                                text: 'Ongoing',
                              ),
                              Tab(
                                icon: Icon(Icons.check_circle),
                                text: 'Completed',
                              ),
                            ],
                          ),
                        ),

                        // Tab Content
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Ongoing Tab
                              _buildOngoingTab(),
                              // Completed Tab
                              _buildCompletedTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOngoingTab() {
    return Consumer<AdminGroupOrdersProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingActive) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.activeOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 64,
                  color: AdminTheme.textHintColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ongoing group orders',
                  style: AdminTheme.bodyLarge.copyWith(
                    color: AdminTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'New group orders will appear here',
                  style: AdminTheme.bodySmall.copyWith(
                    color: AdminTheme.textHintColor,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => provider.refresh(),
          color: AdminTheme.primaryColor,
          child: ListView(
            padding: const EdgeInsets.all(AdminConstants.defaultPadding),
            children: provider.activeOrders.map((order) {
              final orderId = order['id'] ?? '';
              return AnimatedOrderCard(
                key: ValueKey('group_order_$orderId'),
                animationKey: orderId,
                order: order,
                userName: provider.getUserName(order['userId'] ?? ''),
                showCompleteButton: true,
                isProcessing: provider.isProcessing &&
                    provider.processingOrderId == orderId,
                onComplete: () async {
                  if (!mounted) return;
                  
                  final messenger = ScaffoldMessenger.of(context);
                  final success = await provider.markOrderAsCompleted(orderId);

                  if (!mounted) return;
                  
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Group order marked as completed'
                            : provider.errorMessage ?? 'Failed to update order',
                      ),
                      backgroundColor:
                          success ? AdminTheme.successColor : AdminTheme.errorColor,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCompletedTab() {
    return Consumer<AdminGroupOrdersProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingCompleted) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.completedOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 64,
                  color: AdminTheme.textHintColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No completed group orders',
                  style: AdminTheme.bodyLarge.copyWith(
                    color: AdminTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completed group orders will appear here',
                  style: AdminTheme.bodySmall.copyWith(
                    color: AdminTheme.textHintColor,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => provider.refresh(),
          color: AdminTheme.primaryColor,
          child: ListView(
            padding: const EdgeInsets.all(AdminConstants.defaultPadding),
            children: provider.completedOrders.map((order) {
              return OrderCard(
                order: order,
                userName: provider.getUserName(order['userId'] ?? ''),
                showCompleteButton: false,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

