import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/screen_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    final name = user?.displayName.split(' ').first ?? 'Guest';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            greeting: 'Good Morning,',
            subtitle: name,
            userInitial: name.isNotEmpty ? name[0].toUpperCase() : 'U',
          ),
          Transform.translate(
            offset: const Offset(0, -16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _HeroCard(),
            ),
          ),
          const _SectionLabel(eyebrow: 'ABOUT US', title: 'A leading integrated FM company'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Darwish Interserve is a leading integrated facilities management '
              'company in Qatar, established in 2010. With a highly skilled workforce, '
              'we deliver high-quality services across commercial, residential, and '
              'government sectors.',
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 13, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel(eyebrow: 'WHAT WE DO', title: 'Our Services'),
          const _ServiceCard(
            icon: Icons.build_outlined,
            iconColor: Color(0xFF2563EB),
            title: 'Hard Services',
            description:
                'Mechanical, Electrical, HVAC, Plumbing, and Civil maintenance solutions ensuring efficient and reliable operations.',
          ),
          const _ServiceCard(
            icon: Icons.spa_outlined,
            iconColor: Color(0xFF16A34A),
            title: 'Soft Services',
            description:
                'Cleaning, landscaping, pest control, and support services designed to maintain safe and comfortable environments.',
          ),
          const _ServiceCard(
            icon: Icons.security_outlined,
            iconColor: Color(0xFFB45309),
            title: 'Specialised Services',
            description:
                'Asset management, helpdesk operations, energy efficiency, and integrated workplace solutions.',
          ),
          const SizedBox(height: 24),
          const _SectionLabel(
              eyebrow: 'QUICK ACTIONS', title: 'Get in touch'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: const [
                Expanded(
                    child: _QuickAction(
                        icon: Icons.call, label: 'Contact Us')),
                SizedBox(width: 10),
                Expanded(
                    child: _QuickAction(
                        icon: Icons.public, label: 'Website')),
                SizedBox(width: 10),
                Expanded(
                    child: _QuickAction(
                        icon: Icons.warning_amber, label: 'Emergency')),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 24, height: 2, color: AppColors.gold),
              const SizedBox(width: 8),
              const Text(
                'WELCOME TO DIFM',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Redefining the Future\nfor People and Places',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your Trusted Facilities Management Partner in Qatar',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String eyebrow;
  final String title;
  const _SectionLabel({required this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _ServiceCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, color: AppColors.primary, size: 18),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
