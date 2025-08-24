import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';

/// Features section widget showcasing platform benefits.
/// 
/// Displays key features and benefits of the RESP gift platform
/// in a responsive grid layout.
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ResponsiveContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: context.isMobile ? 48 : 80,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSectionHeader(context, theme, colorScheme),
            SizedBox(height: context.isMobile ? 32 : 48),
            _buildFeaturesGrid(context, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        ResponsiveText(
          'Why Choose RESP Gifts?',
          style: context.isMobile 
              ? theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                )
              : theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ResponsiveText(
          'Give meaningful gifts that grow with compound interest and government matching.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final features = _getFeatures();
    
    return ResponsiveGridView(
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 3,
      spacing: 24,
      childAspectRatio: context.isMobile ? 1.2 : 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: features.map((feature) => _buildFeatureCard(
        context, 
        theme, 
        colorScheme, 
        feature,
      )).toList(),
    );
  }

  Widget _buildFeatureCard(BuildContext context, ThemeData theme, ColorScheme colorScheme, FeatureData feature) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feature.icon,
                size: 28,
                color: feature.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              feature.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feature.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureBenefits(context, theme, colorScheme, feature.benefits),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBenefits(BuildContext context, ThemeData theme, ColorScheme colorScheme, List<String> benefits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: benefits.map((benefit) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                benefit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  List<FeatureData> _getFeatures() {
    return [
      FeatureData(
        icon: Icons.savings_outlined,
        title: 'Tax-Free Growth',
        description: 'RESP contributions grow tax-free until withdrawal, maximizing the gift\'s impact.',
        color: const Color(0xFF4CAF50),
        benefits: [
          'No tax on investment gains',
          'Government matching up to \$500/year',
          'Compound growth over time',
        ],
      ),
      FeatureData(
        icon: Icons.favorite_outline,
        title: 'Meaningful Gifts',
        description: 'Give something that truly matters - a child\'s education and future opportunities.',
        color: const Color(0xFFE91E63),
        benefits: [
          'Lasting impact beyond childhood',
          'Teaches financial responsibility',
          'Shows you care about their future',
        ],
      ),
      FeatureData(
        icon: Icons.smartphone_outlined,
        title: 'Easy to Use',
        description: 'Simple, secure platform that makes giving educational gifts effortless.',
        color: const Color(0xFF2196F3),
        benefits: [
          'Set up in under 5 minutes',
          'Mobile-friendly interface',
          'Secure payment processing',
        ],
      ),
      FeatureData(
        icon: Icons.family_restroom_outlined,
        title: 'Family Friendly',
        description: 'Perfect for birthdays, holidays, and special occasions when family wants to contribute.',
        color: const Color(0xFFFF9800),
        benefits: [
          'Share gift pages with family',
          'Track contributions together',
          'Celebrate milestones',
        ],
      ),
      FeatureData(
        icon: Icons.trending_up_outlined,
        title: 'Watch It Grow',
        description: 'See the impact of your gifts as they compound and grow over the years.',
        color: const Color(0xFF9C27B0),
        benefits: [
          'Real-time balance updates',
          'Growth tracking charts',
          'Milestone celebrations',
        ],
      ),
      FeatureData(
        icon: Icons.school_outlined,
        title: 'Education Focus',
        description: 'Funds can be used for university, college, trade schools, and other qualifying programs.',
        color: const Color(0xFF607D8B),
        benefits: [
          'Flexible education options',
          'Covers tuition and living costs',
          'Supports lifelong learning',
        ],
      ),
    ];
  }
}

/// Data class for feature information
class FeatureData {
  const FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.benefits,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<String> benefits;
}

/// Compact features section for smaller spaces
class CompactFeaturesSection extends StatelessWidget {
  const CompactFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ResponsiveContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Key Benefits',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildCompactFeaturesList(context, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactFeaturesList(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final compactFeatures = [
      CompactFeatureData(
        icon: Icons.savings_outlined,
        title: 'Tax-Free Growth',
        subtitle: 'Government matching + compound interest',
        color: const Color(0xFF4CAF50),
      ),
      CompactFeatureData(
        icon: Icons.favorite_outline,
        title: 'Meaningful Impact',
        subtitle: 'Gifts that last a lifetime',
        color: const Color(0xFFE91E63),
      ),
      CompactFeatureData(
        icon: Icons.smartphone_outlined,
        title: 'Simple Setup',
        subtitle: 'Ready in under 5 minutes',
        color: const Color(0xFF2196F3),
      ),
    ];

    return Column(
      children: compactFeatures.map((feature) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: _buildCompactFeatureItem(context, theme, colorScheme, feature),
      )).toList(),
    );
  }

  Widget _buildCompactFeatureItem(BuildContext context, ThemeData theme, ColorScheme colorScheme, CompactFeatureData feature) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: feature.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            feature.icon,
            size: 24,
            color: feature.color,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                feature.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Data class for compact feature information
class CompactFeatureData {
  const CompactFeatureData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}