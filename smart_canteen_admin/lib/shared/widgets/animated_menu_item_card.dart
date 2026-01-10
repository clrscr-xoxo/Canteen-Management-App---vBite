import 'package:flutter/material.dart';
import '../../core/theme/admin_theme.dart';
import '../../core/constants/admin_constants.dart';

/// Animated Menu Item Card that can fade out and slide to the right
class AnimatedMenuItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onToggleAvailability;
  final bool isProcessing;
  final String animationKey;

  const AnimatedMenuItemCard({
    super.key,
    required this.item,
    this.onToggleAvailability,
    this.isProcessing = false,
    required this.animationKey,
  });

  @override
  State<AnimatedMenuItemCard> createState() => _AnimatedMenuItemCardState();
}

class _AnimatedMenuItemCardState extends State<AnimatedMenuItemCard>
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

  Future<void> _animateAndToggle() async {
    if (_isAnimating || widget.onToggleAvailability == null) return;

    setState(() {
      _isAnimating = true;
    });

    // Animate out, perform the action, then animate back to avoid leaving a gap
    await _controller.forward();

    // Call the toggle callback after animation
    widget.onToggleAvailability!.call();

    // Bring the card back into place so layout does not retain empty space
    if (mounted) {
      await _controller.reverse();
    }

    if (mounted) {
      setState(() {
        _isAnimating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.item['name'] ?? 'Unknown Item';
    final description = widget.item['description'] ?? '';
    final price = (widget.item['price'] as num?)?.toDouble() ?? 0.0;
    final imageUrl = widget.item['imageUrl'] ?? '';
    final isAvailable = widget.item['isAvailable'] ?? true;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: AdminTheme.cardColor,
          elevation: AdminConstants.cardElevation,
          child: Padding(
            padding: const EdgeInsets.all(AdminConstants.defaultPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(AdminConstants.borderRadius),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: AdminTheme.textHintColor.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.restaurant,
                                size: 48,
                                color: AdminTheme.textHintColor,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 120,
                              height: 120,
                              color: AdminTheme.textHintColor.withValues(alpha: 0.1),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 120,
                          height: 120,
                          color: AdminTheme.textHintColor.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.restaurant,
                            size: 48,
                            color: AdminTheme.textHintColor,
                          ),
                        ),
                ),
                const SizedBox(width: 16),

                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: AdminTheme.heading2.copyWith(
                                color: AdminTheme.textPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Availability Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? AdminTheme.successColor.withValues(alpha: 0.1)
                                  : AdminTheme.errorColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AdminConstants.borderRadius,
                              ),
                            ),
                            child: Text(
                              isAvailable ? 'Available' : 'Sold Out',
                              style: AdminTheme.bodySmall.copyWith(
                                color: isAvailable
                                    ? AdminTheme.successColor
                                    : AdminTheme.errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: AdminTheme.bodyMedium.copyWith(
                          color: AdminTheme.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${price.toStringAsFixed(2)}',
                            style: AdminTheme.heading3.copyWith(
                              color: AdminTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Toggle Availability Button
                          ElevatedButton.icon(
                            onPressed: _isAnimating || widget.isProcessing
                                ? null
                                : _animateAndToggle,
                            icon: _isAnimating
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    isAvailable ? Icons.block : Icons.check_circle,
                                    size: 18,
                                  ),
                            label: Text(
                              _isAnimating
                                  ? 'Updating...'
                                  : widget.isProcessing
                                      ? 'Processing...'
                                      : isAvailable
                                          ? 'Mark Sold Out'
                                          : 'Mark Available',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAvailable
                                  ? AdminTheme.errorColor
                                  : AdminTheme.successColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

