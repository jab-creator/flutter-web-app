import 'package:flutter/material.dart';
import '../models/gift_page_model.dart';
import '../utils/form_validators.dart';
import 'theme_selector.dart';

/// Data model for gift page form.
class GiftPageFormData {
  GiftPageFormData({
    this.headline = '',
    this.blurb = '',
    this.theme = GiftPageTheme.defaultTheme,
    this.isPublic = true,
  });

  String headline;
  String blurb;
  GiftPageTheme theme;
  bool isPublic;

  bool get isValid {
    return headline.isNotEmpty && 
           blurb.isNotEmpty &&
           FormValidators.validateHeadline(headline) == null &&
           FormValidators.validateBlurb(blurb) == null;
  }

  GiftPageFormData copyWith({
    String? headline,
    String? blurb,
    GiftPageTheme? theme,
    bool? isPublic,
  }) {
    return GiftPageFormData(
      headline: headline ?? this.headline,
      blurb: blurb ?? this.blurb,
      theme: theme ?? this.theme,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}

/// A form widget for customizing gift page content and appearance.
class GiftPageForm extends StatefulWidget {
  const GiftPageForm({
    super.key,
    required this.onDataChanged,
    this.initialData,
    this.childName = '',
    this.showPreview = true,
    this.showPublicToggle = true,
  });

  /// Callback when form data changes.
  final ValueChanged<GiftPageFormData> onDataChanged;

  /// Initial form data.
  final GiftPageFormData? initialData;

  /// Child's name for generating default content.
  final String childName;

  /// Whether to show live preview.
  final bool showPreview;

  /// Whether to show the public/private toggle.
  final bool showPublicToggle;

  @override
  State<GiftPageForm> createState() => _GiftPageFormState();
}

class _GiftPageFormState extends State<GiftPageForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _headlineController;
  late final TextEditingController _blurbController;
  
  late GiftPageFormData _formData;
  bool _hasGeneratedDefaults = false;

  @override
  void initState() {
    super.initState();
    
    _formData = widget.initialData ?? GiftPageFormData();
    
    // Generate default content if not provided and child name is available
    if (!_hasGeneratedDefaults && widget.childName.isNotEmpty) {
      _generateDefaultContent();
    }
    
    _headlineController = TextEditingController(text: _formData.headline);
    _blurbController = TextEditingController(text: _formData.blurb);
    
    // Set up listeners
    _headlineController.addListener(_onHeadlineChanged);
    _blurbController.addListener(_onBlurbChanged);
  }

  @override
  void didUpdateWidget(GiftPageForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Generate defaults if child name changed and we haven't generated yet
    if (widget.childName != oldWidget.childName && 
        widget.childName.isNotEmpty && 
        !_hasGeneratedDefaults) {
      _generateDefaultContent();
    }
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _blurbController.dispose();
    super.dispose();
  }

  void _generateDefaultContent() {
    if (widget.childName.isEmpty) return;
    
    final name = widget.childName;
    final defaultHeadline = "Help $name's RESP grow";
    final defaultBlurb = "Instead of toys that get forgotten, give $name a gift that will help their future education. Every contribution goes directly into their Registered Education Savings Plan (RESP).";
    
    setState(() {
      _formData = _formData.copyWith(
        headline: _formData.headline.isEmpty ? defaultHeadline : _formData.headline,
        blurb: _formData.blurb.isEmpty ? defaultBlurb : _formData.blurb,
      );
      _hasGeneratedDefaults = true;
    });
    
    _headlineController.text = _formData.headline;
    _blurbController.text = _formData.blurb;
    
    _notifyDataChanged();
  }

  void _onHeadlineChanged() {
    _formData = _formData.copyWith(headline: _headlineController.text);
    _notifyDataChanged();
  }

  void _onBlurbChanged() {
    _formData = _formData.copyWith(blurb: _blurbController.text);
    _notifyDataChanged();
  }

  void _onThemeChanged(GiftPageTheme theme) {
    setState(() {
      _formData = _formData.copyWith(theme: theme);
    });
    _notifyDataChanged();
  }

  void _onPublicToggleChanged(bool isPublic) {
    setState(() {
      _formData = _formData.copyWith(isPublic: isPublic);
    });
    _notifyDataChanged();
  }

  void _notifyDataChanged() {
    widget.onDataChanged(_formData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Form(
      key: _formKey,
      child: widget.showPreview 
          ? _buildWithPreview(theme)
          : _buildFormOnly(theme),
    );
  }

  Widget _buildWithPreview(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form section
        Expanded(
          flex: 1,
          child: _buildFormOnly(theme),
        ),
        
        const SizedBox(width: 32),
        
        // Preview section
        Expanded(
          flex: 1,
          child: _buildPreview(theme),
        ),
      ],
    );
  }

