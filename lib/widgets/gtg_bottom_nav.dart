import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';

class GtgBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const GtgBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.search_rounded, label: 'Search'),
    _NavItem(icon: Icons.group_rounded, label: 'People'),
    _NavItem(icon: Icons.article_rounded, label: 'News'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  static const List<String> _routes = [
    '/home',
    '/search',
    '/gtg-flow',
    '/routes',
    '/settings',
  ];

  void _handleTap(BuildContext context, int index) {
    if (onTap != null) onTap!(index);
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 101,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.topSheet),
        ),
        boxShadow: const [AppShadows.nav],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isActive = index == currentIndex;
          return GestureDetector(
            onTap: () => _handleTap(context, index),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 52,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 27,
                    color: isActive ? AppColors.primary : AppColors.textPrimary,
                  ),
                  if (isActive)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
