import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';

/// Hero section widget for the landing page.
/// 
/// Displays the main value proposition with a compelling headline,
/// supporting text, and primary call-to-action button.
class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    this.onGetStarted,
    this.onLearnMore,
  });

  final VoidCallback? onGetStarted;
  final VoidCallback? onLearnMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ResponsiveContainer(
      child: ResponsiveWidget(
        mobile: _buildMobileLayout(context, theme, colorScheme),
        tablet: _buildTabletLayout(context, theme, colorScheme),
        desktop: _buildDesktopLayout(context, theme, colorScheme),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeroImage(context, height: 200),
          const SizedBox(height: 32),
          _buildContent(context, theme, colorScheme, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          _buildActions(context, theme, isStacked: true),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeroImage(context, height: 250),
          const SizedBox(height: 40),
          _buildContent(context, theme, colorScheme, textAlign: TextAlign.center),
          const SizedBox(height: 40),
          _buildActions(context, theme, isStacked: false),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: _buildContent(context, theme, colorScheme, textAlign: TextAlign.left),
          ),
          const SizedBox(width: 64),
          Expanded(
            flex: 4,
            child: _buildHeroImage(context, height: 400),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, ColorScheme colorScheme, {required TextAlign textAlign}) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Give the Gift of Education',
          style: context.isMobile 
              ? theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                )
              : theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
          textAlign: textAlign,
        ),
        const SizedBox(height: 16),
        ResponsiveText(
          'Help children build their future with RESP contributions. Instead of toys that break, give gifts that grow.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: textAlign,
        ),
        const SizedBox(height: 24),
        _buildFeatureHighlights(context, theme, colorScheme, textAlign: textAlign),
        if (context.isDesktop) ...[
          const SizedBox(height: 32),
          _buildActions(context, theme, isStacked: false),
        ],
      ],
    );
  }

  Widget _buildFeatureHighlights(BuildContext context, ThemeData theme, ColorScheme colorScheme, {required TextAlign textAlign}) {
    final highlights = [
      '🎓 Tax-free growth in RESPs',
      '💝 Meaningful gifts that last',
      '🚀 Easy setup in minutes',
    ];

    return Column(
      crossAxisAlignment: textAlign == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: highlights.map((highlight) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ResponsiveText(
          highlight,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          textAlign: textAlign,
        ),
      )).toList(),
    );
  }

  Widget _buildHeroImage(BuildContext context, {required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: height * 0.3,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Education Fund',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme, {required bool isStacked}) {
    final primaryButton = ElevatedButton(
      onPressed: onGetStarted,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text('Get Started'),
      ),
    );

    final secondaryButton = OutlinedButton(
      onPressed: onLearnMore,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text('Learn More'),
      ),
    );

    if (isStacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primaryButton,
          const SizedBox(height: 12),
          secondaryButton,
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: context.isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          primaryButton,
          const SizedBox(width: 16),
          secondaryButton,
        ],
      );
    }
  }
}

/// Hero section with background decoration
class DecoratedHeroSection extends StatelessWidget {
  const DecoratedHeroSection({
    super.key,
    this.onGetStarted,
    this.onLearnMore,
  });

  final VoidCallback? onGetStarted;
  final VoidCallback? onLearnMore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceVariant.withOpacity(0.3),
          ],
        ),
      ),
      child: HeroSection(
        onGetStarted: onGetStarted,
        onLearnMore: onLearnMore,
      ),
    );
  }
}