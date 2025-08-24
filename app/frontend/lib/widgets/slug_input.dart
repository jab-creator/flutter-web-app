import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/slug_service.dart';
import '../utils/form_validators.dart';

/// Validation state for slug input.
enum SlugValidationState {
  initial,
  checking,
  available,
  unavailable,
  invalid,
  error,
}

/// A specialized text input widget for URL slugs with real-time validation.
class SlugInput extends StatefulWidget {
  const SlugInput({
    super.key,
    required this.onChanged,
    this.initialValue,
    this.enabled = true,
    this.decoration,
    this.slugService,
    this.showPreview = true,
    this.baseUrl = 'respgift.com/for/',
    this.onValidationChanged,
  });

  /// Callback when the slug value changes.
  final ValueChanged<String> onChanged;

  /// Initial value for the slug input.
  final String? initialValue;

  /// Whether the input is enabled.
  final bool enabled;

  /// Input decoration for the text field.
  final InputDecoration? decoration;

  /// Service for slug validation (optional, will create default if not provided).
  final SlugService? slugService;

  /// Whether to show the URL preview.
  final bool showPreview;

  /// Base URL for the preview.
  final String baseUrl;

  /// Callback when validation state changes.
  final ValueChanged<bool>? onValidationChanged;

  @override
  State<SlugInput> createState() => _SlugInputState();
}

class _SlugInputState extends State<SlugInput> {
  late final TextEditingController _controller;
  late final SlugService _slugService;
  
  SlugValidationState _validationState = SlugValidationState.initial;
  String? _errorMessage;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _slugService = widget.slugService ?? SlugService();
    
    // Set up listener for real-time validation
    _controller.addListener(_onTextChanged);
    
    // Validate initial value if provided
    if (widget.initialValue?.isNotEmpty == true) {
      _validateSlug(widget.initialValue!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _slugService.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final value = _controller.text;
    widget.onChanged(value);
    
    if (value.isEmpty) {
      setState(() {
        _validationState = SlugValidationState.initial;
        _errorMessage = null;
        _suggestions.clear();
      });
      widget.onValidationChanged?.call(false);
      return;
    }
    
    _validateSlug(value);
  }

  Future<void> _validateSlug(String slug) async {
    // Format the slug
    final formattedSlug = FormValidators.formatSlug(slug);
    
    // Update controller if formatting changed
    if (formattedSlug != slug && formattedSlug.isNotEmpty) {
      final selection = _controller.selection;
      _controller.value = TextEditingValue(
        text: formattedSlug,
        selection: TextSelection.collapsed(
          offset: selection.baseOffset.clamp(0, formattedSlug.length),
        ),
      );
      return; // This will trigger another validation
    }
    
    // Validate format first
    final formatError = FormValidators.validateSlug(formattedSlug);
    if (formatError != null) {
      setState(() {
        _validationState = SlugValidationState.invalid;
        _errorMessage = formatError;
        _suggestions.clear();
      });
      widget.onValidationChanged?.call(false);
      return;
    }
    
    // Check availability
    setState(() {
      _validationState = SlugValidationState.checking;
      _errorMessage = null;
      _suggestions.clear();
    });
    
    try {
      final isAvailable = await _slugService.checkSlugAvailabilityDebounced(formattedSlug);
      
      if (mounted) {
        if (isAvailable) {
          setState(() {
            _validationState = SlugValidationState.available;
            _errorMessage = null;
            _suggestions.clear();
          });
          widget.onValidationChanged?.call(true);
        } else {
          // Get suggestions for unavailable slug
          final suggestions = await _slugService.suggestAlternativeSlugs(formattedSlug);
          
          if (mounted) {
            setState(() {
              _validationState = SlugValidationState.unavailable;
              _errorMessage = 'This URL is already taken';
              _suggestions = suggestions;
            });
            widget.onValidationChanged?.call(false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _validationState = SlugValidationState.error;
          _errorMessage = 'Unable to check availability. Please try again.';
          _suggestions.clear();
        });
        widget.onValidationChanged?.call(false);
      }
    }
  }

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    // The listener will handle validation
  }

  Color _getValidationColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (_validationState) {
      case SlugValidationState.available:
        return colorScheme.primary;
      case SlugValidationState.unavailable:
      case SlugValidationState.invalid:
      case SlugValidationState.error:
        return colorScheme.error;
      case SlugValidationState.checking:
        return colorScheme.outline;
      case SlugValidationState.initial:
        return colorScheme.outline;
    }
  }

  Widget _buildValidationIcon() {
    switch (_validationState) {
      case SlugValidationState.checking:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SlugValidationState.available:
        return Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        );
      case SlugValidationState.unavailable:
      case SlugValidationState.invalid:
      case SlugValidationState.error:
        return Icon(
          Icons.error,
          color: Theme.of(context).colorScheme.error,
          size: 20,
        );
      case SlugValidationState.initial:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main input field
        TextFormField(
          controller: _controller,
          enabled: widget.enabled,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9\-]')),
            LowerCaseTextFormatter(),
          ],
          decoration: (widget.decoration ?? const InputDecoration()).copyWith(
            suffixIcon: _buildValidationIcon(),
            errorText: _errorMessage,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: _getValidationColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _getValidationColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _getValidationColor(context),
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (_validationState == SlugValidationState.invalid ||
                _validationState == SlugValidationState.unavailable ||
                _validationState == SlugValidationState.error) {
              return _errorMessage;
            }
            return null;
          },
        ),
        
        // URL Preview
        if (widget.showPreview && _controller.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.link,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.baseUrl}${_controller.text}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Validation message
        if (_validationState == SlugValidationState.available) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'This URL is available!',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
        
        // Suggestions
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Suggestions:',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                onPressed: () => _selectSuggestion(suggestion),
                backgroundColor: colorScheme.surfaceVariant,
                side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

/// Text formatter that converts input to lowercase.
class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}