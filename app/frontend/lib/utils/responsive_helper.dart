import 'package:flutter/material.dart';

/// Responsive design utilities for the RESP Gift Platform.
/// 
/// Provides breakpoints, layout helpers, and responsive widgets
/// following Material Design 3 guidelines.
class ResponsiveHelper {
  // Breakpoints based on Material Design 3 guidelines
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  /// Get the current screen type based on width
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else if (width < desktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Check if current screen is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32);
    } else if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48);
    } else {
      return const EdgeInsets.symmetric(horizontal: 64);
    }
  }

  /// Get maximum content width for centered layouts
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 800;
    } else if (isDesktop(context)) {
      return 1200;
    } else {
      return 1400;
    }
  }

  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    if (isMobile(context)) {
      return 0.9;
    } else if (isTablet(context)) {
      return 1.0;
    } else {
      return 1.1;
    }
  }

  /// Get responsive grid column count
  static int getGridColumns(BuildContext context, {int? mobile, int? tablet, int? desktop}) {
    if (isMobile(context)) {
      return mobile ?? 1;
    } else if (isTablet(context)) {
      return tablet ?? 2;
    } else {
      return desktop ?? 3;
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, {
    double mobile = 16,
    double tablet = 24,
    double desktop = 32,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }
}

/// Screen type enumeration
enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Responsive widget that builds different layouts based on screen size
class ResponsiveWidget extends StatelessWidget {
  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveHelper.getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
}

/// Responsive layout builder with breakpoint-based layouts
class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, ScreenType screenType) builder;

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveHelper.getScreenType(context);
    return builder(context, screenType);
  }
}

/// Responsive container with max width constraints
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? ResponsiveHelper.getMaxContentWidth(context);
    final effectivePadding = padding ?? ResponsiveHelper.getResponsiveHorizontalPadding(context);

    return Container(
      width: double.infinity,
      padding: effectivePadding,
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: child,
      ),
    );
  }
}

/// Responsive grid view with adaptive column count
class ResponsiveGridView extends StatelessWidget {
  const ResponsiveGridView({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.runSpacing,
    this.childAspectRatio = 1.0,
    this.physics,
    this.shrinkWrap = false,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double? runSpacing;
  final double childAspectRatio;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.getGridColumns(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing ?? spacing,
      childAspectRatio: childAspectRatio,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }
}

/// Responsive text widget that scales based on screen size
class ResponsiveText extends StatelessWidget {
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.scaleFactor,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? scaleFactor;

  @override
  Widget build(BuildContext context) {
    final multiplier = scaleFactor ?? ResponsiveHelper.getFontSizeMultiplier(context);
    final effectiveStyle = style?.copyWith(
      fontSize: (style?.fontSize ?? 14) * multiplier,
    );

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Extension methods for BuildContext to access responsive utilities
extension ResponsiveExtension on BuildContext {
  /// Get screen type
  ScreenType get screenType => ResponsiveHelper.getScreenType(this);
  
  /// Check if mobile
  bool get isMobile => ResponsiveHelper.isMobile(this);
  
  /// Check if tablet
  bool get isTablet => ResponsiveHelper.isTablet(this);
  
  /// Check if desktop
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  
  /// Check if large desktop
  bool get isLargeDesktop => ResponsiveHelper.isLargeDesktop(this);
  
  /// Get responsive padding
  EdgeInsets get responsivePadding => ResponsiveHelper.getResponsivePadding(this);
  
  /// Get responsive horizontal padding
  EdgeInsets get responsiveHorizontalPadding => ResponsiveHelper.getResponsiveHorizontalPadding(this);
  
  /// Get max content width
  double get maxContentWidth => ResponsiveHelper.getMaxContentWidth(this);
  
  /// Get font size multiplier
  double get fontSizeMultiplier => ResponsiveHelper.getFontSizeMultiplier(this);
}