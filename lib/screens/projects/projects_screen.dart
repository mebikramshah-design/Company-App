import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../theme/app_theme.dart';
import '../../widgets/screen_header.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            greeting: 'Our Projects',
            subtitle: '100+ active engagements',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.tune, color: Colors.white),
                ),
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.gold,
                  child: Text('M',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 6),
            child: Center(
              child: Text(
                'OUR PORTFOLIO',
                style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const Center(
            child: Text(
              'Our Projects',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Selected projects that showcase our capability across\nmultiple sectors.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Expanded(child: _Stat(value: '100+', label: 'Active Projects')),
                _Divider(),
                Expanded(child: _Stat(value: '235', label: 'Total Sites')),
                _Divider(),
                Expanded(child: _Stat(value: '3.5K+', label: 'Workforce')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...sampleProjects.map((p) => _ProjectCard(project: p)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE5E7EB),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final CompanyProject project;
  const _ProjectCard({required this.project});

  Color get _accent {
    switch (project.number) {
      case '01':
        return const Color(0xFF22C55E);
      case '02':
        return AppColors.primary;
      case '03':
        return AppColors.navy;
      default:
        return AppColors.secondary;
    }
  }

  IconData get _icon {
    switch (project.sector) {
      case 'Aviation Sector':
        return Icons.flight;
      case 'Education Sector':
        return Icons.school;
      case 'Commercial Sector':
        return Icons.apartment;
      default:
        return Icons.business;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 16,
                  top: 12,
                  child: Text(
                    project.number,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_icon, color: Colors.white),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      project.sector.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.business_center,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    const Text(
                      'Client: ',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                    ),
                    Expanded(
                      child: Text(
                        project.client,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  project.description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${project.sites} sites',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                    ),
                    const Spacer(),
                    const Text(
                      'View Details',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward,
                        size: 14, color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
