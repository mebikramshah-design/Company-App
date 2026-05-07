class CompanyEvent {
  final String id;
  final String title;
  final String category;
  final String date;
  final String description;
  final bool featured;

  const CompanyEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.description,
    this.featured = false,
  });
}

const sampleEvents = <CompanyEvent>[
  CompanyEvent(
    id: 'e1',
    title: 'Industry Engagement & Participation',
    category: 'Industry',
    date: 'March 2026',
    description:
        'Active participation in industry events to strengthen partnerships and showcase our expertise in facilities management.',
    featured: true,
  ),
  CompanyEvent(
    id: 'e2',
    title: 'Project Milestone Achievement',
    category: 'Achievement',
    date: 'January 2026',
    description:
        'Successful completion of key project milestones, demonstrating our commitment to quality and timely delivery.',
  ),
  CompanyEvent(
    id: 'e3',
    title: 'Workforce Excellence Awards',
    category: 'Community',
    date: 'December 2025',
    description:
        'Recognising frontline employees who consistently deliver outstanding service across our 100+ active sites.',
  ),
];
