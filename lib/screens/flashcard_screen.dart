import 'package:flutter/material.dart';
import 'package:testmaker/controllers/flashcard_controller.dart';
import 'package:testmaker/models/flashcard.dart';
import 'package:testmaker/utils/responsive_sizer.dart';
import 'package:testmaker/widgets/quiz_progress_bar.dart';

/// ********************************************************************
/// FlashcardScreen
/// ********************************************************************
///
/// Displays flashcards one at a time with flip animation.
/// The layout is responsive and keeps a focused, card-based design that
/// mirrors Apple's Human Interface Guidelines (clear hierarchy, ample
/// padding, and smooth motion).
///
class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({
    required this.flashcards,
    super.key,
  });

  final List<Flashcard> flashcards;

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  late final FlashcardController _controller;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _controller = FlashcardController(widget.flashcards);
    _controller.addListener(_onControllerChanged);
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.easeInOut,
      ),
    );
    _pageController = PageController(initialPage: _controller.currentIndex);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _flipController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
      // Sync animation controller with the current card's flip state
      final isFlipped = _controller.isCurrentCardFlipped;
      if (isFlipped) {
        _flipController.value = 1.0;
      } else {
        _flipController.value = 0.0;
      }
    }
  }

  void _flipCard() {
    if (_flipController.isAnimating) {
      return;
    }

    final currentFlipped = _controller.isCurrentCardFlipped;
    _controller.flipCurrentCard();

    if (!currentFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _onPageChanged(int index) {
    _controller.goToCard(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Padding(
              padding: ResponsiveSizer.paddingFromConstraints(constraints),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  QuizProgressBar(
                    currentIndex: _controller.currentIndex,
                    total: _controller.totalCards,
                  ),
                  SizedBox(
                    height: ResponsiveSizer.spacingFromConstraints(
                      constraints,
                      multiplier: 2,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'Card ${_controller.currentIndex + 1}',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_controller.currentIndex + 1} of ${_controller.totalCards}',
                        style: textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ResponsiveSizer.spacingFromConstraints(
                      constraints,
                      multiplier: 2,
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        // Swipeable card container using PageView
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          itemCount: widget.flashcards.length,
                          itemBuilder: (BuildContext context, int index) {
                            final isCardFlipped =
                                _controller.isCardFlipped(index);
                            final isCurrentCard =
                                index == _controller.currentIndex;

                            return GestureDetector(
                              onTap: isCurrentCard ? _flipCard : null,
                              child: AnimatedBuilder(
                                animation: isCurrentCard
                                    ? _flipAnimation
                                    : const AlwaysStoppedAnimation(0),
                                builder: (BuildContext context, Widget? child) {
                                  // For current card, use animation value; for others, use stored state
                                  final animationValue = isCurrentCard &&
                                          _flipController.isAnimating
                                      ? _flipAnimation.value
                                      : (isCardFlipped ? 1.0 : 0.0);
                                  final angle = animationValue *
                                      3.14159; // π radians = 180 degrees
                                  final isFrontVisible =
                                      angle < 1.5708; // π/2 = 90 degrees

                                  return Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001) // Perspective
                                      ..rotateY(angle),
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: ResponsiveSizer
                                            .horizontalPaddingFromConstraints(
                                          constraints,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(
                                          ResponsiveSizer
                                              .borderRadiusFromConstraints(
                                            constraints,
                                            multiplier: 2,
                                          ),
                                        ),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.04,
                                            ),
                                            blurRadius: 26,
                                            offset: const Offset(0, 18),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(
                                        ResponsiveSizer
                                                .cardPaddingFromConstraints(
                                              constraints,
                                            ) *
                                            1.2,
                                      ),
                                      child: isFrontVisible
                                          ? _buildFront(
                                              theme,
                                              textTheme,
                                              constraints,
                                              index,
                                            )
                                          : Transform(
                                              alignment: Alignment.center,
                                              transform: Matrix4.identity()
                                                ..rotateY(3.14159),
                                              child: _buildBack(
                                                theme,
                                                textTheme,
                                                constraints,
                                                index,
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        // Left edge indicator (Previous)
                        if (!_controller.isFirstCard)
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme
                                      .colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(2, 0),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.chevron_left,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        // Right edge indicator (Next)
                        if (!_controller.isLastCard)
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme
                                      .colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(-2, 0),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.chevron_right,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveSizer.spacingFromConstraints(
                      constraints,
                      multiplier: 2,
                    ),
                  ),
                  // Center Flip Card button
                  Center(
                    child: FilledButton.icon(
                      onPressed: _flipCard,
                      icon: Icon(
                        _controller.isCurrentCardFlipped
                            ? Icons.refresh
                            : Icons.flip,
                      ),
                      label: Text(
                        _controller.isCurrentCardFlipped
                            ? 'Flip Back'
                            : 'Flip Card',
                      ),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                            multiplier: 3,
                          ),
                          vertical: ResponsiveSizer.spacingFromConstraints(
                            constraints,
                            multiplier: 1.5,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveSizer.borderRadiusFromConstraints(
                              constraints,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFront(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
    int index,
  ) {
    final flashcard = widget.flashcards[index];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Icon(
          Icons.help_outline,
          size: ResponsiveSizer.iconSizeFromConstraints(
            constraints,
            multiplier: 2.5,
          ),
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
        SizedBox(
          height: ResponsiveSizer.spacingFromConstraints(
            constraints,
            multiplier: 3,
          ),
        ),
        Text(
          flashcard.front,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: ResponsiveSizer.spacingFromConstraints(
            constraints,
            multiplier: 2,
          ),
        ),
        Text(
          'Tap to flip',
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBack(
    ThemeData theme,
    TextTheme textTheme,
    BoxConstraints constraints,
    int index,
  ) {
    final flashcard = widget.flashcards[index];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Icon(
          Icons.check_circle_outline,
          size: ResponsiveSizer.iconSizeFromConstraints(
            constraints,
            multiplier: 2.5,
          ),
          color: theme.colorScheme.primary,
        ),
        SizedBox(
          height: ResponsiveSizer.spacingFromConstraints(
            constraints,
            multiplier: 3,
          ),
        ),
        Text(
          flashcard.back,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        if (flashcard.explanation != null &&
            flashcard.explanation!.isNotEmpty) ...<Widget>[
          SizedBox(
            height: ResponsiveSizer.spacingFromConstraints(
              constraints,
              multiplier: 3,
            ),
          ),
          Container(
            padding: EdgeInsets.all(
              ResponsiveSizer.cardPaddingFromConstraints(constraints),
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(
                ResponsiveSizer.borderRadiusFromConstraints(constraints),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.lightbulb_outline,
                      size:
                          ResponsiveSizer.iconSizeFromConstraints(constraints),
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    SizedBox(
                      width:
                          ResponsiveSizer.spacingFromConstraints(constraints),
                    ),
                    Text(
                      'Explanation',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ResponsiveSizer.spacingFromConstraints(constraints),
                ),
                Text(
                  flashcard.explanation!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(
          height: ResponsiveSizer.spacingFromConstraints(
            constraints,
            multiplier: 2,
          ),
        ),
        Text(
          'Tap to flip back',
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
