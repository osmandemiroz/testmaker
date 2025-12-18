import 'package:flutter/material.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds an animated action button for the expandable PDF section.
class AnimatedActionButton extends StatelessWidget {
  const AnimatedActionButton({
    required this.theme,
    required this.textTheme,
    required this.constraints,
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  final ThemeData theme;
  final TextTheme textTheme;
  final BoxConstraints constraints;
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              height: ResponsiveSizer.buttonHeightFromConstraints(
                    constraints,
                  ) *
                  0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  ResponsiveSizer.borderRadiusFromConstraints(
                    constraints,
                    multiplier: 0.75,
                  ),
                ),
                border: Border.all(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    theme.colorScheme.surfaceContainerLow,
                    theme.colorScheme.surfaceContainerLow
                        .withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading ? null : onPressed,
                  borderRadius: BorderRadius.circular(
                    ResponsiveSizer.borderRadiusFromConstraints(
                      constraints,
                      multiplier: 0.75,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 2,
                      ),
                      vertical: ResponsiveSizer.spacingFromConstraints(
                        constraints,
                        multiplier: 0.75,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (isLoading)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          )
                        else
                          Icon(
                            icon,
                            size: ResponsiveSizer.iconSizeFromConstraints(
                              constraints,
                              multiplier: 0.85,
                            ),
                            color: theme.colorScheme.primary,
                          ),
                        SizedBox(
                          width: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            label,
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
