import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';

/// How it works section widget explaining the 3-step process.
/// 
/// Shows users exactly how the RESP gift platform works
/// with clear, visual step-by-step instructions.
class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      color: colorScheme.surfaceVariant.withOpacity(0.3),
      child: ResponsiveContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: context.isMobile ? 48 : 80,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSectionHeader(context, theme, colorScheme),
              SizedBox(height: context.isMobile ? 32 : 48),
              _buildStepsLayout(context, theme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        ResponsiveText(
          'How It Works',
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
          'Getting started is simple. Follow these three easy steps to begin giving meaningful gifts.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepsLayout(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final steps = _getSteps();

    return ResponsiveWidget(
      mobile: _buildMobileSteps(context, theme, colorScheme, steps),
      tablet: _buildTabletSteps(context, theme, colorScheme, steps),
      desktop: _buildDesktopSteps(context, theme, colorScheme, steps),
    );
  }

  Widget _buildMobileSteps(BuildContext context, ThemeData theme, ColorScheme colorScheme, List<StepData> steps) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        return Column(
          children: [
            _buildStepCard(context, theme, colorScheme, step, index + 1),
            if (index < steps.length - 1) ...[
              const SizedBox(height: 16),
              _buildConnector(context, colorScheme, isVertical: true),
              const SizedBox(height: 16),
            ],
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTabletSteps(BuildContext context, ThemeData theme, ColorScheme colorScheme, List<StepData> steps) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isEven = index % 2 == 0;
        
        return Column(
          children: [
            Row(
              children: [
                if (!isEven) ...[
                  Expanded(child: Container()),
                  const SizedBox(width: 32),
                ],
                Expanded(
                  child: _buildStepCard(context, theme, colorScheme, step, index + 1),
                ),
                if (isEven) ...[
                  const SizedBox(width: 32),
                  Expanded(child: Container()),
                ],
              ],
            ),
            if (index < steps.length - 1) ...[
              const SizedBox(height: 24),
              _buildConnector(context, colorScheme, isVertical: true),
              const SizedBox(height: 24),
            ],
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDesktopSteps(BuildContext context, ThemeData theme, ColorScheme colorScheme, List<StepData> steps) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildStepCard(context, theme, colorScheme, step, index + 1),
              ),
              if (index < steps.length - 1) ...[
                const SizedBox(width: 16),
                _buildConnector(context, colorScheme, isVertical: false),
                const SizedBox(width: 16),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepCard(BuildContext context, ThemeData theme, ColorScheme colorScheme, StepData step, int stepNumber) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildStepNumber(context, theme, colorScheme, stepNumber),
            const SizedBox(height: 16),
            _buildStepIcon(context, colorScheme, step),
            const SizedBox(height: 16),
            Text(
              step.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              step.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildStepDetails(context, theme, colorScheme, step.details),
          ],
        ),
      ),
    );
  }

  Widget _buildStepNumber(BuildContext context, ThemeData theme, ColorScheme colorScheme, int stepNumber) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          stepNumber.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepIcon(BuildContext context, ColorScheme colorScheme, StepData step) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: step.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        step.icon,
        size: 40,
        color: step.color,
      ),
    );
  }

  Widget _buildStepDetails(BuildContext context, ThemeData theme, ColorScheme colorScheme, List<String> details) {
    return Column(
      children: details.map((detail) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                detail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildConnector(BuildContext context, ColorScheme colorScheme, {required bool isVertical}) {
    return Container(
      width: isVertical ? 2 : 40,
      height: isVertical ? 40 : 2,
      decoration: BoxDecoration(
        color: colorScheme.outline.withOpacity(0.3),
        borderRadius: BorderRadius.circular(1),
      ),
      child: isVertical 
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: colorScheme.outline,
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.keyboard_arrow_right,
                  size: 20,
                  color: colorScheme.outline,
                ),
              ],
            ),
    );
  }

  List<StepData> _getSteps() {
    return [
      StepData(
        icon: Icons.person_add_outlined,
        title: 'Create Account',
        description: 'Sign up and set up your child\'s RESP gift page in minutes.',
        color: const Color(0xFF2196F3),
        details: [
          'Quick registration',
          'Secure verification',
          'Custom gift page',
        ],
      ),
      StepData(
        icon: Icons.share_outlined,
        title: 'Share with Family',
        description: 'Send the unique gift page link to family and friends.',
        color: const Color(0xFF4CAF50),
        details: [
          'Unique gift page URL',
          'Easy sharing options',
          'Mobile-friendly',
        ],
      ),
      StepData(
        icon: Icons.celebration_outlined,
        title: 'Watch It Grow',
        description: 'Track contributions and watch the education fund grow over time.',
        color: const Color(0xFFFF9800),
        details: [
          'Real-time updates',
          'Growth tracking',
          'Milestone celebrations',
        ],
      ),
    ];
  }
}

/// Data class for step information
class StepData {
  const StepData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.details,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<String> details;
}

/// Simplified how it works section for compact spaces
class SimpleHowItWorksSection extends StatelessWidget {
  const SimpleHowItWorksSection({super.key});

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
              'Simple 3-Step Process',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildSimpleSteps(context, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleSteps(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final steps = [
      'Create your child\'s gift page',
      'Share with family and friends',
      'Watch the education fund grow',
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (index + 1).toString(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  step,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}