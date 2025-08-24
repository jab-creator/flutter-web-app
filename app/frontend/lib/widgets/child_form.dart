import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../utils/form_validators.dart';
import '../services/slug_service.dart';
import 'slug_input.dart';
import 'photo_upload.dart';

/// Data model for child form.
class ChildFormData {
  ChildFormData({
    this.firstName = '',
    this.lastName = '',
    this.dob,
    this.slug = '',
    this.heroPhotoUrl,
    this.goalCad,
  });

  String firstName;
  String lastName;
  DateTime? dob;
  String slug;
  String? heroPhotoUrl;
  double? goalCad;

  bool get isValid {
    return firstName.isNotEmpty && 
           slug.isNotEmpty &&
           FormValidators.validateFirstName(firstName) == null &&
           FormValidators.validateLastName(lastName) == null &&
           FormValidators.validateDateOfBirth(dob) == null &&
           FormValidators.validateSlug(slug) == null &&
           (goalCad == null || FormValidators.validateGoalAmount(goalCad.toString()) == null);
  }

  ChildFormData copyWith({
    String? firstName,
    String? lastName,
    DateTime? dob,
    String? slug,
    String? heroPhotoUrl,
    double? goalCad,
  }) {
    return ChildFormData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dob: dob ?? this.dob,
      slug: slug ?? this.slug,
      heroPhotoUrl: heroPhotoUrl ?? this.heroPhotoUrl,
      goalCad: goalCad ?? this.goalCad,
    );
  }
}

/// A form widget for collecting child information during onboarding.
class ChildForm extends StatefulWidget {
  const ChildForm({
    super.key,
    required this.onDataChanged,
    this.initialData,
    this.slugService,
    this.showPhotoUpload = true,
    this.showGoalAmount = true,
    this.autoGenerateSlug = true,
  });

  /// Callback when form data changes.
  final ValueChanged<ChildFormData> onDataChanged;

  /// Initial form data.
  final ChildFormData? initialData;

  /// Service for slug validation.
  final SlugService? slugService;

  /// Whether to show photo upload section.
  final bool showPhotoUpload;

  /// Whether to show goal amount field.
  final bool showGoalAmount;

  /// Whether to auto-generate slug from first name.
  final bool autoGenerateSlug;

  @override
  State<ChildForm> createState() => _ChildFormState();
}

