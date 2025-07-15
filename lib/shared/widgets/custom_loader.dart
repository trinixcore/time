import 'package:flutter/material.dart';

class CustomLoader extends StatefulWidget {
  final String? message;
  final double? size;
  final Color? backgroundColor;
  final bool showMessage;

  const CustomLoader({
    super.key,
    this.message,
    this.size,
    this.backgroundColor,
    this.showMessage = true,
  });

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize animations
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Start animations
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loaderSize = widget.size ?? 80.0;

    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Logo Container
            Container(
              width: loaderSize + 20,
              height: loaderSize + 20,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular((loaderSize + 20) / 2),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rotating ring
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: Container(
                          width: loaderSize + 15,
                          height: loaderSize + 15,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: CustomPaint(
                            painter: _LoaderRingPainter(
                              color: theme.primaryColor,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Pulsing logo
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: loaderSize,
                          height: loaderSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(loaderSize / 2),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(loaderSize / 2),
                            child: Image.asset(
                              'assets/images/ICON.png',
                              width: loaderSize * 0.7,
                              height: loaderSize * 0.7,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Loading message with typing animation
            if (widget.showMessage) ...[
              const SizedBox(height: 24),
              TweenAnimationBuilder<int>(
                duration: const Duration(milliseconds: 2000),
                tween: IntTween(
                  begin: 0,
                  end: (widget.message ?? 'Loading...').length,
                ),
                builder: (context, value, child) {
                  final text = widget.message ?? 'Loading...';
                  final displayText = text.substring(
                    0,
                    value.clamp(0, text.length),
                  );
                  return Text(
                    displayText + (value < text.length ? '|' : ''),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Custom painter for the loading ring
class _LoaderRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _LoaderRingPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw partial arc for loading effect
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      3.14159, // Draw half circle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Compact loader for buttons and small spaces
class CompactLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const CompactLoader({super.key, this.size = 20, this.color});

  @override
  State<CompactLoader> createState() => _CompactLoaderState();
}

class _CompactLoaderState extends State<CompactLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animation.value * 2 * 3.14159,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (widget.color ?? theme.primaryColor).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: CustomPaint(
                painter: _CompactRingPainter(
                  color: widget.color ?? theme.primaryColor,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompactRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _CompactRingPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      3.14159 * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Full screen loader overlay
class FullScreenLoader extends StatelessWidget {
  final String? message;
  final bool isVisible;

  const FullScreenLoader({super.key, this.message, this.isVisible = true});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Material(
      color: Colors.black.withOpacity(0.5),
      child: CustomLoader(
        message: message,
        size: 100,
        backgroundColor: Colors.white,
      ),
    );
  }
}
