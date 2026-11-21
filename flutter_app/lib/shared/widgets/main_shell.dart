import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../features/wishlist/presentation/providers/wishlist_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/catalog') || location.startsWith('/menu')) return 1;
    if (location.startsWith('/scan')) return 2;
    if (location.startsWith('/wishlist') || location.startsWith('/favorites')) return 3;
    if (location.startsWith('/profile') || location.startsWith('/account')) return 4;
    return 0; // Home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/catalog');
        break;
      case 2:
        context.go('/scan');
        break;
      case 3:
        context.go('/wishlist');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _calculateSelectedIndex(context);
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: _NavBarItem(
                    index: 0,
                    selectedIndex: selectedIndex,
                    label: 'ទំព័រដើម',
                    activeIcon: Icons.home_rounded,
                    inactiveIcon: Icons.home_outlined,
                    onTap: () => _onItemTapped(0, context),
                  ),
                ),
                Expanded(
                  child: _NavBarItem(
                    index: 1,
                    selectedIndex: selectedIndex,
                    label: 'មុខម្ហូប',
                    activeIcon: Icons.restaurant_menu_rounded,
                    inactiveIcon: Icons.restaurant_menu_outlined,
                    onTap: () => _onItemTapped(1, context),
                  ),
                ),
                // Center Scan to Find Product
                Expanded(
                  child: _NavBarItem(
                    index: 2,
                    selectedIndex: selectedIndex,
                    label: 'ស្កេន',
                    activeIcon: Icons.qr_code_scanner_rounded,
                    inactiveIcon: Icons.qr_code_scanner_outlined,
                    onTap: () => _onItemTapped(2, context),
                  ),
                ),
                // Wishlist (ចូលចិត្ត)
                Expanded(
                  child: _NavBarItem(
                    index: 3,
                    selectedIndex: selectedIndex,
                    label: 'ចូលចិត្ត',
                    activeIcon: Icons.favorite_rounded,
                    inactiveIcon: Icons.favorite_outline_rounded,
                    badgeCount: wishlist.length,
                    badgeColor: Colors.red.shade600,
                    onTap: () => _onItemTapped(3, context),
                  ),
                ),
                Expanded(
                  child: _NavBarItem(
                    index: 4,
                    selectedIndex: selectedIndex,
                    label: 'គណនី',
                    activeIcon: Icons.person_rounded,
                    inactiveIcon: Icons.person_outline_rounded,
                    onTap: () => _onItemTapped(4, context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final int index;
  final int selectedIndex;
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final int badgeCount;
  final Color badgeColor;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.index,
    required this.selectedIndex,
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    this.badgeCount = 0,
    this.badgeColor = AppTheme.primaryColor,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.index == widget.selectedIndex;
    final Color iconColor = isSelected ? AppTheme.primaryColor : const Color(0xFF94A3B8);
    final Color textColor = isSelected ? AppTheme.primaryColor : const Color(0xFF94A3B8);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Smooth Animated Icon: only color change and subtle scale
                  AnimatedScale(
                    scale: isSelected ? 1.12 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      isSelected ? widget.activeIcon : widget.inactiveIcon,
                      color: iconColor,
                      size: 24,
                    ),
                  ),

                  // Badge Counter for Favorites
                  if (widget.badgeCount > 0)
                    Positioned(
                      top: -4,
                      right: -10,
                      child: AnimatedScale(
                        scale: widget.badgeCount > 0 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          decoration: BoxDecoration(
                            color: widget.badgeColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              widget.badgeCount > 99 ? '99+' : '${widget.badgeCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),

              // Animated Text Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontFamily: 'Kantumruy Pro',
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
