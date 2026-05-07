class CompanyProject {
  final String id;
  final String number;
  final String title;
  final String sector;
  final String client;
  final String description;
  final int sites;
  final String? imageUrl;

  const CompanyProject({
    required this.id,
    required this.number,
    required this.title,
    required this.sector,
    required this.client,
    required this.description,
    required this.sites,
    this.imageUrl,
  });
}

const sampleProjects = <CompanyProject>[
  CompanyProject(
    id: 'p1',
    number: '01',
    title: 'Integrated Facility Management — Education Sector',
    sector: 'Education Sector',
    client: 'Government Entity',
    description:
        'Comprehensive facility management services including maintenance, cleaning, and operational support for educational institutions.',
    sites: 215,
  ),
  CompanyProject(
    id: 'p2',
    number: '02',
    title: 'Aviation Facility Maintenance',
    sector: 'Aviation Sector',
    client: 'National Aviation Authority',
    description:
        'End-to-end hard and soft FM services across passenger terminals, support buildings, and airside facilities.',
    sites: 38,
  ),
  CompanyProject(
    id: 'p3',
    number: '03',
    title: 'Commercial Tower MEP Operations',
    sector: 'Commercial Sector',
    client: 'Premier Real Estate',
    description:
        'Mechanical, electrical, plumbing and HVAC operations for premium commercial high-rise towers in Doha.',
    sites: 12,
  ),
];
