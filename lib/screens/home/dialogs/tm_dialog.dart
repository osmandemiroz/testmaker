import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// A modern, glassmorphism-inspired base dialog for the application.
///
/// Features:
/// - Backdrop blur effect
/// - Semi-transparent glass aesthetic
/// - Responsive sizing
/// - Standardized header and actions
class TMDialog extends StatefulWidget {
  const TMDialog({
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.actions,
    this.maxWidth,
    this.contentPadding,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? icon;
  final List<Widget>? actions;
  final double? maxWidth;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<TMDialog> createState() => _TMDialogState();
}

class _TMDialogState extends State<TMDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Get keyboard height to adjust dialog positioning
    // This ensures the "Add Content" button remains visible when keyboard appears
    final viewInsets = MediaQuery.of(context).viewInsets;
    final keyboardHeight = viewInsets.bottom;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            // Adjust insetPadding based on keyboard height
            // When keyboard appears, reduce bottom padding to keep actions visible
            insetPadding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: keyboardHeight > 0 ? 8 : 24,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = widget.maxWidth ??
                    ResponsiveSizer.dialogMaxWidthFromConstraints(constraints);

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                      // Constrain max height to ensure dialog fits above keyboard
                      maxHeight: MediaQuery.of(context).size.height -
                          viewInsets.top -
                          viewInsets.bottom -
                          48, // Account for dialog padding
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.1),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(context, constraints),
                          Flexible(
                            child: SingleChildScrollView(
                              padding: widget.contentPadding ??
                                  const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              child: widget.child,
                            ),
                          ),
                          if (widget.actions != null)
                            _buildActions(context, constraints),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BoxConstraints constraints) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Column(
        children: [
          if (widget.icon != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: widget.icon,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.subtitle!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, BoxConstraints constraints) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: widget.actions!.map((action) {
          final isLast = action == widget.actions!.last;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 12),
              child: action,
            ),
          );
        }).toList(),
      ),
    );
  }
}
