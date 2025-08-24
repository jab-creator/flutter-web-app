import 'package:flutter/material.dart';
import '../models/gift_page_model.dart';

/// Theme configuration for gift page themes.
class GiftPageThemeConfig {
  const GiftPageThemeConfig({
    required this.theme,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    this.accentColor,
  });

  final GiftPageTheme theme;
  final String name;
  final String description;
  final Color primaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;
  final Color? accentColor;

  static const List<GiftPageThemeConfig> allThemes = [
    GiftPageThemeConfig(
      theme: GiftPageTheme.defaultTheme,
      name: 'Classic',
      description: 'Clean and professional look',
      primaryColor: Color(0xFF1976D2),
      backgroundColor: Color(0xFFF5F5F5),
      cardColor: Colors.white,
      textColor: Color(0xFF212121),
      accentColor: Color(0xFF42A5F5),
    ),
    GiftPageThemeConfig(
      theme: GiftPageTheme.soft,
      name: 'Soft',
      description: 'Gentle and warm colors',
      primaryColor: Color(0xFFE91E63),
      backgroundColor: Color(0xFFFCE4EC),
      cardColor: Color(0xFFF8BBD9),
      textColor: Color(0xFF880E4F),
      accentColor: Color(0xFFF06292),
    ),
    GiftPageThemeConfig(
      theme: GiftPageTheme.bold,
      name: 'Bold',
      description: 'Vibrant and energetic',
      primaryColor: Color(0xFFFF5722),
      backgroundColor: Color(0xFFFFF3E0),
      cardColor: Color(0xFFFFCC02),
      textColor: Color(0xFFBF360C),
      accentColor: Color(0xFFFF9800),
    ),
  ];

  static GiftPageThemeConfig getConfig(GiftPageTheme theme) {
    return allThemes.firstWhere(
      (config) => config.theme == theme,
      orElse: () => allThemes.first,
    );
  }
}

/// A widget for selecting gift page themes with visual previews.
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({
    super.key,
    required this.selectedTheme,
    required this.onThemeChanged,
    this.showPreview = true,
    this.previewChildName = 'Emma',
    this.previewHeadline = 'Help Emma\'s RESP grow',
    this.previewBlurb = 'Instead of toys that get forgotten, give Emma a gift that will help her future education.',
  });

  /// Currently selected theme.
  final GiftPageTheme selectedTheme;

  /// Callback when theme selection changes.
  final ValueChanged<GiftPageTheme> onThemeChanged;

  /// Whether to show theme previews.
  final bool showPreview;

  /// Child name for preview.
  final String previewChildName;

  /// Headline for preview.
  final String previewHeadline;

  /// Blurb for preview.
  final String previewBlurb;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Theme selection cards
        ...GiftPageThemeConfig.allThemes.map((themeConfig) {
          final isSelected = themeConfig.theme == selectedTheme;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ThemeCard(
              config: themeConfig,
              isSelected: isSelected,
              onTap: () => onThemeChanged(themeConfig.theme),
              showPreview: showPreview,
              previewChildName: previewChildName,
              previewHeadline: previewHeadline,
              previewBlurb: previewBlurb,
            ),
          );
        }).toList(),
      ],
    );
  }
}

/// Individual theme selection card with preview.
class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.config,
    required this.isSelected,
    required this.onTap,
    required this.showPreview,
    required this.previewChildName,
    required this.previewHeadline,
    required this.previewBlurb,
  });

  final GiftPageThemeConfig config;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showPreview;
  final String previewChildName;
  final String previewHeadline;
  final String previewBlurb;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme info header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                    : null,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
              ),
              child: Row(
                children: [
                  // Theme color indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: config.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Theme name and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          config.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Selection indicator
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                ],
              ),
            ),
            
            // Theme preview
            if (showPreview)
              Container(
                padding: const EdgeInsets.all(16),
                child: _ThemePreview(
                  config: config,
                  childName: previewChildName,
                  headline: previewHeadline,
                  blurb: previewBlurb,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Preview of how the theme will look on a gift page.
class _ThemePreview extends StatelessWidget {
  const _ThemePreview({
    required this.config,
    required this.childName,
    required this.headline,
    required this.blurb,
  });

  final GiftPageThemeConfig config;
  final String childName;
  final String headline;
  final String blurb;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: config.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Stack(
        children: [
          // Background pattern or gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  config.backgroundColor,
                  config.backgroundColor.withOpacity(0.8),
                ],
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Child name
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: config.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    childName,
                    style: TextStyle(
                      color: config.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Headline
                Text(
                  headline,
                  style: TextStyle(
                    color: config.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Blurb
                Text(
                  blurb,
                  style: TextStyle(
                    color: config.textColor.withOpacity(0.8),
                    fontSize: 12,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                
                // Mock gift button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: config.primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Give a Gift',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact theme selector showing only theme names.
class CompactThemeSelector extends StatelessWidget {
  const CompactThemeSelector({
    super.key,
    required this.selectedTheme,
    required this.onThemeChanged,
  });

  final GiftPageTheme selectedTheme;
  final ValueChanged<GiftPageTheme> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Wrap(
      spacing: 12,
      children: GiftPageThemeConfig.allThemes.map((themeConfig) {
        final isSelected = themeConfig.theme == selectedTheme;
        
        return FilterChip(
          label: Text(themeConfig.name),
          selected: isSelected,
          onSelected: (_) => onThemeChanged(themeConfig.theme),
          backgroundColor: themeConfig.primaryColor.withOpacity(0.1),
          selectedColor: themeConfig.primaryColor.withOpacity(0.2),
          checkmarkColor: themeConfig.primaryColor,
          side: BorderSide(
            color: isSelected 
                ? themeConfig.primaryColor 
                : themeConfig.primaryColor.withOpacity(0.3),
          ),
        );
      }).toList(),
    );
  }
}