  Widget _buildFormOnly(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Customize your gift page',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create compelling content that will encourage people to contribute to ${widget.childName.isNotEmpty ? "${widget.childName}'s" : "your child's"} education fund.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        
        // Headline
        TextFormField(
          controller: _headlineController,
          decoration: const InputDecoration(
            labelText: 'Headline *',
            hintText: 'Help Emma\'s RESP grow',
            border: OutlineInputBorder(),
            helperText: 'A compelling headline that explains the purpose',
          ),
          maxLength: 100,
          validator: FormValidators.validateHeadline,
        ),
        const SizedBox(height: 16),
        
        // Blurb/Description
        TextFormField(
          controller: _blurbController,
          decoration: const InputDecoration(
            labelText: 'Description *',
            hintText: 'Instead of toys that get forgotten, give a gift that will help their future education...',
            border: OutlineInputBorder(),
            helperText: 'Explain why people should contribute to the RESP',
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          maxLength: 500,
          validator: FormValidators.validateBlurb,
        ),
        const SizedBox(height: 24),
        
        // Theme Selection
        Text(
          'Choose a Theme',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a visual theme that matches your style.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        
        ThemeSelector(
          selectedTheme: _formData.theme,
          onThemeChanged: _onThemeChanged,
          showPreview: false, // We have our own preview
          previewChildName: widget.childName,
          previewHeadline: _formData.headline,
          previewBlurb: _formData.blurb,
        ),
        
        // Public/Private Toggle
        if (widget.showPublicToggle) ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _formData.isPublic ? Icons.public : Icons.lock,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Page Visibility',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: Text(_formData.isPublic ? 'Public' : 'Private'),
                    subtitle: Text(
                      _formData.isPublic 
                          ? 'Anyone with the link can view and contribute to this page'
                          : 'Only you can view this page (gifts disabled)',
                    ),
                    value: _formData.isPublic,
                    onChanged: _onPublicToggleChanged,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPreview(ThemeData theme) {
    final themeConfig = GiftPageThemeConfig.getConfig(_formData.theme);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview header
        Row(
          children: [
            Icon(
              Icons.preview,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Live Preview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Preview container
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 400),
          decoration: BoxDecoration(
            color: themeConfig.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeConfig.primaryColor.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Child name badge
                if (widget.childName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: themeConfig.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.childName,
                      style: TextStyle(
                        color: themeConfig.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Headline
                Text(
                  _formData.headline.isEmpty 
                      ? 'Your headline will appear here'
                      : _formData.headline,
                  style: TextStyle(
                    color: themeConfig.textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Blurb
                Text(
                  _formData.blurb.isEmpty 
                      ? 'Your description will appear here. This is where you explain why people should contribute to the RESP.'
                      : _formData.blurb,
                  style: TextStyle(
                    color: themeConfig.textColor.withOpacity(0.8),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Mock progress indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeConfig.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: TextStyle(
                              color: themeConfig.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '\$1,250 of \$5,000',
                            style: TextStyle(
                              color: themeConfig.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.25,
                        backgroundColor: themeConfig.primaryColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(themeConfig.primaryColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Mock gift buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildMockGiftButton('\$25', themeConfig),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMockGiftButton('\$50', themeConfig),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMockGiftButton('\$100', themeConfig),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Custom amount button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeConfig.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Custom Amount'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMockGiftButton(String amount, GiftPageThemeConfig themeConfig) {
    return OutlinedButton(
      onPressed: null,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: themeConfig.primaryColor),
        foregroundColor: themeConfig.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(amount),
    );
  }
}

/// Compact version of the gift page form without preview.
class CompactGiftPageForm extends StatelessWidget {
  const CompactGiftPageForm({
    super.key,
    required this.onDataChanged,
    this.initialData,
    this.childName = '',
  });

  final ValueChanged<GiftPageFormData> onDataChanged;
  final GiftPageFormData? initialData;
  final String childName;

  @override
  Widget build(BuildContext context) {
    return GiftPageForm(
      onDataChanged: onDataChanged,
      initialData: initialData,
      childName: childName,
      showPreview: false,
      showPublicToggle: false,
    );
  }
}