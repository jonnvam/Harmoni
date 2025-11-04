import 'package:flutter/material.dart';

/// Breakpoints for responsive layout
class AppBreakpoints {
  static const double tablet = 600; // logical px
  static const double desktop = 1024;
}

/// Standard spacing and paddings for the app
class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Layout utilities for paddings and max content width
class AppLayout {
  /// Horizontal screen padding depending on device width
  static EdgeInsets screenPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= AppBreakpoints.desktop) {
      return const EdgeInsets.symmetric(horizontal: AppSpacing.xxl);
    }
    if (w >= AppBreakpoints.tablet) {
      return const EdgeInsets.symmetric(horizontal: AppSpacing.xl);
    }
    return const EdgeInsets.symmetric(horizontal: AppSpacing.lg);
  }

  /// Max content width to keep readable line length on large screens
  static double maxContentWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= AppBreakpoints.desktop) return 900;
    if (w >= AppBreakpoints.tablet) return 720;
    return double.infinity; // on phones we use full width with padding
  }
}

/// Centers content and constrains its width, applying default horizontal padding
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? AppLayout.screenPadding(context);
    final maxW = maxWidth ?? AppLayout.maxContentWidth(context);
    return Padding(
      padding: pad,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: child,
        ),
      ),
    );
  }
}
