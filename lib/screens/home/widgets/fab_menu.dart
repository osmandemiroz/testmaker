import 'package:flutter/material.dart';
import 'package:testmaker/controllers/home_controller.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// Builds the floating action button with dropdown menu for upload options.
///
/// This FAB appears when a course is selected and provides quick access to
/// upload PDFs, quizzes, and flashcards. The menu expands with smooth animations
/// following Apple's Human Interface Guidelines with a modern, visually appealing design.
class FabMenu extends StatelessWidget {
  const FabMenu({
    required this.controller,
    required this.theme,
    required this.textTheme,
    required this.onUploadFlashcards,
    required this.onUploadQuiz,
    required this.onUploadPdf,
    super.key,
  });

  final HomeController controller;
  final ThemeData theme;
  final TextTheme textTheme;
  final VoidCallback? onUploadFlashcards;
  final VoidCallback? onUploadQuiz;
  final VoidCallback? onUploadPdf;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        // Expanded menu items with smooth slide-up and fade animations
        if (controller.isFabExpanded) ...<Widget>[
          _AnimatedFabMenuItem(
            controller: controller,
            theme: theme,
            textTheme: textTheme,
            icon: Icons.style_outlined,
            label: 'Upload Flashcards',
            isLoading: controller.isFlashcardLoading,
            delay: 0,
            onTap: controller.selectedCourse != null
                ? () {
                    controller.closeFab();
                    onUploadFlashcards?.call();
                  }
                : null,
          ),
          SizedBox(
            height: ResponsiveSizer.spacing(context, multiplier: 1.5),
          ),
          _AnimatedFabMenuItem(
            controller: controller,
            theme: theme,
            textTheme: textTheme,
            icon: Icons.upload_file_outlined,
            label: 'Upload Quiz',
            isLoading: controller.isCustomLoading,
            delay: 50,
            onTap: controller.selectedCourse != null
                ? () {
                    controller.closeFab();
                    onUploadQuiz?.call();
                  }
                : null,
          ),
          SizedBox(
            height: ResponsiveSizer.spacing(context, multiplier: 1.5),
          ),
          _AnimatedFabMenuItem(
            controller: controller,
            theme: theme,
            textTheme: textTheme,
            icon: Icons.picture_as_pdf_outlined,
            label: 'Upload PDF',
            isLoading: controller.isPdfLoading,
            delay: 100,
            onTap: controller.selectedCourse != null
                ? () {
                    controller.closeFab();
                    onUploadPdf?.call();
                  }
                : null,
          ),
          SizedBox(
            height: ResponsiveSizer.spacing(context, multiplier: 2),
          ),
        ],
        // Main FAB button with smooth icon transformation
        FloatingActionButton(
          onPressed: controller.toggleFab,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: controller.isFabExpanded ? 8 : 4,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return RotationTransition(
                turns: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              controller.isFabExpanded ? Icons.close : Icons.add,
              key: ValueKey<bool>(controller.isFabExpanded),
              size: ResponsiveSizer.iconSize(context, multiplier: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

/// Builds an animated menu item for the FAB dropdown with staggered animation.
class _AnimatedFabMenuItem extends StatelessWidget {
  const _AnimatedFabMenuItem({
    required this.controller,
    required this.theme,
    required this.textTheme,
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.delay,
    required this.onTap,
  });

  final HomeController controller;
  final ThemeData theme;
  final TextTheme textTheme;
  final IconData icon;
  final String label;
  final bool isLoading;
  final int delay;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: controller.isFabExpanded ? 1.0 : 0.0,
      ),
      duration: Duration(milliseconds: 300 + delay),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: _FabMenuItem(
              theme: theme,
              textTheme: textTheme,
              icon: icon,
              label: label,
              isLoading: isLoading,
              onTap: onTap,
            ),
          ),
        );
      },
    );
  }
}

/// Builds a menu item for the FAB dropdown.
class _FabMenuItem extends StatelessWidget {
  const _FabMenuItem({
    required this.theme,
    required this.textTheme,
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final ThemeData theme;
  final TextTheme textTheme;
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(
            ResponsiveSizer.borderRadiusFromConstraints(
              constraints,
              multiplier: 2.33,
            ),
          ),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(
              ResponsiveSizer.borderRadiusFromConstraints(
                constraints,
                multiplier: 2.33,
              ),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveSizer.spacingFromConstraints(
                  constraints,
                  multiplier: 2.5,
                ),
                vertical: ResponsiveSizer.spacingFromConstraints(
                  constraints,
                  multiplier: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (isLoading)
                    SizedBox(
                      width: ResponsiveSizer.iconSizeFromConstraints(
                        constraints,
                      ),
                      height: ResponsiveSizer.iconSizeFromConstraints(
                        constraints,
                      ),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
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
                      ),
                      color: theme.colorScheme.primary,
                    ),
                  SizedBox(
                    width: ResponsiveSizer.spacingFromConstraints(
                      constraints,
                      multiplier: 1.5,
                    ),
                  ),
                  Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
