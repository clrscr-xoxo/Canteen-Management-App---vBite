import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/admin_theme.dart';
import '../../core/constants/admin_constants.dart';

/// Animated Order Card that can fade out and slide to the right
class AnimatedOrderCard extends StatefulWidget {
  final Map<String, dynamic> order;
  final String userName;
  final bool showCompleteButton;
  final VoidCallback? onComplete;
  final bool isProcessing;
  final String animationKey;

  const AnimatedOrderCard({
    super.key,
    required this.order,
    required this.userName,
    this.showCompleteButton = false,
    this.onComplete,
    this.isProcessing = false,
    required this.animationKey,
  });

  @override
  State<AnimatedOrderCard> createState() => _AnimatedOrderCardState();
}

class _AnimatedOrderCardState extends State<AnimatedOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _animateAndComplete() async {
    if (_isAnimating || widget.onComplete == null) return;

    setState(() {
      _isAnimating = true;
    });

    // Start animation immediately
    _controller.forward();

    // Call the completion callback immediately (don't wait for animation)
    // This makes the Firestore update happen instantly while animation plays
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = (widget.order['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final orderStatus = widget.order['orderStatus'] ?? 'active';
    final paymentStatus = widget.order['paymentStatus'] ?? 'pending';
    final createdAt = widget.order['createdAt'];
    final items = widget.order['items'] as List<dynamic>? ?? [];
    final itemsCount = items.length;
    final isGroupOrder = widget.order['isGroupOrder'] ?? false;
    final groupName = widget.order['groupName'];

    // Format date
    String formattedDate = 'Just now';
    String formattedTime = '';
    if (createdAt != null && createdAt is Timestamp) {
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
        formattedDate = DateFormat('MMM d, y').format(date);
      }
      formattedTime = DateFormat('HH:mm').format(date);
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

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          margin: const EdgeInsets.only(bottom: AdminConstants.defaultPadding),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(AdminConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.userName,
                                style: AdminTheme.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AdminTheme.textPrimaryColor,
                                ),
                              ),
                              if (isGroupOrder) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AdminTheme.secondaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.group,
                                        size: 12,
                                        color: AdminTheme.secondaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        groupName ?? 'Group Order',
                                        style: AdminTheme.bodySmall.copyWith(
                                          color: AdminTheme.secondaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$itemsCount item${itemsCount != 1 ? 's' : ''} • $formattedDate${formattedTime.isNotEmpty ? ' • $formattedTime' : ''}',
                            style: AdminTheme.bodySmall.copyWith(
                              color: AdminTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Amount
                    Text(
                      '₹${totalAmount.toStringAsFixed(2)}',
                      style: AdminTheme.heading3.copyWith(
                        color: AdminTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Items List
                if (items.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AdminConstants.smallPadding),
                    decoration: BoxDecoration(
                      color: AdminTheme.cardColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ...items.take(3).map<Widget>((item) {
                          final itemData = item as Map<String, dynamic>;
                          final itemName = itemData['name'] ?? 'Unknown Item';
                          final quantity = itemData['quantity'] ?? 1;
                          final price = (itemData['price'] as num?)?.toDouble() ?? 0.0;
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '$itemName × $quantity',
                                    style: AdminTheme.bodyMedium.copyWith(
                                      color: AdminTheme.textPrimaryColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹${(price * quantity).toStringAsFixed(2)}',
                                  style: AdminTheme.bodyMedium.copyWith(
                                    color: AdminTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (items.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'and ${items.length - 3} more item${items.length - 3 != 1 ? 's' : ''}',
                              style: AdminTheme.bodySmall.copyWith(
                                color: AdminTheme.textSecondaryColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Status Row
                Row(
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            orderStatus.toString().toUpperCase(),
                            style: AdminTheme.bodySmall.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Payment Status
                    if (paymentStatus.toString().toLowerCase() == 'paid') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AdminTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.payment,
                              size: 14,
                              color: AdminTheme.successColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'PAID',
                              style: AdminTheme.bodySmall.copyWith(
                                color: AdminTheme.successColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Complete Button (if applicable)
                    if (widget.showCompleteButton && widget.onComplete != null)
                      ElevatedButton.icon(
                        onPressed: _isAnimating || widget.isProcessing
                            ? null
                            : _animateAndComplete,
                        icon: widget.isProcessing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.check, size: 18),
                        label: Text(
                          _isAnimating
                              ? 'Marking...'
                              : widget.isProcessing
                                  ? 'Processing...'
                                  : 'Mark as Completed',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.successColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

