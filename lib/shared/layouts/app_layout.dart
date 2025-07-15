import 'package:flutter/material.dart';

/// Main application layout wrapper
class AppLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final bool showAppBar;

  const AppLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          showAppBar
              ? AppBar(
                title: title != null ? Text(title!) : null,
                actions: actions,
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              )
              : null,
      drawer: drawer,
      body: SafeArea(child: child),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Responsive layout that adapts to screen size
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 768) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Card layout for consistent content presentation
class ContentCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ContentCard({
    super.key,
    required this.child,
    this.title,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(title!, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
