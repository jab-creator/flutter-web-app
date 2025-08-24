import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/child_model.dart';
import '../models/gift_page_model.dart';
import '../models/slug_index_model.dart';
import '../services/firestore_service.dart';
import '../services/slug_service.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/child_form.dart';
import '../widgets/gift_page_form.dart';
import '../utils/responsive_helper.dart';

/// Onboarding flow steps.
enum OnboardingStep {
  childInfo(1, 'Child Info'),
  giftPage(2, 'Gift Page'),
  review(3, 'Review');

  const OnboardingStep(this.number, this.label);
  final int number;
  final String label;

  static List<String> get labels => OnboardingStep.values.map((e) => e.label).toList();
}

/// State for the onboarding process.
enum OnboardingState {
  editing,
  submitting,
  completed,
  error,
}

/// Multi-step onboarding screen for creating child profile and gift page.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final FirestoreService _firestoreService = FirestoreService();
  final SlugService _slugService = SlugService();
  
  OnboardingStep _currentStep = OnboardingStep.childInfo;
  OnboardingState _state = OnboardingState.editing;
  
  ChildFormData _childData = ChildFormData();
  GiftPageFormData _giftPageData = GiftPageFormData();
  
  String? _errorMessage;
  bool _canProceedFromStep1 = false;
  bool _canProceedFromStep2 = false;

  @override
  void dispose() {
    _pageController.dispose();
    _slugService.dispose();
    super.dispose();
  }

  void _onChildDataChanged(ChildFormData data) {
    setState(() {
      _childData = data;
      _canProceedFromStep1 = data.isValid;
    });
    
    // Update gift page form with child name for better defaults
    if (data.firstName.isNotEmpty && _giftPageData.headline.isEmpty) {
      // This will trigger default content generation in the gift page form
      setState(() {});
    }
  }

  void _onGiftPageDataChanged(GiftPageFormData data) {
    setState(() {
      _giftPageData = data;
      _canProceedFromStep2 = data.isValid;
    });
  }

  Future<void> _nextStep() async {
    if (_currentStep == OnboardingStep.review) {
      await _submitOnboarding();
      return;
    }

    final nextStepIndex = _currentStep.number;
    if (nextStepIndex < OnboardingStep.values.length) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep = OnboardingStep.values[nextStepIndex];
      });
    }
  }

  Future<void> _previousStep() async {
    if (_currentStep.number > 1) {
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep = OnboardingStep.values[_currentStep.number - 2];
      });
    }
  }

  Future<void> _submitOnboarding() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _state = OnboardingState.error;
        _errorMessage = 'User not authenticated. Please log in again.';
      });
      return;
    }

    setState(() {
      _state = OnboardingState.submitting;
      _errorMessage = null;
    });

    try {
      // Create child record
      final child = Child(
        id: '', // Will be set by Firestore
        userId: user.uid,
        firstName: _childData.firstName,
        lastName: _childData.lastName.isEmpty ? null : _childData.lastName,
        dob: _childData.dob,
        slug: _childData.slug,
        heroPhotoUrl: _childData.heroPhotoUrl,
        goalCad: _childData.goalCad,
        createdAt: DateTime.now(),
      );

      final createdChild = await _firestoreService.createChild(child);

      // Create gift page record
      final giftPage = GiftPage(
        id: '', // Will be set by Firestore
        childId: createdChild.id,
        headline: _giftPageData.headline,
        blurb: _giftPageData.blurb,
        theme: _giftPageData.theme,
        isPublic: _giftPageData.isPublic,
      );

      await _firestoreService.createGiftPage(giftPage);

      setState(() {
        _state = OnboardingState.completed;
      });

      // Navigate to dashboard or success page after a brief delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/app');
        }
      });

    } catch (e) {
      setState(() {
        _state = OnboardingState.error;
        _errorMessage = 'Failed to create child profile: ${e.toString()}';
      });
    }
  }

  bool _canProceedFromCurrentStep() {
    switch (_currentStep) {
      case OnboardingStep.childInfo:
        return _canProceedFromStep1;
      case OnboardingStep.giftPage:
        return _canProceedFromStep2;
      case OnboardingStep.review:
        return true;
    }
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case OnboardingStep.childInfo:
        return 'Continue to Gift Page';
      case OnboardingStep.giftPage:
        return 'Review & Create';
      case OnboardingStep.review:
        return _state == OnboardingState.submitting 
            ? 'Creating...' 
            : 'Create Gift Page';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Child\'s Gift Page'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: EdgeInsets.all(isDesktop ? 32 : 16),
            child: OnboardingProgressIndicator(
              currentStep: _currentStep.number,
              totalSteps: OnboardingStep.values.length,
              stepLabels: OnboardingStep.labels,
              showLabels: isDesktop,
            ),
          ),
          
          // Main content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildChildInfoStep(),
                _buildGiftPageStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(theme, isDesktop),
        ],
      ),
    );
  }

  Widget _buildChildInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ChildForm(
            onDataChanged: _onChildDataChanged,
            initialData: _childData,
            slugService: _slugService,
          ),
        ),
      ),
    );
  }

  Widget _buildGiftPageStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: GiftPageForm(
            onDataChanged: _onGiftPageDataChanged,
            initialData: _giftPageData,
            childName: _childData.firstName,
            showPreview: ResponsiveHelper.isDesktop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Review and Create',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please review the information below before creating your child\'s gift page.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              
              // Child Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.child_care,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Child Information',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildReviewItem('Name', _childData.firstName + 
                          (_childData.lastName.isNotEmpty ? ' ${_childData.lastName}' : '')),
                      
                      if (_childData.dob != null)
                        _buildReviewItem('Date of Birth', 
                            '${_childData.dob!.day}/${_childData.dob!.month}/${_childData.dob!.year}'),
                      
                      _buildReviewItem('Gift Page URL', 'respgift.com/for/${_childData.slug}'),
                      
                      if (_childData.goalCad != null)
                        _buildReviewItem('Savings Goal', '\$${_childData.goalCad!.toStringAsFixed(0)} CAD'),
                      
                      if (_childData.heroPhotoUrl != null)
                        _buildReviewItem('Hero Photo', 'Uploaded ✓'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Gift Page Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Gift Page Settings',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildReviewItem('Headline', _giftPageData.headline),
                      _buildReviewItem('Description', _giftPageData.blurb, maxLines: 3),
                      _buildReviewItem('Theme', _giftPageData.theme.value.toUpperCase()),
                      _buildReviewItem('Visibility', _giftPageData.isPublic ? 'Public' : 'Private'),
                    ],
                  ),
                ),
              ),
              
              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: theme.colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              // Success message
              if (_state == OnboardingState.completed) ...[
                const SizedBox(height: 16),
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Gift page created successfully! Redirecting to your dashboard...',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value, {int maxLines = 1}) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(ThemeData theme, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          if (_currentStep.number > 1)
            OutlinedButton(
              onPressed: _state == OnboardingState.submitting ? null : _previousStep,
              child: const Text('Back'),
            )
          else
            const SizedBox.shrink(),
          
          const Spacer(),
          
          // Next/Submit button
          ElevatedButton(
            onPressed: _canProceedFromCurrentStep() && _state != OnboardingState.submitting
                ? _nextStep
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_state == OnboardingState.submitting) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(_getNextButtonText()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}