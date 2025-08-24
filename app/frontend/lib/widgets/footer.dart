import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// Site footer widget with links and information.
/// 
/// Provides navigation links, legal information, and contact details
/// in a responsive layout that adapts to different screen sizes.
class Footer extends StatelessWidget {
  const Footer({
    super.key,
    this.onPrivacyPolicy,
    this.onTermsOfService,
    this.onContact,
    this.onAbout,
    this.onHelp,
    this.onBlog,
  });

  final VoidCallback? onPrivacyPolicy;
  final VoidCallback? onTermsOfService;
  final VoidCallback? onContact;
  final VoidCallback? onAbout;
  final VoidCallback? onHelp;
  final VoidCallback? onBlog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      color: colorScheme.surfaceVariant.withOpacity(0.5),
      child: ResponsiveContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: context.isMobile ? 32 : 48,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandSection(context, theme, colorScheme),
        const SizedBox(height: 32),
        _buildLinksSection(context, theme, colorScheme),
        const SizedBox(height: 32),
        _buildContactSection(context, theme, colorScheme),
        const SizedBox(height: 32),
        _buildSocialSection(context, theme, colorScheme),
        const SizedBox(height: 32),
        _buildBottomSection(context, theme, colorScheme),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildBrandSection(context, theme, colorScheme),
            ),
            const SizedBox(width: 48),
            Expanded(
              child: _buildLinksSection(context, theme, colorScheme),
            ),
            const SizedBox(width: 48),
            Expanded(
              child: _buildContactSection(context, theme, colorScheme),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSocialSection(context, theme, colorScheme),
        const SizedBox(height: 24),
        _buildBottomSection(context, theme, colorScheme),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildBrandSection(context, theme, colorScheme),
            ),
            const SizedBox(width: 64),
            Expanded(
              child: _buildLinksSection(context, theme, colorScheme),
            ),
            const SizedBox(width: 64),
            Expanded(
              child: _buildContactSection(context, theme, colorScheme),
            ),
            const SizedBox(width: 64),
            Expanded(
              child: _buildSocialSection(context, theme, colorScheme),
            ),
          ],
        ),
        const SizedBox(height: 48),
        _buildBottomSection(context, theme, colorScheme),
      ],
    );
  }

  Widget _buildBrandSection(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.school_outlined,
              size: 32,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'RESP Gifts',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Making education gifts meaningful and accessible for Canadian families.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildTrustBadges(context, theme, colorScheme),
      ],
    );
  }

  Widget _buildTrustBadges(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildTrustBadge(
          context,
          theme,
          colorScheme,
          icon: Icons.security_outlined,
          text: 'Secure',
        ),
        _buildTrustBadge(
          context,
          theme,
          colorScheme,
          icon: Icons.verified_outlined,
          text: 'Verified',
        ),
        _buildTrustBadge(
          context,
          theme,
          colorScheme,
          icon: Icons.flag_outlined,
          text: 'Canadian',
        ),
      ],
    );
  }

  Widget _buildTrustBadge(BuildContext context, ThemeData theme, ColorScheme colorScheme, {
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksSection(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Links',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildFooterLink(context, theme, colorScheme, 'About Us', onAbout),
        _buildFooterLink(context, theme, colorScheme, 'How It Works', onHelp),
        _buildFooterLink(context, theme, colorScheme, 'Blog', onBlog),
        _buildFooterLink(context, theme, colorScheme, 'Help Center', onHelp),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          context,
          theme,
          colorScheme,
          icon: Icons.email_outlined,
          text: 'support@respgifts.ca',
        ),
        _buildContactItem(
          context,
          theme,
          colorScheme,
          icon: Icons.phone_outlined,
          text: '1-800-RESP-GIFT',
        ),
        _buildContactItem(
          context,
          theme,
          colorScheme,
          icon: Icons.location_on_outlined,
          text: 'Toronto, ON, Canada',
        ),
      ],
    );
  }

  Widget _buildContactItem(BuildContext context, ThemeData theme, ColorScheme colorScheme, {
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: context.isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'Follow Us',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: context.isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            _buildSocialButton(context, colorScheme, Icons.facebook, 'Facebook'),
            const SizedBox(width: 12),
            _buildSocialButton(context, colorScheme, Icons.alternate_email, 'Twitter'),
            const SizedBox(width: 12),
            _buildSocialButton(context, colorScheme, Icons.camera_alt, 'Instagram'),
            const SizedBox(width: 12),
            _buildSocialButton(context, colorScheme, Icons.business, 'LinkedIn'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(BuildContext context, ColorScheme colorScheme, IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          // Handle social media link
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Divider(
          color: colorScheme.outline.withOpacity(0.2),
          thickness: 1,
        ),
        const SizedBox(height: 24),
        ResponsiveWidget(
          mobile: Column(
            children: [
              _buildLegalLinks(context, theme, colorScheme),
              const SizedBox(height: 16),
              _buildCopyright(context, theme, colorScheme),
            ],
          ),
          desktop: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCopyright(context, theme, colorScheme),
              _buildLegalLinks(context, theme, colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegalLinks(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFooterLink(context, theme, colorScheme, 'Privacy Policy', onPrivacyPolicy, isInline: true),
        Text(
          ' • ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        _buildFooterLink(context, theme, colorScheme, 'Terms of Service', onTermsOfService, isInline: true),
        Text(
          ' • ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        _buildFooterLink(context, theme, colorScheme, 'Contact', onContact, isInline: true),
      ],
    );
  }

  Widget _buildCopyright(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Text(
      '© ${DateTime.now().year} RESP Gifts. All rights reserved.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFooterLink(BuildContext context, ThemeData theme, ColorScheme colorScheme, String text, VoidCallback? onTap, {bool isInline = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: isInline ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          text,
          style: (isInline ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
            color: colorScheme.primary,
            decoration: TextDecoration.underline,
            decorationColor: colorScheme.primary.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

/// Minimal footer for compact layouts
class MinimalFooter extends StatelessWidget {
  const MinimalFooter({
    super.key,
    this.onPrivacyPolicy,
    this.onTermsOfService,
  });

  final VoidCallback? onPrivacyPolicy;
  final VoidCallback? onTermsOfService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      color: colorScheme.surfaceVariant.withOpacity(0.3),
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ResponsiveWidget(
            mobile: Column(
              children: [
                Text(
                  '© ${DateTime.now().year} RESP Gifts',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: onPrivacyPolicy,
                      child: Text(
                        'Privacy',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      '•',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: onTermsOfService,
                      child: Text(
                        'Terms',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            desktop: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© ${DateTime.now().year} RESP Gifts. All rights reserved.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: onPrivacyPolicy,
                      child: Text(
                        'Privacy Policy',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onTermsOfService,
                      child: Text(
                        'Terms of Service',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}