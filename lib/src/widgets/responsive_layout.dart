import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/platform_utils.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? web;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.web,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (PlatformUtils.isWeb) {
          // Web-specific layout
          if (constraints.maxWidth >= 1200) {
            return web ?? desktop ?? tablet ?? mobile;
          } else if (constraints.maxWidth >= 800) {
            return desktop ?? tablet ?? mobile;
          } else if (constraints.maxWidth >= 600) {
            return tablet ?? mobile;
          } else {
            return mobile;
          }
        } else {
          // Mobile-specific layout
          if (constraints.maxWidth >= 800) {
            return tablet ?? mobile;
          } else {
            return mobile;
          }
        }
      },
    );
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, String) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        String breakpoint;
        if (constraints.maxWidth >= 1200) {
          breakpoint = 'DESKTOP';
        } else if (constraints.maxWidth >= 800) {
          breakpoint = 'TABLET';
        } else {
          breakpoint = 'MOBILE';
        }
        return builder(context, breakpoint);
      },
    );
  }
}

class AdaptivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const AdaptivePadding({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    EdgeInsets adaptivePadding;
    if (PlatformUtils.isWeb) {
      if (screenWidth >= 1200) {
        adaptivePadding = const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
      } else if (screenWidth >= 800) {
        adaptivePadding = const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
      } else {
        adaptivePadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
      }
    } else {
      adaptivePadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }

    return Padding(
      padding: padding ?? adaptivePadding,
      child: child,
    );
  }
}

class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;

  const AdaptiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    double adaptiveMaxWidth;
    if (PlatformUtils.isWeb) {
      if (screenWidth >= 1200) {
        adaptiveMaxWidth = 1000;
      } else if (screenWidth >= 800) {
        adaptiveMaxWidth = 700;
      } else {
        adaptiveMaxWidth = double.infinity;
      }
    } else {
      adaptiveMaxWidth = double.infinity;
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? adaptiveMaxWidth,
      ),
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );
  }
}

class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? childAspectRatio;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    int crossAxisCount;
    if (PlatformUtils.isWeb) {
      if (screenWidth >= 1200) {
        crossAxisCount = 4;
      } else if (screenWidth >= 800) {
        crossAxisCount = 3;
      } else if (screenWidth >= 600) {
        crossAxisCount = 2;
      } else {
        crossAxisCount = 1;
      }
    } else {
      if (screenWidth >= 600) {
        crossAxisCount = 2;
      } else {
        crossAxisCount = 1;
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing ?? 16,
        mainAxisSpacing: mainAxisSpacing ?? 16,
        childAspectRatio: childAspectRatio ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
} 