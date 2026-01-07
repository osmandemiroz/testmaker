import 'dart:io';

import 'package:flutter/material.dart';
import 'package:testmaker/controllers/auth_controller.dart';
import 'package:testmaker/screens/auth/widgets/widgets.dart';
import 'package:testmaker/screens/home_screen.dart';
import 'package:testmaker/utils/responsive_sizer.dart';

/// ********************************************************************
/// auth_screen.dart
/// ********************************************************************
///
/// The main authentication screen for TestMaker.
/// Provides options for email/password login and registration,
/// Google Sign-In, Apple Sign-In, and Guest access.
///
/// Follows Apple Human Interface Guidelines:
/// - Clean, minimal layout with generous whitespace
/// - App logo prominently displayed at top
/// - Smooth form switching between login and register modes
/// - Large, accessible sign-in buttons
/// - Subtle guest option for users who prefer not to create an account
/// - Smooth fade transitions between states
/// - Support for both light and dark themes
///
/// Design choices:
/// - Apple Sign-In shown only on iOS/macOS (where it's available)
/// - Google Sign-In available on all platforms
/// - Email/password supports both login and registration
/// - Guest option allows exploring the app without commitment
/// - Error messages displayed with iOS-style snackbars
///

/// Enum for tracking the current auth mode
enum AuthMode {
  /// User is logging into existing account
  login,

  /// User is creating a new account
  register,
}

