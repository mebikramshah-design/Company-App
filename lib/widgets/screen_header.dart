import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ScreenHeader extends StatelessWidget {
  final String greeting;
  final String? subtitle;
  final String? userInitial;
  final Widget? trailing;
  final bool showBell;

  const ScreenHeader({
    super.key,
    required this.greeting,
    this.subtitle,
    this.userInitial,
    this.trailing,
    this.showBell = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showBell)
            Container(
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.notifications_none, color: Colors.white),
                    Positioned(
                      right: -2,
                      top: -2,
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (trailing != null) trailing!,
          if (trailing == null)
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.gold,
              child: Text(
                userInitial ?? 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
