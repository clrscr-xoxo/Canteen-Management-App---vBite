import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/constants/admin_constants.dart';
import '../../../shared/widgets/dashboard_sidebar.dart';
import '../../../shared/widgets/dashboard_topbar.dart';
import '../../../shared/providers/admin_reports_provider.dart';
import '../../../core/services/admin_reports_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 4; // Reports is index 4 in sidebar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load reports data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminReportsProvider>(context, listen: false);
      provider.loadReportsData();
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
                        // Header Section
                        _buildHeaderSection(),

                        // Time Range Selector
                        _buildTimeRangeSelector(),

                        // Tabs
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: AdminTheme.primaryColor,
                            unselectedLabelColor: AdminTheme.textSecondaryColor,
                            indicatorColor: AdminTheme.primaryColor,
                            indicatorWeight: 3,
                            labelStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            tabs: const [
                              Tab(
                                icon: Icon(Icons.trending_up, size: 20),
                                text: 'Revenue',
                              ),
                              Tab(
                                icon: Icon(Icons.star, size: 20),
                                text: 'Top Items',
                              ),
                              Tab(
                                icon: Icon(Icons.bar_chart, size: 20),
                                text: 'Order Stats',
                              ),
                              Tab(
                                icon: Icon(Icons.access_time, size: 20),
                                text: 'Peak Hours',
                              ),
                            ],
                          ),
                        ),

                        // Tab Content
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: const [
                              RevenueReportTab(),
                              TopSellingItemsTab(),
                              OrderStatisticsTab(),
                              PeakHoursTab(),
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

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AdminTheme.primaryColor,
            AdminTheme.primaryDarkColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AdminTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.analytics,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reports & Analytics',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Comprehensive insights into your canteen operations',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Consumer<AdminReportsProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminConstants.defaultPadding * 2,
            vertical: AdminConstants.defaultPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AdminTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.date_range, size: 18, color: AdminTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Time Range:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AdminTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildTimeRangeButton(provider, ReportTimeRange.today, 'Today', Icons.today),
                    _buildTimeRangeButton(provider, ReportTimeRange.week, 'This Week', Icons.view_week),
                    _buildTimeRangeButton(provider, ReportTimeRange.month, 'This Month', Icons.calendar_month),
                    _buildTimeRangeButton(provider, ReportTimeRange.year, 'This Year', Icons.calendar_today),
                    _buildTimeRangeButton(provider, ReportTimeRange.custom, 'Custom', Icons.tune),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: provider.isLoading ? null : () => provider.refresh(),
                  tooltip: 'Refresh',
                  color: AdminTheme.primaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeRangeButton(AdminReportsProvider provider, ReportTimeRange range, String label, IconData icon) {
    final isSelected = provider.selectedTimeRange == range;
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [AdminTheme.primaryColor, AdminTheme.primaryDarkColor],
              )
            : null,
        color: isSelected ? null : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? null
            : Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AdminTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (range == ReportTimeRange.custom) {
              _showCustomDateRangePickerDialog(provider);
            } else {
              provider.setTimeRange(range);
              provider.loadReportsData();
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : AdminTheme.textSecondaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AdminTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCustomDateRangePickerDialog(AdminReportsProvider provider) async {
    DateTime startDate = provider.customStartDate ?? DateTime.now().subtract(const Duration(days: 7));
    DateTime endDate = provider.customEndDate ?? DateTime.now();

    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey[50]!,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AdminTheme.primaryColor,
                            AdminTheme.primaryDarkColor,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Select Custom Date Range',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildAttractiveDateSelector(
                                  context: context,
                                  label: 'Start Date',
                                  date: startDate,
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: startDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: AdminTheme.primaryColor,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: AdminTheme.textPrimaryColor,
                                              secondary: AdminTheme.primaryLightColor,
                                            ),
                                            dialogTheme: DialogThemeData(
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        startDate = picked;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildAttractiveDateSelector(
                                  context: context,
                                  label: 'End Date',
                                  date: endDate,
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: endDate,
                                      firstDate: startDate,
                                      lastDate: DateTime.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: AdminTheme.primaryColor,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: AdminTheme.textPrimaryColor,
                                              secondary: AdminTheme.primaryLightColor,
                                            ),
                                            dialogTheme: DialogThemeData(
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        endDate = picked;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (startDate.isAfter(endDate))
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AdminTheme.errorColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AdminTheme.errorColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: AdminTheme.errorColor, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Start date must be before end date',
                                      style: TextStyle(
                                        color: AdminTheme.errorColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Actions
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: AdminTheme.textSecondaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: !startDate.isAfter(endDate)
                                ? () {
                                    provider.setTimeRange(
                                      ReportTimeRange.custom,
                                      customStart: startDate,
                                      customEnd: endDate,
                                    );
                                    provider.loadReportsData();
                                    Navigator.of(context).pop();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Apply',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAttractiveDateSelector({
    required BuildContext context,
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AdminTheme.textSecondaryColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[200]!,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AdminTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: AdminTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${date.day}/${date.month}/${date.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getFormattedDayName(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: AdminTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AdminTheme.primaryColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getFormattedDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]}';
  }
}

// Revenue Report Tab
class RevenueReportTab extends StatelessWidget {
  const RevenueReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminReportsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${provider.errorMessage}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final revenueData = provider.revenueData;
        if (revenueData == null || revenueData.isEmpty) {
          return const Center(
            child: Text('No revenue data available'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AdminConstants.defaultPadding * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Revenue',
                      '₹${_formatCurrency(revenueData['totalRevenue'] as double)}',
                      AdminTheme.primaryColor,
                      Icons.attach_money,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Paid Revenue',
                      '₹${_formatCurrency(revenueData['paidRevenue'] as double)}',
                      AdminTheme.successColor,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Pending Revenue',
                      '₹${_formatCurrency(revenueData['pendingRevenue'] as double)}',
                      AdminTheme.warningColor,
                      Icons.pending,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Avg Order Value',
                      '₹${_formatCurrency(revenueData['avgOrderValue'] as double)}',
                      AdminTheme.accentColor,
                      Icons.shopping_cart,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Revenue Chart
              _buildRevenueChart(revenueData['dailyRevenue'] as Map<String, double>),
              const SizedBox(height: 32),
              
              // Section Title
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'Order Statistics',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AdminTheme.textPrimaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              
              // Additional Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Orders',
                      '${revenueData['totalOrders']}',
                      AdminTheme.textSecondaryColor,
                      Icons.receipt_long,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Paid Orders',
                      '${revenueData['paidOrders']}',
                      AdminTheme.successColor,
                      Icons.verified,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Pending Orders',
                      '${revenueData['pendingOrders']}',
                      AdminTheme.warningColor,
                      Icons.hourglass_empty,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AdminTheme.textSecondaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(Map<String, double> dailyRevenue) {
    if (dailyRevenue.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bar_chart, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No data available for chart',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final sortedEntries = dailyRevenue.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AdminTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: AdminTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Daily Revenue Trend',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AdminTheme.textPrimaryColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 350,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: _getChartInterval(sortedEntries),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 55,
                        interval: _getChartInterval(sortedEntries),
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              _formatCurrencyForChart(value),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        interval: _getBottomInterval(sortedEntries.length),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < sortedEntries.length) {
                            final dateStr = sortedEntries[index].key;
                            final date = DateTime.parse(dateStr);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[400]!, width: 1),
                      left: BorderSide(color: Colors.grey[400]!, width: 1),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AdminTheme.primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AdminTheme.primaryColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AdminTheme.primaryColor.withValues(alpha: 0.3),
                            AdminTheme.primaryColor.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: _getMaxY(sortedEntries),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    }
    return amount.toStringAsFixed(2);
  }

  double _getMaxY(List<MapEntry<String, double>> sortedEntries) {
    if (sortedEntries.isEmpty) return 1000;
    final maxValue = sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    // Add 20% padding and round to nice numbers
    final padded = maxValue * 1.2;
    if (padded < 1000) return 1000;
    return (padded / 1000).ceil() * 1000;
  }

  double _getChartInterval(List<MapEntry<String, double>> sortedEntries) {
    final maxY = _getMaxY(sortedEntries);
    if (maxY <= 2000) return 500;
    if (maxY <= 5000) return 1000;
    if (maxY <= 10000) return 2000;
    return maxY / 5;
  }

  double _getBottomInterval(int length) {
    if (length <= 7) return 1;
    if (length <= 14) return 2;
    if (length <= 30) return 3;
    return length / 10;
  }

  String _formatCurrencyForChart(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }
}

// Top Selling Items Tab
class TopSellingItemsTab extends StatelessWidget {
  const TopSellingItemsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminReportsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${provider.errorMessage}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final items = provider.topSellingItems;
        if (items.isEmpty) {
          return const Center(
            child: Text('No items data available'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AdminConstants.defaultPadding * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AdminTheme.accentColor.withValues(alpha: 0.1),
                      AdminTheme.accentColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AdminTheme.accentColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AdminTheme.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.star, color: AdminTheme.accentColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Top ${items.length} Selling Items',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AdminTheme.textPrimaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Items List
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildItemCard(item, index + 1);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, int rank) {
    final quantity = item['quantity'] as int;
    final revenue = item['revenue'] as double;
    final orders = item['orders'] as int;

    final rankColor = rank <= 3 
        ? (rank == 1 ? Colors.amber : rank == 2 ? Colors.grey[400]! : Colors.brown[300]!)
        : AdminTheme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rankColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: rank <= 3
                    ? LinearGradient(
                        colors: rank == 1
                            ? [Colors.amber, Colors.orange]
                            : rank == 2
                                ? [Colors.grey[400]!, Colors.grey[600]!]
                                : [Colors.brown[300]!, Colors.brown[500]!],
                      )
                    : LinearGradient(
                        colors: [
                          AdminTheme.primaryColor,
                          AdminTheme.primaryDarkColor,
                        ],
                      ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: rankColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Item Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] as String? ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AdminTheme.textPrimaryColor,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AdminTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shopping_cart, size: 14, color: AdminTheme.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              '$quantity sold',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AdminTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AdminTheme.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt, size: 14, color: AdminTheme.accentColor),
                            const SizedBox(width: 4),
                            Text(
                              '$orders orders',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AdminTheme.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Revenue
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AdminTheme.successColor.withValues(alpha: 0.2),
                    AdminTheme.successColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AdminTheme.successColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.currency_rupee, color: AdminTheme.successColor, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    revenue.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AdminTheme.successColor,
                    ),
                  ),
                  Text(
                    'Revenue',
                    style: TextStyle(
                      fontSize: 10,
                      color: AdminTheme.successColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Order Statistics Tab
class OrderStatisticsTab extends StatelessWidget {
  const OrderStatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminReportsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${provider.errorMessage}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final stats = provider.orderStatistics;
        if (stats == null || stats.isEmpty) {
          return const Center(
            child: Text('No statistics available'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AdminConstants.defaultPadding * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AdminTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.bar_chart, color: AdminTheme.primaryColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Order Status Overview',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AdminTheme.textPrimaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Orders',
                      '${stats['totalOrders']}',
                      AdminTheme.primaryColor,
                      Icons.receipt_long,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Active Orders',
                      '${stats['activeOrders']}',
                      AdminTheme.warningColor,
                      Icons.pending,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Completed Orders',
                      '${stats['completedOrders']}',
                      AdminTheme.successColor,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Cancelled Orders',
                      '${stats['cancelledOrders']}',
                      AdminTheme.errorColor,
                      Icons.cancel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Order Type Distribution
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Group Orders',
                      '${stats['groupOrders']}',
                      AdminTheme.accentColor,
                      Icons.group,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Individual Orders',
                      '${stats['individualOrders']}',
                      AdminTheme.primaryColor,
                      Icons.person,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Completion Rate',
                      '${(stats['completionRate'] as double).toStringAsFixed(1)}%',
                      AdminTheme.successColor,
                      Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Avg Processing Time',
                      '${(stats['avgProcessingTime'] as double).toStringAsFixed(0)} min',
                      AdminTheme.textSecondaryColor,
                      Icons.timer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Section Title for Chart
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AdminTheme.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.pie_chart, color: AdminTheme.accentColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Order Status Distribution',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AdminTheme.textPrimaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Order Status Pie Chart
              _buildOrderStatusChart(stats),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AdminTheme.textSecondaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusChart(Map<String, dynamic> stats) {
    final active = stats['activeOrders'] as int;
    final completed = stats['completedOrders'] as int;
    final cancelled = stats['cancelledOrders'] as int;
    final total = active + completed + cancelled;

    if (total == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: Text('No data available')),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Status Distribution',
              style: AdminTheme.heading3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: active.toDouble(),
                      color: AdminTheme.warningColor,
                      title: 'Active\n$active',
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: completed.toDouble(),
                      color: AdminTheme.successColor,
                      title: 'Completed\n$completed',
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: cancelled.toDouble(),
                      color: AdminTheme.errorColor,
                      title: 'Cancelled\n$cancelled',
                      radius: 80,
                    ),
                  ],
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Peak Hours Tab
class PeakHoursTab extends StatelessWidget {
  const PeakHoursTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminReportsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${provider.errorMessage}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final peakData = provider.peakHoursData;
        if (peakData == null || peakData.isEmpty) {
          return const Center(
            child: Text('No peak hours data available'),
          );
        }

        final hourlyData = peakData['hourlyData'] as List<Map<String, dynamic>>;
        final dayOfWeekData = peakData['dayOfWeekData'] as List<Map<String, dynamic>>;
        final peakHour = peakData['peakHour'] as int;
        final peakDay = peakData['peakDay'] as int;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AdminConstants.defaultPadding * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Peak Insights
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: AdminTheme.primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Peak Hour',
                                  style: AdminTheme.heading3,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
              Text(
                _formatHour(peakHour),
                style: AdminTheme.heading1.copyWith(color: AdminTheme.primaryColor),
              ),
                            Text(
                              '${hourlyData[peakHour]['orderCount']} orders',
                              style: AdminTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: AdminTheme.accentColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Peak Day',
                                  style: AdminTheme.heading3,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getDayName(peakDay),
                              style: AdminTheme.heading1.copyWith(color: AdminTheme.accentColor),
                            ),
                            Text(
                              '${dayOfWeekData[peakDay]['orderCount']} orders',
                              style: AdminTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Hourly Order Chart
              _buildHourlyChart(hourlyData),
              const SizedBox(height: 32),
              
              // Day of Week Chart
              _buildDayOfWeekChart(dayOfWeekData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHourlyChart(List<Map<String, dynamic>> hourlyData) {
    final maxOrders = hourlyData.map((e) => e['orderCount'] as int).reduce((a, b) => a > b ? a : b);
    final maxY = (maxOrders * 1.2).ceil();
    final interval = maxY <= 10 ? 2 : (maxY <= 20 ? 5 : (maxY <= 50 ? 10 : maxY ~/ 5));
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders by Hour of Day',
              style: AdminTheme.heading3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 350,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval.toDouble(),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: interval.toDouble(),
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 3, // Show every 3rd hour for readability
                        getTitlesWidget: (value, meta) {
                          final hour = value.toInt();
                          if (hour >= 0 && hour < 24 && hour % 3 == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _formatHourSimple(hour),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[400]!, width: 1),
                      left: BorderSide(color: Colors.grey[400]!, width: 1),
                    ),
                  ),
                  barGroups: hourlyData.asMap().entries.map((entry) {
                    final orderCount = entry.value['orderCount'] as int;
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: orderCount.toDouble(),
                          color: AdminTheme.primaryColor,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  maxY: maxY.toDouble(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayOfWeekChart(List<Map<String, dynamic>> dayOfWeekData) {
    final maxOrders = dayOfWeekData.map((e) => e['orderCount'] as int).reduce((a, b) => a > b ? a : b);
    final maxY = (maxOrders * 1.2).ceil();
    final interval = maxY <= 10 ? 2 : (maxY <= 20 ? 5 : (maxY <= 50 ? 10 : maxY ~/ 5));
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders by Day of Week',
              style: AdminTheme.heading3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 350,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval.toDouble(),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: interval.toDouble(),
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          final day = value.toInt();
                          if (day >= 0 && day < 7) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _getDayNameShort(day),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[400]!, width: 1),
                      left: BorderSide(color: Colors.grey[400]!, width: 1),
                    ),
                  ),
                  barGroups: dayOfWeekData.asMap().entries.map((entry) {
                    final orderCount = entry.value['orderCount'] as int;
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: orderCount.toDouble(),
                          color: AdminTheme.accentColor,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  maxY: maxY.toDouble(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }

  String _formatHourSimple(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour$period';
  }

  String _getDayNameShort(int dayIndex) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dayIndex];
  }

  String _getDayName(int dayIndex) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayIndex];
  }
}

