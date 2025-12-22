import 'package:flutter/material.dart';
import 'package:testmaker/screens/onboarding/decorative_elements.dart';
import 'package:testmaker/screens/onboarding/onboarding_content.dart';
import 'package:testmaker/utils/responsive_sizer.dart';
import 'package:testmaker/widgets/parallax_layer.dart';

/// ********************************************************************
/// OnboardingPage
/// ********************************************************************
///
/// Individual onboarding page with parallax animations and content.
/// Displays a single screen from the onboarding flow with:
/// - Animated gradient background
/// - Parallax-scrolling visual elements
/// - Feature icon(s) with smooth animations
/// - Headline and subheadline text
/// - Staggered fade-in animations
///
/// Follows Apple's Human Interface Guidelines with:
/// - Generous white space and padding
/// - Clear visual hierarchy
/// - Smooth, physics-based animations
/// - Readable typography with SF Pro font
///
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    required this.content,
    required this.pageOffset,
    required this.pageIndex,
    super.key,
  });

  /// The content data for this page
  final OnboardingContent content;

  /// The current page offset from PageController (for parallax)
  final double pageOffset;

  /// The index of this page in the PageView
  final int pageIndex;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late AnimationController _entryAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Special animation for flashcard flip (page 2 - index 2)
  late AnimationController _flipAnimationController;
  late Animation<double> _flipAnimation;

  // Special animation for logo breathing effect (page 0)
  late AnimationController _logoBreathingController;
  late Animation<double> _logoBreathingAnimation;

  @override
  void initState() {
    super.initState();
    // [_OnboardingPageState.initState]
    // Initialize entry animations for when page first appears
    _entryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Fade animation: 0.0 (invisible) to 1.0 (fully visible)
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _entryAnimationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Slide animation: slide up from below with spring curve
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryAnimationController,
        // Use elastic curve for more dynamic feel
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Flashcard flip animation (continuous loop for page 2)
    _flipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _flipAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Logo breathing animation (slower for better performance)
    _logoBreathingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _logoBreathingAnimation = Tween<double>(
      begin: 1,
      end: 1.06, // Reduced from 1.08 for subtler effect
    ).animate(
      CurvedAnimation(
        parent: _logoBreathingController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the entry animation
    _entryAnimationController.forward();

    // Start flip animation for flashcard page (index 2)
    if (widget.pageIndex == 2) {
      // Delay and then start repeating flip
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          _flipAnimationController.repeat(reverse: true);
        }
      });
    }

    // Start breathing animation for welcome page (index 0)
    // Only start if this is the active page
    if (widget.pageIndex == 0) {
      // Delay and then start repeating breathing effect
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _logoBreathingController.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void didUpdateWidget(OnboardingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // [didUpdateWidget] Performance optimization
    // Stop animations when page is off-screen to save resources
    final pageOffsetDiff = (widget.pageOffset - widget.pageIndex).abs();
    
    // Pause animations when page is far from view
    if (pageOffsetDiff > 1.5) {
      if (_logoBreathingController.isAnimating) {
        _logoBreathingController.stop();
      }
      if (_flipAnimationController.isAnimating) {
        _flipAnimationController.stop();
      }
    } else {
      // Resume animations when page comes back into view
      if (widget.pageIndex == 0 && !_logoBreathingController.isAnimating) {
        _logoBreathingController.repeat(reverse: true);
      }
      if (widget.pageIndex == 2 && !_flipAnimationController.isAnimating) {
        _flipAnimationController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _entryAnimationController.dispose();
    _flipAnimationController.dispose();
    _logoBreathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final size = MediaQuery.of(context).size;

    return Container(
      // [OnboardingPage.build] - Background gradient with parallax
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.content.gradientColors,
        ),
      ),
      child: Stack(
        children: <Widget>[
          // Decorative background elements with parallax
          // Wrapped in RepaintBoundary to isolate repaints
          RepaintBoundary(
            child: DecorativeElements(
              pageOffset: widget.pageOffset,
              pageIndex: widget.pageIndex,
              primaryColor: widget.content.iconColor,
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveSizer.horizontalPadding(context) * 2,
                vertical: ResponsiveSizer.sectionSpacing(context) * 1.5,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Spacer(),
                  // Icon section with parallax and animations
                  _buildIconSection(size, context),
                  SizedBox(height: ResponsiveSizer.sectionSpacing(context) * 2),
                  // Text content with parallax
                  _buildTextContent(textTheme, context),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// [_buildIconSection]
  ///
  /// Builds the icon/visual section with parallax animations.
  /// For screens with secondary icons (like PDF → Quiz), shows both
  /// with an arrow between them. Otherwise shows a single large icon.
  /// Special case: Page 2 (flashcards) gets a flip animation.
  /// Special case: Page 0 (welcome) uses app logo with animations.
  Widget _buildIconSection(Size size, BuildContext context) {
    final hasSecondaryIcon = widget.content.secondaryIcon != null;
    final isFlashcardPage = widget.pageIndex == 2;
    final useImage = widget.content.useImageInsteadOfIcon;
    
    // Responsive icon sizes
    final iconSize = ResponsiveSizer.iconSize(context, multiplier: 4);
    final largeIconSize = ResponsiveSizer.iconSize(context, multiplier: 6);
    final arrowSize = ResponsiveSizer.iconSize(context, multiplier: 2);
    final spacing = ResponsiveSizer.spacing(context, multiplier: 3);

    // Special case: Use logo image for welcome screen
    if (useImage && widget.content.imagePath != null) {
      return ParallaxScaleLayer(
        pageOffset: widget.pageOffset,
        currentPageIndex: widget.pageIndex,
        parallaxSpeed: 0.75,
        scaleSpeed: 0.3,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildAnimatedLogo(
            widget.content.imagePath!,
            widget.content.iconColor,
            context: context,
          ),
        ),
      );
    } else if (hasSecondaryIcon) {
      // [_buildIconSection] - Show transformation visual (PDF → Quiz)
      return ParallaxScaleLayer(
        pageOffset: widget.pageOffset,
        currentPageIndex: widget.pageIndex,
        parallaxSpeed: 0.75,
        scaleSpeed: 0.15,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Primary icon (e.g., PDF)
              _buildAnimatedIcon(
                widget.content.icon,
                widget.content.iconColor,
                size: iconSize,
                context: context,
              ),
              SizedBox(width: spacing),
              // Arrow indicating transformation
              Icon(
                Icons.arrow_forward_rounded,
                size: arrowSize,
                color: widget.content.iconColor.withValues(alpha: 0.6),
              ),
              SizedBox(width: spacing),
              // Secondary icon (e.g., Quiz)
              _buildAnimatedIcon(
                widget.content.secondaryIcon!,
                widget.content.iconColor,
                size: iconSize,
                context: context,
              ),
            ],
          ),
        ),
      );
    } else if (isFlashcardPage) {
      // [_buildIconSection] - Show flashcard with flip animation
      // Capture context to avoid shadowing in AnimatedBuilder
      final buildContext = context;
      
      return ParallaxScaleLayer(
        pageOffset: widget.pageOffset,
        currentPageIndex: widget.pageIndex,
        parallaxSpeed: 0.75,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              // Calculate rotation angle (0 to pi for flip)
              final angle = _flipAnimation.value * 3.14159;
              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateY(angle);

              return Transform(
                transform: transform,
                alignment: Alignment.center,
                child: _buildFlashcardIcon(
                  widget.content.iconColor,
                  context: buildContext,
                  isFront: angle < 3.14159 / 2,
                ),
              );
            },
          ),
        ),
      );
    } else {
      // [_buildIconSection] - Show single large icon
      return ParallaxScaleLayer(
        pageOffset: widget.pageOffset,
        currentPageIndex: widget.pageIndex,
        parallaxSpeed: 0.75,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildAnimatedIcon(
            widget.content.icon,
            widget.content.iconColor,
            size: largeIconSize,
            context: context,
          ),
        ),
      );
    }
  }

  /// [_buildAnimatedIcon]
  ///
  /// Builds a single icon with container styling, shadow, and animations.
  /// Optimized with simplified shadow for better performance.
  Widget _buildAnimatedIcon(
    IconData icon,
    Color color, {
    required double size,
    required BuildContext context,
  }) {
    final borderRadius = ResponsiveSizer.borderRadius(context, multiplier: 1.5);
    
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.all(size * 0.25),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            // Single optimized shadow
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: size,
          color: color,
        ),
      ),
    );
  }

  /// [_buildAnimatedLogo]
  ///
  /// Builds the app logo with animations for the welcome screen.
  /// Optimized with RepaintBoundary and cached image.
  Widget _buildAnimatedLogo(
    String imagePath,
    Color color, {
    required BuildContext context,
  }) {
    final logoSize = ResponsiveSizer.scaleWidth(context, 140);
    final borderRadius = ResponsiveSizer.borderRadius(context, multiplier: 2);
    
    return AnimatedBuilder(
      animation: _logoBreathingAnimation,
      builder: (context, child) {
        // Simplified glow calculation for better performance
        final glowIntensity = (_logoBreathingAnimation.value - 1) * 4;
        
        return Transform.scale(
          scale: _logoBreathingAnimation.value,
          child: Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                // Single optimized shadow
                BoxShadow(
                  color: color.withValues(alpha: 0.25 + (glowIntensity * 0.08)),
                  blurRadius: 20 + (glowIntensity * 1.5),
                  spreadRadius: 2 + (glowIntensity * 0.5),
                ),
              ],
            ),
            padding: EdgeInsets.all(ResponsiveSizer.cardPadding(context)),
            child: child, // Reuse child from builder
          ),
        );
      },
      // Cache the image widget (child parameter)
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius * 0.7),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            // Enable caching
            cacheWidth: 300,
            cacheHeight: 300,
          ),
        ),
      ),
    );
  }

  /// [_buildFlashcardIcon]
  ///
  /// Builds a flashcard-style card that shows different content
  /// on front and back for the flip animation on page 2.
  /// Optimized with simplified shadow.
  Widget _buildFlashcardIcon(
    Color color, {
    required bool isFront,
    required BuildContext context,
  }) {
    final cardWidth = ResponsiveSizer.scaleWidth(context, 160);
    final cardHeight = ResponsiveSizer.scaleHeight(context, 200);
    final padding = ResponsiveSizer.cardPadding(context);
    final borderRadius = ResponsiveSizer.borderRadius(context, multiplier: 1.5);
    final iconSize = ResponsiveSizer.iconSize(context, multiplier: 3);
    final spacing = ResponsiveSizer.spacing(context, multiplier: 1.5);
    
    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          // Single optimized shadow
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            isFront ? Icons.question_mark_rounded : Icons.lightbulb_rounded,
            size: iconSize,
            color: color,
          ),
          SizedBox(height: spacing),
          Container(
            height: 3,
            width: ResponsiveSizer.scaleWidth(context, 40),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: ResponsiveSizer.spacing(context)),
          Container(
            height: 3,
            width: ResponsiveSizer.scaleWidth(context, 60),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  /// [_buildTextContent]
  ///
  /// Builds the headline and subheadline text with parallax and animations.
  /// Text slides up and fades in with a slight delay for polished feel.
  Widget _buildTextContent(TextTheme textTheme, BuildContext context) {
    final fontMultiplier = ResponsiveSizer.fontSizeMultiplier(context);
    final headlineSize = 32 * fontMultiplier;
    final bodySize = 18 * fontMultiplier;
    final spacing = ResponsiveSizer.spacing(context, multiplier: 2);
    
    return ParallaxLayer(
      pageOffset: widget.pageOffset,
      currentPageIndex: widget.pageIndex,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: <Widget>[
              // Headline
              Text(
                widget.content.headline,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: headlineSize,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing),
              // Subheadline
              Text(
                widget.content.subheadline,
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: bodySize,
                  height: 1.5,
                  color: textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
