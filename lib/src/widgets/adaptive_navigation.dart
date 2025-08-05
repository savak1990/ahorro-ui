import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';

class AdaptiveNavigation extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<Widget> children;
  final List<NavigationDestination> destinations;

  const AdaptiveNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.children,
    required this.destinations,
  });

  @override
  State<AdaptiveNavigation> createState() => _AdaptiveNavigationState();
}

class _AdaptiveNavigationState extends State<AdaptiveNavigation> {
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isWeb) {
      return _buildWebNavigation(context);
    } else {
      return _buildMobileNavigation(context);
    }
  }

  Widget _buildWebNavigation(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;
        
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: isWideScreen,
                minExtendedWidth: 200,
                minWidth: 80,
                selectedIndex: widget.selectedIndex,
                onDestinationSelected: widget.onDestinationSelected,
                labelType: isWideScreen 
                    ? NavigationRailLabelType.none  // Исправлено: none для extended
                    : NavigationRailLabelType.selected,
                destinations: widget.destinations.map((destination) {
                  return NavigationRailDestination(
                    icon: destination.icon,
                    selectedIcon: destination.selectedIcon,
                    label: Text(destination.label),
                  );
                }).toList(),
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedIconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.primary,
                ),
                unselectedIconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                selectedLabelTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              VerticalDivider(
                thickness: 1,
                width: 1,
                color: Theme.of(context).dividerTheme.color,
              ),
              Expanded(
                child: widget.children[widget.selectedIndex],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileNavigation(BuildContext context) {
    return Scaffold(
      body: widget.children[widget.selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: widget.onDestinationSelected,
        destinations: widget.destinations,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
    );
  }
}

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;

  const AdaptiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isWeb) {
      // Web: Use a more prominent app bar
      return AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
        foregroundColor: foregroundColor ?? Theme.of(context).colorScheme.onSurface,
        elevation: elevation ?? 0,
        centerTitle: centerTitle,
        toolbarHeight: 80,
        titleSpacing: 24,
      );
    } else {
      // Mobile: Use standard app bar
      return AppBar(
        title: Text(title),
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: elevation,
        centerTitle: centerTitle,
      );
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(
    PlatformUtils.isWeb ? 80 : kToolbarHeight,
  );
}

class AdaptiveDrawer extends StatelessWidget {
  final Widget child;
  final double? width;

  const AdaptiveDrawer({
    super.key,
    required this.child,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final drawerWidth = width ?? (PlatformUtils.isWeb ? 320 : 280);
    
    return Drawer(
      width: drawerWidth,
      child: child,
    );
  }
}

class AdaptiveFloatingActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AdaptiveFloatingActionButton({
    super.key,
    required this.child,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isWeb) {
      // Web: Use a larger FAB with better positioning
      return FloatingActionButton.large(
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        child: child,
      );
    } else {
      // Mobile: Use standard FAB
      return FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        child: child,
      );
    }
  }
} 