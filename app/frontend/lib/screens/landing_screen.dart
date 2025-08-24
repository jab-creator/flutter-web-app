import 'package:flutter/material.dart';
import '../widgets/landing/hero_section.dart';
import '../widgets/landing/features_section.dart';
import '../widgets/landing/how_it_works_section.dart';
import '../widgets/landing/cta_section.dart';
import '../widgets/footer.dart';
import '../utils/responsive_helper.dart';

/// Main landing screen for the RESP Gift Platform.
///
/// Combines all landing page sections in a responsive layout
/// that provides an engaging first impression for visitors.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: _buildScrollToTopButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Row(
        children: [
          Icon(
            Icons.school_outlined,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'RESP Gifts',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        if (!context.isMobile) ...[
          TextButton(
            onPressed: () => _scrollToSection('features'),
            child: const Text('Features'),
          ),
          TextButton(
            onPressed: () => _scrollToSection('how-it-works'),
            child: const Text('How It Works'),
          ),
          TextButton(
            onPressed: _handleLogin,
            child: const Text('Login'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _handleGetStarted,
            child: const Text('Get Started'),
          ),
          const SizedBox(width: 16),
        ] else ...[
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'features',
                child: Text('Features'),
              ),
              const PopupMenuItem(
                value: 'how-it-works',
                child: Text('How It Works'),
              ),
              const PopupMenuItem(
                value: 'login',
                child: Text('Login'),
              ),
              const PopupMenuItem(
                value: 'get-started',
                child: Text('Get Started'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // Hero Section
          DecoratedHeroSection(
            onGetStarted: _handleGetStarted,
            onLearnMore: () => _scrollToSection('features'),
          ),

          // Features Section
          _buildSection(
            key: 'features',
            child: const FeaturesSection(),
          ),

          // How It Works Section
          _buildSection(
            key: 'how-it-works',
            child: const HowItWorksSection(),
          ),

          // CTA Section
          CtaSection(
            onGetStarted: _handleGetStarted,
            onLearnMore: () => _scrollToSection('features'),
          ),

          // Footer
          Footer(
            onPrivacyPolicy: _handlePrivacyPolicy,
            onTermsOfService: _handleTermsOfService,
            onContact: _handleContact,
            onAbout: _handleAbout,
            onHelp: _handleHelp,
            onBlog: _handleBlog,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String key, required Widget child}) {
    return Container(
      key: ValueKey(key),
      child: child,
    );
  }

  Widget? _buildScrollToTopButton(BuildContext context) {
    // Show button if scrolled more than 500 pixels
    final showButton =
        _scrollController.hasClients && _scrollController.offset > 500;

    if (!showButton) return null;

    return FloatingActionButton(
      onPressed: _scrollToTop,
      mini: true,
      tooltip: 'Scroll to top',
      child: const Icon(Icons.keyboard_arrow_up),
    );
  }

  void _scrollToSection(String sectionKey) {
    final context = this.context;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Find the section by key
    final sectionContext = context.findAncestorWidgetOfExactType<Container>();
    if (sectionContext == null) return;

    // Calculate approximate scroll position based on section
    double targetOffset = 0;
    switch (sectionKey) {
      case 'features':
        targetOffset = MediaQuery.of(context).size.height * 0.8;
        break;
      case 'how-it-works':
        targetOffset = MediaQuery.of(context).size.height * 1.6;
        break;
      default:
        targetOffset = 0;
    }

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'features':
        _scrollToSection('features');
        break;
      case 'how-it-works':
        _scrollToSection('how-it-works');
        break;
      case 'login':
        _handleLogin();
        break;
      case 'get-started':
        _handleGetStarted();
        break;
    }
  }

  void _handleGetStarted() {
    // Navigate to signup screen
    Navigator.of(context).pushNamed('/signup');
  }

  void _handleLogin() {
    // Navigate to login screen
    Navigator.of(context).pushNamed('/login');
  }

  void _handlePrivacyPolicy() {
    // Navigate to privacy policy or show dialog
    _showInfoDialog(
      context,
      'Privacy Policy',
      'Our privacy policy outlines how we collect, use, and protect your personal information. We are committed to maintaining the highest standards of data protection and transparency.',
    );
  }

  void _handleTermsOfService() {
    // Navigate to terms of service or show dialog
    _showInfoDialog(
      context,
      'Terms of Service',
      'Our terms of service outline the rules and regulations for using the RESP Gifts platform. By using our service, you agree to these terms.',
    );
  }

  void _handleContact() {
    // Navigate to contact page or show contact info
    _showInfoDialog(
      context,
      'Contact Us',
      'Get in touch with our support team:\n\nEmail: support@respgifts.ca\nPhone: 1-800-RESP-GIFT\n\nWe\'re here to help Monday through Friday, 9 AM to 5 PM EST.',
    );
  }

  void _handleAbout() {
    // Navigate to about page or show info
    _showInfoDialog(
      context,
      'About RESP Gifts',
      'RESP Gifts makes it easy for Canadian families to give meaningful educational gifts through Registered Education Savings Plans (RESPs). Our platform helps children build their future with tax-free growth and government matching.',
    );
  }

  void _handleHelp() {
    // Navigate to help center or show help info
    _showInfoDialog(
      context,
      'Help Center',
      'Need help getting started?\n\n• Check our FAQ section\n• Watch our tutorial videos\n• Contact our support team\n• Browse our knowledge base\n\nWe\'re committed to making RESP gifts simple and accessible for everyone.',
    );
  }

  void _handleBlog() {
    // Navigate to blog or show coming soon
    _showInfoDialog(
      context,
      'Blog',
      'Our blog is coming soon! We\'ll share tips on RESP planning, education savings strategies, and platform updates. Stay tuned for valuable insights on building your child\'s education fund.',
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Compact landing screen for mobile-first experiences
class CompactLandingScreen extends StatelessWidget {
  const CompactLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.school_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('RESP Gifts'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/login'),
            child: const Text('Login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Compact Hero
            HeroSection(
              onGetStarted: () => Navigator.of(context).pushNamed('/signup'),
              onLearnMore: () {
                // Show features bottom sheet
                _showFeaturesBottomSheet(context);
              },
            ),

            // Compact Features
            const CompactFeaturesSection(),

            // Simple How It Works
            const SimpleHowItWorksSection(),

            // Compact CTA
            CompactCtaSection(
              onGetStarted: () => Navigator.of(context).pushNamed('/signup'),
            ),

            // Minimal Footer
            const MinimalFooter(),
          ],
        ),
      ),
    );
  }

  void _showFeaturesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: FeaturesSection(),
            ),
          ),
        ),
      ),
    );
  }
}