/// ********************************************************************
/// AuthScreen
/// ********************************************************************
///
/// Main authentication screen with email/password and social sign-in options.
///
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final AuthController _authController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Text controllers for form fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  /// Current authentication mode
  AuthMode _authMode = AuthMode.login;

  /// Tracks which button is currently loading
  String? _loadingButton;

  /// Whether Apple Sign-In is available on this platform
  bool _isAppleAvailable = false;

  @override
  void initState() {
    super.initState();
    // [AuthScreen.initState] - Initialize auth controller and animations
    _authController = AuthController();
    _authController.addListener(_onAuthStateChanged);

    // Initialize fade-in animation for the screen content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Start the fade-in animation
    _fadeController.forward();

    // Check if Apple Sign-In is available
    _checkAppleAvailability();
  }

  Future<void> _checkAppleAvailability() async {
    // [AuthScreen._checkAppleAvailability] - Check platform support
    if (Platform.isIOS || Platform.isMacOS) {
      final available = await _authController.isAppleSignInAvailable;
      if (mounted) {
        setState(() {
          _isAppleAvailable = available;
        });
      }
    }
  }

  void _onAuthStateChanged() {
    // [AuthScreen._onAuthStateChanged] - Handle auth state changes
    if (!mounted) return;

    if (_authController.isAuthenticated) {
      // Navigate to home screen on successful auth
      _navigateToHome();
    } else if (_authController.error != null) {
      // Show error message
      _showError(_authController.error!);
      _authController.clearError();
      setState(() {
        _loadingButton = null;
      });
    }
  }

  /// Navigates to the home screen with a fade transition
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
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

  /// Shows an error message using iOS-style snackbar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(ResponsiveSizer.spacing(context) * 2),
      ),
    );
  }

  /// Shows a success message
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(ResponsiveSizer.spacing(context) * 2),
      ),
    );
  }

  /// Toggles between login and register modes
  void _toggleAuthMode() {
    setState(() {
      _authMode =
          _authMode == AuthMode.login ? AuthMode.register : AuthMode.login;
      // Clear password fields when switching
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  /// Handles form submission (login or register)
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loadingButton = 'email';
    });

    bool success;
    if (_authMode == AuthMode.login) {
      success = await _authController.signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      success = await _authController.registerWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
      );
    }

    if (!success && mounted) {
      setState(() {
        _loadingButton = null;
      });
    }
  }

  /// Handles forgot password
  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email address first');
      return;
    }

    setState(() {
      _loadingButton = 'forgot';
    });

    final success = await _authController.sendPasswordResetEmail(email);

    if (mounted) {
      setState(() {
        _loadingButton = null;
      });

      if (success) {
        _showSuccess('Password reset email sent! Check your inbox.');
      }
    }
  }

  /// Handles Google Sign-In
  Future<void> _signInWithGoogle() async {
    setState(() {
      _loadingButton = 'google';
    });

    final success = await _authController.signInWithGoogle();

    if (!success && mounted) {
      setState(() {
        _loadingButton = null;
      });
    }
  }

  /// Handles Apple Sign-In
  Future<void> _signInWithApple() async {
    setState(() {
      _loadingButton = 'apple';
    });

    final success = await _authController.signInWithApple();

    if (!success && mounted) {
      setState(() {
        _loadingButton = null;
      });
    }
  }

  /// Handles Guest Sign-In
  Future<void> _signInAsGuest() async {
    setState(() {
      _loadingButton = 'guest';
    });

    final success = await _authController.signInAsGuest();

    if (!success && mounted) {
      setState(() {
        _loadingButton = null;
      });
    }
  }

  @override
  void dispose() {
    _authController
      ..removeListener(_onAuthStateChanged)
      ..dispose();
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveSizer.horizontalPadding(context) * 2,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: ResponsiveSizer.sectionSpacing(context),
                        ),

                        // App Logo and Title
                        _buildHeader(theme),

                        SizedBox(
                          height: ResponsiveSizer.sectionSpacing(context) * 1.5,
                        ),

                        // Email/Password Form
                        _buildAuthForm(theme),

                        SizedBox(
                          height: ResponsiveSizer.sectionSpacing(context),
                        ),

                        // Divider
                        const AuthDivider(),

                        // Social sign-in buttons
                        _buildSocialButtons(theme),

                        SizedBox(
                          height: ResponsiveSizer.spacing(context) * 1.5,
                        ),

                        // Guest option
                        GuestButton(
                          onPressed:
                              _loadingButton == null ? _signInAsGuest : null,
                          isLoading: _loadingButton == 'guest',
                        ),

                        SizedBox(
                          height: ResponsiveSizer.sectionSpacing(context),
                        ),

                        // Terms and Privacy notice
                        _buildLegalNotice(theme),

                        SizedBox(
                          height: ResponsiveSizer.spacing(context) * 2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Builds the header with app logo and welcome text
  Widget _buildHeader(ThemeData theme) {
    final logoSize = ResponsiveSizer.iconSize(context) * 4;
    final titleFontSize = 28 * ResponsiveSizer.fontSizeMultiplier(context);
    final subtitleFontSize = 16 * ResponsiveSizer.fontSizeMultiplier(context);

    return Column(
      children: [
        // App Logo Image
        ClipRRect(
          borderRadius: BorderRadius.circular(logoSize * 0.22),
          child: Image.asset(
            'assets/logo/app_logo.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.cover,
          ),
        ),

        SizedBox(height: ResponsiveSizer.sectionSpacing(context) * 0.8),

        // Welcome Title
        Text(
          _authMode == AuthMode.login ? 'Welcome Back' : 'Create Account',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: titleFontSize,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: ResponsiveSizer.spacing(context) * 0.5),

        // Subtitle
        Text(
          _authMode == AuthMode.login
              ? 'Sign in to access your quizzes and flashcards'
              : 'Sign up to start creating quizzes',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: subtitleFontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the email/password authentication form
  Widget _buildAuthForm(ThemeData theme) {
    final fieldSpacing = ResponsiveSizer.spacing(context) * 1.5;

    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name field (only for register)
            if (_authMode == AuthMode.register) ...[
              AuthTextField(
                controller: _nameController,
                label: 'Name',
                hintText: 'Enter your name',
                prefixIcon: Icons.person_outline_rounded,
                autofillHints: const [AutofillHints.name],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: fieldSpacing),
            ],

            // Email field
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                // Email validation without RegExp to avoid deprecation
                final email = value.trim();
                final atIndex = email.indexOf('@');
                // Must have exactly one @ symbol and it can't be at start or end
                if (atIndex <= 0 || atIndex >= email.length - 1) {
                  return 'Please enter a valid email';
                }
                // Check domain part (after @)
                final domain = email.substring(atIndex + 1);
                final lastDotIndex = domain.lastIndexOf('.');
                // Domain must have at least one dot and TLD must be 2-4 chars
                if (lastDotIndex <= 0 ||
                    lastDotIndex >= domain.length - 1 ||
                    domain.length - lastDotIndex - 1 < 2 ||
                    domain.length - lastDotIndex - 1 > 4) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            SizedBox(height: fieldSpacing),

            // Password field
            AuthTextField(
              controller: _passwordController,
              label: 'Password',
              hintText: _authMode == AuthMode.register
                  ? 'Create a password (min 6 characters)'
                  : 'Enter your password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              textInputAction: _authMode == AuthMode.register
                  ? TextInputAction.next
                  : TextInputAction.done,
              autofillHints: _authMode == AuthMode.login
                  ? const [AutofillHints.password]
                  : const [AutofillHints.newPassword],
              onFieldSubmitted:
                  _authMode == AuthMode.login ? (_) => _submitForm() : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (_authMode == AuthMode.register && value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),

            // Confirm Password field (only for register)
            if (_authMode == AuthMode.register) ...[
              SizedBox(height: fieldSpacing),
              AuthTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hintText: 'Confirm your password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onFieldSubmitted: (_) => _submitForm(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return "Passwords don't match";
                  }
                  return null;
                },
              ),
            ],

            // Forgot password link (only for login)
            if (_authMode == AuthMode.login) ...[
              SizedBox(height: ResponsiveSizer.spacing(context)),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loadingButton == null ? _forgotPassword : null,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize:
                          14 * ResponsiveSizer.fontSizeMultiplier(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],

            SizedBox(height: fieldSpacing),

            // Submit button
            AuthPrimaryButton(
              text: _authMode == AuthMode.login ? 'Sign In' : 'Create Account',
              onPressed: _loadingButton == null ? _submitForm : null,
              isLoading: _loadingButton == 'email',
            ),

            SizedBox(height: ResponsiveSizer.spacing(context)),

            // Toggle auth mode link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _authMode == AuthMode.login
                      ? "Don't have an account? "
                      : 'Already have an account? ',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14 * ResponsiveSizer.fontSizeMultiplier(context),
                  ),
                ),
                TextButton(
                  onPressed: _loadingButton == null ? _toggleAuthMode : null,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _authMode == AuthMode.login ? 'Sign Up' : 'Sign In',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize:
                          14 * ResponsiveSizer.fontSizeMultiplier(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the social sign-in buttons section
  Widget _buildSocialButtons(ThemeData theme) {
    final buttonSpacing = ResponsiveSizer.spacing(context) * 1.5;

    return Column(
      children: [
        // Google Sign-In Button
        SocialSignInButton(
          provider: SocialSignInProvider.google,
          onPressed: _loadingButton == null ? _signInWithGoogle : null,
          isLoading: _loadingButton == 'google',
        ),

        // Apple Sign-In Button (only on iOS/macOS)
        if (_isAppleAvailable) ...[
          SizedBox(height: buttonSpacing),
          SocialSignInButton(
            provider: SocialSignInProvider.apple,
            onPressed: _loadingButton == null ? _signInWithApple : null,
            isLoading: _loadingButton == 'apple',
          ),
        ],
      ],
    );
  }

  /// Builds the legal notice at the bottom
  Widget _buildLegalNotice(ThemeData theme) {
    final fontSize = 12 * ResponsiveSizer.fontSizeMultiplier(context);

    return Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        fontSize: fontSize,
      ),
      textAlign: TextAlign.center,
    );
  }
}
