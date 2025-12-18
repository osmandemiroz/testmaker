import 'package:flutter/material.dart';
import 'package:testmaker/services/question_generator_service.dart';
import 'package:testmaker/utils/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

/// A beautifully designed settings dialog following Apple's Human Interface
/// Guidelines:
///  - Clean, minimal design with generous spacing
///  - Soft rounded corners and subtle shadows
///  - Smooth animations and transitions
///  - Clear visual hierarchy and focus states
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late TextEditingController _apiKeyController;
  bool _isFocused = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
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

    _loadApiKey();
    _animationController.forward();
  }

  /// Loads the current API key from storage.
  Future<void> _loadApiKey() async {
    final currentKey = await QuestionGeneratorService.getApiKey() ?? '';
    if (mounted) {
      setState(() {
        _apiKeyController.text = currentKey;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _apiKeyController.dispose();
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
                          // Title
                          Text(
                            'Settings',
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
                            'Manage your app preferences',
                            style: textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // API Key section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Google AI API Key',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveSizer.spacingFromConstraints(
                              constraints,
                            ),
                          ),
                          Text(
                            'Required for generating questions from PDFs',
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveSizer.spacingFromConstraints(
                              constraints,
                              multiplier: 1.5,
                            ),
                          ),
                          Focus(
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
                              child: _isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : TextField(
                                      controller: _apiKeyController,
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText:
                                            'Enter your Google AI API key',
                                        hintStyle:
                                            textTheme.bodyLarge?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 18,
                                        ),
                                      ),
                                      obscureText: true,
                                    ),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveSizer.spacingFromConstraints(
                              constraints,
                              multiplier: 1.5,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final url = Uri.parse(
                                'https://makersuite.google.com/app/apikey',
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            icon: Icon(
                              Icons.open_in_new,
                              size: ResponsiveSizer.iconSizeFromConstraints(
                                constraints,
                                multiplier: 0.67,
                              ),
                            ),
                            label: const Text('Get API Key'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
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
                          // Save button
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: () async {
                                await QuestionGeneratorService.setApiKey(
                                  _apiKeyController.text.trim().isEmpty
                                      ? null
                                      : _apiKeyController.text.trim(),
                                );
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Settings saved successfully!',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
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
                                'Save',
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
