import 'package:flutter/material.dart';
import 'package:testmaker/screens/auth/auth_screen.dart';
import 'package:testmaker/screens/onboarding/onboarding_content.dart';
import 'package:testmaker/screens/onboarding/onboarding_page.dart';
import 'package:testmaker/services/onboarding_service.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// ********************************************************************
/// OnboardingScreen
/// ********************************************************************
///
/// Main onboarding screen with PageView and navigation controls.
/// Displays a 4-page onboarding flow that introduces users to
/// TestMaker's AI-powered quiz and flashcard generation features.
///
/// Features:
/// - Horizontal PageView with parallax animations
/// - iOS-style page indicators (dots)
/// - Skip button (top-right, always visible)
/// - Next button (bottom, changes to "Get Started" on final page)
/// - Smooth transitions between pages
/// - Marks onboarding as complete when finished
///
/// Follows Apple's Human Interface Guidelines:
/// - Clear navigation with skip option
/// - Progressive disclosure of features
/// - Smooth, physics-based page transitions
/// - Minimal, focused design
///
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late List<OnboardingContent> _pages;
  double _currentPage = 0;
  late AnimationController _skipButtonAnimationController;
  late Animation<double> _skipButtonFadeAnimation;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // [_OnboardingScreenState.initState]
    // Initialize page controller and listen for page changes
    _pageController = PageController()
      ..addListener(() {
        setState(() {
          _currentPage = _pageController.page ?? 0.0;
        });
        // Start pulse animation when reaching final page
        if (_currentPage >= _pages.length - 1) {
          if (!_pulseAnimationController.isAnimating) {
            _pulseAnimationController.repeat(reverse: true);
          }
        } else {
          if (_pulseAnimationController.isAnimating) {
            _pulseAnimationController.stop();
          }
        }
      });

    // Initialize skip button fade-in animation
    _skipButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _skipButtonFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _skipButtonAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Initialize pulse animation for "Get Started" button
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start skip button animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _skipButtonAnimationController.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // [_OnboardingScreenState.didChangeDependencies]
    // Load pages here to have access to BuildContext for theme
    _pages = OnboardingContent.getOnboardingPages(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _skipButtonAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  /// [_completeOnboarding]
  ///
  /// Marks onboarding as complete and navigates to the auth screen.
  /// Called when user taps "Get Started" on the final page or "Skip".
  Future<void> _completeOnboarding() async {
    await OnboardingService.markOnboardingComplete();

    if (!mounted) return;

    // Navigate to auth screen with fade transition
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  /// [_nextPage]
  ///
  /// Navigates to the next page with smooth animation.
  /// If on the last page, completes onboarding instead.
  void _nextPage() {
    final currentPageIndex = _currentPage.round();
    if (currentPageIndex < _pages.length - 1) {
      // [_nextPage] - Go to next page
      _pageController.animateToPage(
        currentPageIndex + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // [_nextPage] - Complete onboarding (last page)
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPageIndex = _currentPage.round();
    final isLastPage = currentPageIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: <Widget>[
          // Main PageView with onboarding pages
          // Optimize with viewportFraction for better performance
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            // Reduce off-screen rendering
            physics: const PageScrollPhysics(),
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: OnboardingPage(
                  content: _pages[index],
                  pageOffset: _currentPage,
                  pageIndex: index,
                ),
              );
            },
          ),

          // Skip button (top-right)
          Positioned(
            top: MediaQuery.of(context).padding.top +
                ResponsiveSizer.spacing(context, multiplier: 2),
            right: ResponsiveSizer.horizontalPadding(context) * 1.5,
            child: FadeTransition(
              opacity: _skipButtonFadeAnimation,
              child: TextButton(
                onPressed: _completeOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveSizer.horizontalPadding(context) * 1.25,
                    vertical: ResponsiveSizer.spacing(context, multiplier: 1.5),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16 * ResponsiveSizer.fontSizeMultiplier(context),
                  ),
                ),
              ),
            ),
          ),

          // Bottom controls: Page indicators and Next button
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom +
                ResponsiveSizer.sectionSpacing(context),
            child: Column(
              children: <Widget>[
                // Page indicators
                _buildPageIndicators(theme),
                SizedBox(height: ResponsiveSizer.sectionSpacing(context)),
                // Next / Get Started button
                _buildNextButton(theme, isLastPage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// [_buildPageIndicators]
  ///
  /// Builds iOS-style page indicators (dots) at the bottom.
  /// Active dot is larger and has full opacity, inactive dots are smaller.
  Widget _buildPageIndicators(ThemeData theme) {
    final dotSize = ResponsiveSizer.spacing(context);
    final activeDotWidth = dotSize * 3;
    final spacing = ResponsiveSizer.spacing(context) / 2;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final isActive = index == _currentPage.round();
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: spacing),
          width: isActive ? activeDotWidth : dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }

  /// [_buildNextButton]
  ///
  /// Builds the Next or Get Started button at the bottom.
  /// Changes text and style on the last page to emphasize completion.
  /// Adds a subtle pulse animation to "Get Started" button.
  Widget _buildNextButton(ThemeData theme, bool isLastPage) {
    final fontSize = 18 * ResponsiveSizer.fontSizeMultiplier(context);
    final iconSize = ResponsiveSizer.iconSize(context);
    final buttonHeight = ResponsiveSizer.buttonHeight(context) * 1.3;
    final borderRadius = ResponsiveSizer.borderRadius(context, multiplier: 1.3);
    final horizontalPadding = ResponsiveSizer.horizontalPadding(context) * 2;
    
    final buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          isLastPage ? 'Get Started' : 'Next',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
          ),
        ),
        if (!isLastPage) ...[
          SizedBox(width: ResponsiveSizer.spacing(context)),
          Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: iconSize,
          ),
        ],
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: isLastPage
            ? AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor:
                            theme.colorScheme.primary.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                      ),
                      child: buttonContent,
                    ),
                  );
                },
              )
            : ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                child: buttonContent,
              ),
      ),
    );
  }
}