class _ChildFormState extends State<ChildForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _dobController;
  late final TextEditingController _goalController;
  
  late ChildFormData _formData;
  late final SlugService _slugService;
  
  bool _isSlugValid = false;
  bool _hasUserEditedSlug = false;

  @override
  void initState() {
    super.initState();
    
    _formData = widget.initialData ?? ChildFormData();
    _slugService = widget.slugService ?? SlugService();
    
    _firstNameController = TextEditingController(text: _formData.firstName);
    _lastNameController = TextEditingController(text: _formData.lastName);
    _dobController = TextEditingController(
      text: _formData.dob != null 
          ? DateFormat('yyyy-MM-dd').format(_formData.dob!)
          : '',
    );
    _goalController = TextEditingController(
      text: _formData.goalCad?.toString() ?? '',
    );
    
    // Set up listeners
    _firstNameController.addListener(_onFirstNameChanged);
    _lastNameController.addListener(_onLastNameChanged);
    _goalController.addListener(_onGoalChanged);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _goalController.dispose();
    _slugService.dispose();
    super.dispose();
  }

  void _onFirstNameChanged() {
    final firstName = FormValidators.formatName(_firstNameController.text);
    _formData = _formData.copyWith(firstName: firstName);
    
    // Auto-generate slug if user hasn't manually edited it
    if (widget.autoGenerateSlug && !_hasUserEditedSlug && firstName.isNotEmpty) {
      final baseSlug = _slugService.generateBaseSlug(firstName);
      _formData = _formData.copyWith(slug: baseSlug);
    }
    
    _notifyDataChanged();
  }

  void _onLastNameChanged() {
    final lastName = FormValidators.formatName(_lastNameController.text);
    _formData = _formData.copyWith(lastName: lastName);
    _notifyDataChanged();
  }

  void _onGoalChanged() {
    final goalText = _goalController.text;
    final goal = goalText.isEmpty ? null : double.tryParse(goalText);
    _formData = _formData.copyWith(goalCad: goal);
    _notifyDataChanged();
  }

  void _onSlugChanged(String slug) {
    _hasUserEditedSlug = true;
    _formData = _formData.copyWith(slug: slug);
    _notifyDataChanged();
  }

  void _onSlugValidationChanged(bool isValid) {
    setState(() {
      _isSlugValid = isValid;
    });
  }

  void _onDateOfBirthChanged(DateTime? date) {
    _formData = _formData.copyWith(dob: date);
    _dobController.text = date != null 
        ? DateFormat('yyyy-MM-dd').format(date)
        : '';
    _notifyDataChanged();
  }

  void _onPhotoUploaded(String photoUrl) {
    _formData = _formData.copyWith(heroPhotoUrl: photoUrl);
    _notifyDataChanged();
  }

  void _onPhotoRemoved() {
    _formData = _formData.copyWith(heroPhotoUrl: null);
    _notifyDataChanged();
  }

  void _notifyDataChanged() {
    widget.onDataChanged(_formData);
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = _formData.dob ?? DateTime(now.year - 5, now.month, now.day);
    
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 18, now.month, now.day),
      lastDate: now,
      helpText: 'Select date of birth',
      fieldLabelText: 'Date of birth',
    );
    
    if (selectedDate != null) {
      _onDateOfBirthChanged(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Tell us about your child',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll use this information to create their personalized gift page.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          
          // First Name (Required)
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name *',
              hintText: 'Enter your child\'s first name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: FormValidators.validateFirstName,
            onChanged: (value) {
              // Formatting is handled in the listener
            },
          ),
          const SizedBox(height: 16),
          
          // Last Name (Optional)
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name',
              hintText: 'Enter your child\'s last name (optional)',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: FormValidators.validateLastName,
          ),
          const SizedBox(height: 16),
          
          // Date of Birth (Optional)
          TextFormField(
            controller: _dobController,
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              hintText: 'Select date of birth (optional)',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _selectDateOfBirth,
              ),
            ),
            readOnly: true,
            onTap: _selectDateOfBirth,
            validator: (value) {
              return FormValidators.validateDateOfBirth(_formData.dob);
            },
          ),
          const SizedBox(height: 24),
          
          // URL Slug Section
          Text(
            'Gift Page URL',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This will be the web address where people can give gifts to your child.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          
          SlugInput(
            initialValue: _formData.slug,
            onChanged: _onSlugChanged,
            onValidationChanged: _onSlugValidationChanged,
            slugService: _slugService,
            decoration: const InputDecoration(
              labelText: 'URL Slug *',
              hintText: 'your-childs-name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          
          // Goal Amount (Optional)
          if (widget.showGoalAmount) ...[
            Text(
              'Savings Goal',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set a target amount for your child\'s RESP (optional).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _goalController,
              decoration: const InputDecoration(
                labelText: 'Goal Amount (CAD)',
                hintText: '5000',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) => FormValidators.validateGoalAmount(value),
            ),
            const SizedBox(height: 24),
          ],
          
          // Photo Upload (Optional)
          if (widget.showPhotoUpload) ...[
            Text(
              'Hero Photo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a photo to make the gift page more personal and engaging.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            
            PhotoUpload(
              initialPhotoUrl: _formData.heroPhotoUrl,
              onPhotoUploaded: _onPhotoUploaded,
              onPhotoRemoved: _onPhotoRemoved,
              width: 200,
              height: 150,
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact version of the child form for smaller spaces.
class CompactChildForm extends StatelessWidget {
  const CompactChildForm({
    super.key,
    required this.onDataChanged,
    this.initialData,
    this.slugService,
  });

  final ValueChanged<ChildFormData> onDataChanged;
  final ChildFormData? initialData;
  final SlugService? slugService;

  @override
  Widget build(BuildContext context) {
    return ChildForm(
      onDataChanged: onDataChanged,
      initialData: initialData,
      slugService: slugService,
      showPhotoUpload: false,
      showGoalAmount: false,
      autoGenerateSlug: true,
    );
  }
}