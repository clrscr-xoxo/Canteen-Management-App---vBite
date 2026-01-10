import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/admin_theme.dart';
import '../../core/constants/admin_constants.dart';

class RecentActivityList extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final Map<String, String> userNames;
  final bool isLoading;

  const RecentActivityList({
    super.key,
    required this.orders,
    required this.userNames,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: AdminTheme.textHintColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No recent activity',
                style: AdminTheme.bodyLarge.copyWith(
                  color: AdminTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Activity will appear here once orders are placed',
                style: AdminTheme.bodySmall.copyWith(
                  color: AdminTheme.textHintColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final userId = order['userId'] ?? '';
    final userName = userNames[userId] ?? 'Unknown User';
    final totalAmount = (order['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final orderStatus = order['orderStatus'] ?? 'active';
    final paymentStatus = order['paymentStatus'] ?? 'pending';
    final createdAt = order['createdAt'];
    final items = order['items'] as List<dynamic>? ?? [];
    final itemsCount = items.length;

    // Format date
    String formattedDate = 'Just now';
    if (createdAt != null) {
      if (createdAt is Timestamp) {
        final date = createdAt.toDate();
        final now = DateTime.now();
        final difference = now.difference(date);

        if (difference.inMinutes < 1) {
          formattedDate = 'Just now';
        } else if (difference.inHours < 1) {
          formattedDate = '${difference.inMinutes}m ago';
        } else if (difference.inDays < 1) {
          formattedDate = '${difference.inHours}h ago';
        } else {
          formattedDate = DateFormat('MMM d, y HH:mm').format(date);
        }
      }
    }

    // Status color
    Color statusColor = AdminTheme.primaryColor;
    IconData statusIcon = Icons.shopping_bag;
    
    switch (orderStatus.toString().toLowerCase()) {
      case 'active':
        statusColor = AdminTheme.warningColor;
        statusIcon = Icons.assignment;
        break;
      case 'completed':
        statusColor = AdminTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = AdminTheme.errorColor;
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AdminConstants.smallPadding),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AdminConstants.defaultPadding,
          vertical: AdminConstants.smallPadding,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
        ),
        title: Text(
          userName,
          style: AdminTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AdminTheme.textPrimaryColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '$itemsCount item${itemsCount != 1 ? 's' : ''} • $formattedDate',
              style: AdminTheme.bodySmall.copyWith(
                color: AdminTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    orderStatus.toString().toUpperCase(),
                    style: AdminTheme.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
                if (paymentStatus.toString().toLowerCase() == 'paid') ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AdminTheme.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'PAID',
                      style: AdminTheme.bodySmall.copyWith(
                        color: AdminTheme.successColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Text(
          '₹${totalAmount.toStringAsFixed(2)}',
          style: AdminTheme.heading3.copyWith(
            color: AdminTheme.textPrimaryColor,
          ),
        ),
      ),
    );
  }
}

