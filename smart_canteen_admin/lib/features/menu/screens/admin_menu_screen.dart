import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/constants/admin_constants.dart';
import '../../../shared/widgets/dashboard_sidebar.dart';
import '../../../shared/widgets/dashboard_topbar.dart';
import '../../../shared/providers/admin_menu_provider.dart';
import '../../../shared/widgets/animated_menu_item_card.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  int _selectedIndex = 2; // Menu is index 2 in sidebar
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load menu items when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminMenuProvider>(context, listen: false);
      provider.loadMenuItems();
      provider.setupListeners();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
                // Top Bar
                const DashboardTopbar(),

                // Content
                Expanded(
                  child: Container(
                    color: AdminTheme.contentBackground,
                    child: Column(
                      children: [
                        // Filters Section (Header)
                        Container(
                          color: AdminTheme.contentBackground,
                          padding: const EdgeInsets.all(AdminConstants.defaultPadding),
                          child: _buildFiltersSection(),
                        ),

                        // Menu Items List
                        Expanded(
                          child: _buildMenuItemsList(),
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

  Widget _buildFiltersSection() {
    return Consumer<AdminMenuProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Menu Management',
                  style: AdminTheme.heading2.copyWith(
                    color: AdminTheme.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Refresh Button
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: AdminTheme.textPrimaryColor,
                  ),
                  onPressed: provider.isLoading
                      ? null
                      : () => provider.refresh(),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Filters Row - Wrap for responsiveness
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              children: [
                // Search Bar
                SizedBox(
                  width: 250,
                  child: TextField(
                        controller: _searchController,
                        style: AdminTheme.bodyMedium.copyWith(
                          color: AdminTheme.textPrimaryColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search menu items...',
                          hintStyle: AdminTheme.bodyMedium.copyWith(
                            color: AdminTheme.textSecondaryColor,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AdminTheme.textSecondaryColor,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: AdminTheme.textSecondaryColor,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.setSearchQuery('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AdminConstants.borderRadius,
                            ),
                            borderSide: BorderSide(
                              color: AdminTheme.textHintColor.withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AdminConstants.borderRadius,
                            ),
                            borderSide: BorderSide(
                              color: AdminTheme.textHintColor.withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AdminConstants.borderRadius,
                            ),
                            borderSide: BorderSide(
                              color: AdminTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          provider.setSearchQuery(value);
                        },
                      ),
                    ),
                // Category Filter
                Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AdminConstants.borderRadius,
                        ),
                        border: Border.all(
                          color: AdminTheme.textHintColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: DropdownButton<String>(
                        hint: Text(
                          'All Categories',
                          style: AdminTheme.bodyMedium.copyWith(
                            color: AdminTheme.textSecondaryColor,
                          ),
                        ),
                        value: provider.selectedCategoryId,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ...provider.categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category['id'],
                              child: Text(category['name'] ?? 'Unknown'),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          provider.setCategoryFilter(value);
                        },
                        style: AdminTheme.bodyMedium.copyWith(
                          color: AdminTheme.textPrimaryColor,
                        ),
                        underline: const SizedBox.shrink(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AdminTheme.textPrimaryColor,
                        ),
                        isExpanded: false,
                      ),
                    ),
                // Availability Filter
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AdminConstants.borderRadius,
                      ),
                      border: Border.all(
                        color: AdminTheme.textHintColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: DropdownButton<bool?>(
                      hint: Text(
                        'All Items',
                        style: AdminTheme.bodyMedium.copyWith(
                          color: AdminTheme.textSecondaryColor,
                        ),
                      ),
                      value: provider.availabilityFilter,
                      items: const [
                        DropdownMenuItem<bool?>(
                          value: null,
                          child: Text('All Items'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: true,
                          child: Text('Available Only'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: false,
                          child: Text('Sold Out Only'),
                        ),
                      ],
                      onChanged: (value) {
                        provider.setAvailabilityFilter(value);
                      },
                      style: AdminTheme.bodyMedium.copyWith(
                        color: AdminTheme.textPrimaryColor,
                      ),
                      underline: const SizedBox.shrink(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: AdminTheme.textPrimaryColor,
                      ),
                      isExpanded: false,
                      ),
                    ),
                // Clear Filters Button
                TextButton.icon(
                    onPressed: () {
                      provider.clearFilters();
                      _searchController.clear();
                    },
                    icon: Icon(
                      Icons.clear_all,
                      size: 18,
                      color: AdminTheme.primaryColor,
                    ),
                    label: Text(
                      'Clear',
                      style: AdminTheme.bodyMedium.copyWith(
                        color: AdminTheme.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItemsList() {
    return Consumer<AdminMenuProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.menuItems.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.hasError && provider.menuItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AdminTheme.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading menu items',
                  style: AdminTheme.heading2.copyWith(
                    color: AdminTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage ?? 'Unknown error',
                  style: AdminTheme.bodyMedium.copyWith(
                    color: AdminTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        final filteredItems = provider.filteredMenuItems;

        if (filteredItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 64,
                  color: AdminTheme.textHintColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No menu items found',
                  style: AdminTheme.heading2.copyWith(
                    color: AdminTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters',
                  style: AdminTheme.bodyMedium.copyWith(
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
          child: ListView.builder(
            padding: const EdgeInsets.all(AdminConstants.defaultPadding),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final itemId = item['id'] ?? '';
              final isAvailable = item['isAvailable'] ?? true;
              
              return AnimatedMenuItemCard(
                key: ValueKey('menu_item_$itemId'),
                animationKey: itemId,
                item: item,
                isProcessing: provider.isProcessingItem(itemId),
                onToggleAvailability: () async {
                  if (!mounted) return;
                  
                  final messenger = ScaffoldMessenger.of(context);
                  final success = await provider.toggleItemAvailability(itemId);

                  if (!mounted) return;
                  
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? (isAvailable
                                ? 'Item marked as sold out'
                                : 'Item marked as available')
                            : provider.errorMessage ?? 'Failed to update item availability',
                      ),
                      backgroundColor: success
                          ? (isAvailable
                              ? AdminTheme.errorColor
                              : AdminTheme.successColor)
                          : AdminTheme.errorColor,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

}

