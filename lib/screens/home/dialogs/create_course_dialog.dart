import 'package:flutter/material.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// A beautifully designed dialog for creating a new course.
///
/// This custom dialog follows Apple's Human Interface Guidelines:
///  - Clean, minimal design with generous spacing
///  - Soft rounded corners and subtle shadows
///  - Smooth animations and transitions
///  - Clear visual hierarchy and focus states
class CreateCourseDialog extends StatefulWidget {
  const CreateCourseDialog({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  State<CreateCourseDialog> createState() => _CreateCourseDialogState();
}

class _CreateCourseDialogState extends State<CreateCourseDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
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
    final textTheme = theme.textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveSizer.dialogMaxWidthFromConstraints(
                    constraints,
                  ),
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    ResponsiveSizer.borderRadiusFromConstraints(
                      constraints,
                      multiplier: 1.4,
                    ),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Header section with icon
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        ResponsiveSizer.horizontalPaddingFromConstraints(
                              constraints,
                            ) *
                            1.4,
                        ResponsiveSizer.verticalPaddingFromConstraints(
                              constraints,
                            ) *
                            1.3,
                        ResponsiveSizer.horizontalPaddingFromConstraints(
                              constraints,
                            ) *
                            1.4,
                        ResponsiveSizer.verticalPaddingFromConstraints(
                          constraints,
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          // Icon container
                          Container(
                            width: ResponsiveSizer.scaleWidthFromConstraints(
                              constraints,
                              64,
                            ),
                            height: ResponsiveSizer.scaleWidthFromConstraints(
                              constraints,
                              64,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                ResponsiveSizer.borderRadiusFromConstraints(
                                  constraints,
                                  multiplier: 1.5,
                                ),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary
                                      .withValues(alpha: 0.8),
                                ],
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add,
                              color: theme.colorScheme.onPrimary,
                              size: ResponsiveSizer.iconSizeFromConstraints(
                                constraints,
                                multiplier: 1.6,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveSizer.spacingFromConstraints(
                              constraints,
                              multiplier: 2.5,
                            ),
                          ),
                          // Title
                          Text(
                            'New Course',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: ResponsiveSizer.spacingFromConstraints(
                              constraints,
                            ),
                          ),
                          // Subtitle
                          Text(
                            'Give your course a name to get started',
                            style: textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // Input section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Focus(
                        onFocusChange: (bool hasFocus) {
                          setState(() {
                            _isFocused = hasFocus;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isFocused
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                              width: _isFocused ? 2 : 1,
                            ),
                            color: _isFocused
                                ? theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.1)
                                : theme.colorScheme.surfaceContainerHighest,
                          ),
                          child: TextField(
                            controller: widget.controller,
                            autofocus: true,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g., Math 101, History, Science',
                              hintStyle: textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                            onSubmitted: (String value) {
                              if (value.trim().isNotEmpty) {
                                Navigator.of(context).pop(value.trim());
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 3.5,
                      ),
                    ),
                    // Action buttons
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 3.5,
                        ),
                        0,
                        ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 3.5,
                        ),
                        ResponsiveSizer.spacingFromConstraints(
                          constraints,
                          multiplier: 3.5,
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          // Cancel button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Create button
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: () {
                                if (widget.controller.text.trim().isNotEmpty) {
                                  Navigator.of(context)
                                      .pop(widget.controller.text.trim());
                                }
                              },
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                elevation: 0,
                              ),
                              child: Text(
                                'Create',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
