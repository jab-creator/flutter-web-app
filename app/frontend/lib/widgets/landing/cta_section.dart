import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';

/// Call-to-action section widget for the landing page.
/// 
/// Provides compelling final call-to-action to encourage
/// users to sign up and start using the platform.
class CtaSection extends StatelessWidget {
  const CtaSection({
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: ResponsiveContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: context.isMobile ? 48 : 64,
          ),
          child: ResponsiveWidget(
            mobile: _buildMobileLayout(context, theme, colorScheme),
            tablet: _buildTabletLayout(context, theme, colorScheme),
            desktop: _buildDesktopLayout(context, theme, colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildContent(context, theme, colorScheme, textAlign: TextAlign.center),
        const SizedBox(height: 32),
        _buildActions(context, theme, colorScheme, isStacked: true),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildContent(context, theme, colorScheme, textAlign: TextAlign.center),
        const SizedBox(height: 32),
        _buildActions(context, theme, colorScheme, isStacked: false),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildContent(context, theme, colorScheme, textAlign: TextAlign.left),
        ),
        const SizedBox(width: 48),
        Expanded(
          flex: 1,
          child: _buildActions(context, theme, colorScheme, isStacked: true),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, ColorScheme colorScheme, {required TextAlign textAlign}) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Ready to Give the Gift of Education?',
          style: context.isMobile 
              ? theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                )
              : theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
          textAlign: textAlign,
        ),
        const SizedBox(height: 16),
        ResponsiveText(
          'Join thousands of families who are building brighter futures through RESP gifts. Start your child\'s education fund today.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onPrimary.withOpacity(0.9),
            height: 1.5,
          ),
          textAlign: textAlign,
        ),
        const SizedBox(height: 24),
        _buildTrustIndicators(context, theme, colorScheme, textAlign: textAlign),
      ],
    );
  }

  Widget _buildTrustIndicators(BuildContext context, ThemeData theme, ColorScheme colorScheme, {required TextAlign textAlign}) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: textAlign == TextAlign.center ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              Icons.security_outlined,
              size: 20,
              color: colorScheme.onPrimary.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              'Bank-level security',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
            const SizedBox(width: 24),
            Icon(
              Icons.verified_outlined,
              size: 20,
              color: colorScheme.onPrimary.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              'Government approved',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: textAlign == TextAlign.center ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              Icons.people_outline,
              size: 20,
              color: colorScheme.onPrimary.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              '10,000+ families trust us',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
            const SizedBox(width: 24),
            Icon(
              Icons.trending_up_outlined,
              size: 20,
              color: colorScheme.onPrimary.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              '\$50M+ in RESPs',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme, ColorScheme colorScheme, {required bool isStacked}) {
    final primaryButton = ElevatedButton(
      onPressed: onGetStarted,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Start Free Today',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    final secondaryButton = OutlinedButton(
      onPressed: onLearnMore,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onPrimary,
        side: BorderSide(color: colorScheme.onPrimary.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Learn More',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
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

/// Compact CTA section for smaller spaces
class CompactCtaSection extends StatelessWidget {
  const CompactCtaSection({
    super.key,
    this.onGetStarted,
    this.backgroundColor,
  });

  final VoidCallback? onGetStarted;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primaryContainer;

    return Container(
      width: double.infinity,
      color: effectiveBackgroundColor,
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to get started?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create your child\'s gift page in minutes.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                onPressed: onGetStarted,
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Newsletter signup CTA section
class NewsletterCtaSection extends StatefulWidget {
  const NewsletterCtaSection({
    super.key,
    this.onSubscribe,
  });

  final Function(String email)? onSubscribe;

  @override
  State<NewsletterCtaSection> createState() => _NewsletterCtaSectionState();
}

class _NewsletterCtaSectionState extends State<NewsletterCtaSection> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ResponsiveContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Stay Updated',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Get tips on RESP planning and updates on new features.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildEmailForm(context, theme, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      child: ResponsiveWidget(
        mobile: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmailField(context, theme, colorScheme),
            const SizedBox(height: 16),
            _buildSubscribeButton(context, theme, colorScheme),
          ],
        ),
        desktop: Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildEmailField(context, theme, colorScheme),
            ),
            const SizedBox(width: 16),
            _buildSubscribeButton(context, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        hintText: 'Enter your email address',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildSubscribeButton(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSubscribe,
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Subscribe'),
    );
  }

  Future<void> _handleSubscribe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSubscribe?.call(_emailController.text.trim());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for subscribing!'),
            backgroundColor: Colors.green,
          ),
        );
        _emailController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}