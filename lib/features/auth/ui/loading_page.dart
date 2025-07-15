import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/widgets/custom_loader.dart';

class LoadingPage extends ConsumerStatefulWidget {
  final String? message;

  const LoadingPage({super.key, this.message});

  @override
  ConsumerState<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends ConsumerState<LoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Start animations
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(shouldShowSetupProvider);
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    // Check if we're in a fresh system state
    final isFreshSystem =
        setupState.hasValue &&
        setupState.value == true &&
        authState.hasValue &&
        authState.value == null;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withOpacity(0.1),
              theme.colorScheme.surface,
              theme.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    32,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo - Smaller
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationAnimation.value * 2 * 3.14159,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.primaryColor,
                                      theme.primaryColor.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.primaryColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 6),
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.access_time_rounded,
                                  size: 35,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // App Name - More compact
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 15 * (1 - value)),
                          child: Column(
                            children: [
                              // Main title - Smaller
                              Text(
                                'TRINIX INTERNAL MANAGEMENT ENGINE',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 600
                                          ? 14
                                          : 18,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              // Subtitle with acronym - Smaller
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.primaryColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'T.I.M.E',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.primaryColor,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Conditional content based on system state
                  if (isFreshSystem) ...[
                    // Fresh system - show setup guide
                    _buildSetupGuide(theme),
                  ] else ...[
                    // Loading state - show progress indicator
                    _buildLoadingIndicator(theme),
                  ],

                  const SizedBox(height: 24),

                  // Status Information - More compact
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStatusRow(
                          'Setup',
                          setupState.when(
                            data:
                                (shouldShow) =>
                                    shouldShow ? "Required" : "Complete",
                            loading: () => "Checking...",
                            error: (_, __) => "Error",
                          ),
                          setupState.when(
                            data:
                                (shouldShow) =>
                                    shouldShow ? Colors.orange : Colors.green,
                            loading: () => Colors.blue,
                            error: (_, __) => Colors.red,
                          ),
                          theme,
                        ),
                        const SizedBox(height: 6),
                        _buildStatusRow(
                          'Auth',
                          authState.when(
                            data:
                                (user) => user != null ? "Active" : "Inactive",
                            loading: () => "Checking...",
                            error: (_, __) => "Error",
                          ),
                          authState.when(
                            data:
                                (user) =>
                                    user != null ? Colors.green : Colors.orange,
                            loading: () => Colors.blue,
                            error: (_, __) => Colors.red,
                          ),
                          theme,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Manual navigation buttons - More compact
                  if (setupState.hasValue || setupState.hasError) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildActionButton(
                          'Login',
                          Icons.login,
                          () => context.go('/login'),
                          theme,
                          isPrimary: false,
                        ),
                        _buildActionButton(
                          'Setup',
                          Icons.settings,
                          () => context.go('/setup-super-admin'),
                          theme,
                          isPrimary: isFreshSystem,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Company branding - More compact
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor.withOpacity(0.08),
                          theme.primaryColor.withOpacity(0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TRINIX',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Powered by Innovation',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupGuide(ThemeData theme) {
    return Column(
      children: [
        // Welcome message - More compact
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withOpacity(0.1),
                theme.primaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.rocket_launch, size: 32, color: theme.primaryColor),
              const SizedBox(height: 8),
              Text(
                'Welcome to Your New System!',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Your TRINIX Internal Management Engine is ready to be configured.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Setup steps - More compact
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Setup Steps:',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildSetupStep(
                '1',
                'Create Super Admin',
                'Set up administrator account',
                Icons.admin_panel_settings,
                theme,
              ),
              const SizedBox(height: 6),
              _buildSetupStep(
                '2',
                'Configure System',
                'Initialize departments & designations',
                Icons.settings_applications,
                theme,
              ),
              const SizedBox(height: 6),
              _buildSetupStep(
                '3',
                'Start Managing',
                'Begin user management',
                Icons.people,
                theme,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Call to action - More compact
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: theme.primaryColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Click "Setup" below to begin configuration',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return CustomLoader(
      message: widget.message ?? 'Loading system...',
      size: 60,
    );
  }

  Widget _buildSetupStep(
    String number,
    String title,
    String description,
    IconData icon,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: theme.primaryColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                  height: 1.2,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(
    String label,
    String value,
    Color color,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
    ThemeData theme, {
    bool isPrimary = true,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isPrimary
                ? theme.primaryColor
                : theme.primaryColor.withOpacity(0.1),
        foregroundColor:
            isPrimary ? theme.colorScheme.onPrimary : theme.primaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
        ),
      ),
    );
  }
}

// Specialized loading pages for different contexts
class AuthLoadingPage extends LoadingPage {
  const AuthLoadingPage({super.key})
    : super(message: 'Checking authentication...');
}

class ProfileLoadingPage extends LoadingPage {
  const ProfileLoadingPage({super.key})
    : super(message: 'Loading your profile...');
}

class AppInitializingPage extends LoadingPage {
  const AppInitializingPage({super.key})
    : super(message: 'Setting up your workspace...');
}
