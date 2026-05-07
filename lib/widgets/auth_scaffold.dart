import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;
  final bool showBack;

  const AuthScaffold({super.key, required this.child, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  if (showBack)
                    IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: AppColors.navy),
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/welcome'),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  const Text(
                    'DARWISH\nINTERSERVE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                      height: 1.1,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 36,
              color: AppColors.gold,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
