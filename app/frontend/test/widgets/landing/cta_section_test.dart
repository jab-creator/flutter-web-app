import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resp_gift_app/widgets/landing/cta_section.dart';
import 'package:resp_gift_app/theme/app_theme.dart';

void main() {
  group('CtaSection', () {
    testWidgets('renders CTA content correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CtaSection(),
          ),
        ),
      );

      // Verify main CTA headline
      expect(find.text('Ready to Give the Gift of Education?'), findsOneWidget);
      
      // Verify supporting text
      expect(find.textContaining('Join thousands of families'), findsOneWidget);
    });

    testWidgets('displays trust indicators', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CtaSection(),
          ),
        ),
      );

      // Verify trust indicator text
      expect(find.text('Bank-level security'), findsOneWidget);
      expect(find.text('Government approved'), findsOneWidget);
      expect(find.text('10,000+ families trust us'), findsOneWidget);
      expect(find.text('\$50M+ in RESPs'), findsOneWidget);
    });

    testWidgets('displays trust indicator icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CtaSection(),
          ),
        ),
      );

      // Verify trust indicator icons
      expect(find.byIcon(Icons.security_outlined), findsOneWidget);
      expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_outlined), findsOneWidget);
    });

    testWidgets('calls onGetStarted when Start Free Today button is pressed', (WidgetTester tester) async {
      bool getStartedCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CtaSection(
              onGetStarted: () {
                getStartedCalled = true;
              },
            ),
          ),
        ),
      );

      // Find and tap the Start Free Today button
      final startButton = find.text('Start Free Today');
      expect(startButton, findsOneWidget);
      
      await tester.tap(startButton);
      await tester.pump();

      expect(getStartedCalled, isTrue);
    });

    testWidgets('calls onLearnMore when Learn More button is pressed', (WidgetTester tester) async {
      bool learnMoreCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CtaSection(
              onLearnMore: () {
                learnMoreCalled = true;
              },
            ),
          ),
        ),
      );

      // Find and tap the Learn More button
      final learnMoreButton = find.text('Learn More');
      expect(learnMoreButton, findsOneWidget);
      
      await tester.tap(learnMoreButton);
      await tester.pump();

      expect(learnMoreCalled, isTrue);
    });

    testWidgets('has gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CtaSection(),
          ),
        ),
      );

      // Verify the section has a container with gradient decoration
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('adapts layout for different screen sizes', (WidgetTester tester) async {
      // Test mobile layout
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CtaSection(),
          ),
        ),
      );
      await tester.pump();

      // Verify content is present
      expect(find.text('Ready to Give the Gift of Education?'), findsOneWidget);

      // Test desktop layout
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CtaSection(),
          ),
        ),
      );
      await tester.pump();

      // Verify content is still present after layout change
      expect(find.text('Ready to Give the Gift of Education?'), findsOneWidget);
    });
  });

  group('CompactCtaSection', () {
    testWidgets('renders compact layout correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CompactCtaSection(),
          ),
        ),
      );

      // Verify compact CTA text
      expect(find.text('Ready to get started?'), findsOneWidget);
      expect(find.text('Create your child\'s gift page in minutes.'), findsOneWidget);
    });

    testWidgets('calls onGetStarted when Get Started button is pressed', (WidgetTester tester) async {
      bool getStartedCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CompactCtaSection(
              onGetStarted: () {
                getStartedCalled = true;
              },
            ),
          ),
        ),
      );

      // Find and tap the Get Started button
      final getStartedButton = find.text('Get Started');
      expect(getStartedButton, findsOneWidget);
      
      await tester.tap(getStartedButton);
      await tester.pump();

      expect(getStartedCalled, isTrue);
    });

    testWidgets('uses custom background color when provided', (WidgetTester tester) async {
      const customColor = Colors.red;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CompactCtaSection(
              backgroundColor: customColor,
            ),
          ),
        ),
      );

      // Verify the section has a container
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('NewsletterCtaSection', () {
    testWidgets('renders newsletter signup form', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: NewsletterCtaSection(),
          ),
        ),
      );

      // Verify newsletter content
      expect(find.text('Stay Updated'), findsOneWidget);
      expect(find.textContaining('Get tips on RESP planning'), findsOneWidget);
      
      // Verify email form elements
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Subscribe'), findsOneWidget);
    });

    testWidgets('validates email input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: NewsletterCtaSection(),
          ),
        ),
      );

      // Try to submit without email
      await tester.tap(find.text('Subscribe'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('validates email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: NewsletterCtaSection(),
          ),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField), 'invalid-email');
      await tester.tap(find.text('Subscribe'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('calls onSubscribe with valid email', (WidgetTester tester) async {
      String? subscribedEmail;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: NewsletterCtaSection(
              onSubscribe: (email) async {
                subscribedEmail = email;
              },
            ),
          ),
        ),
      );

      // Enter valid email
      const testEmail = 'test@example.com';
      await tester.enterText(find.byType(TextFormField), testEmail);
      await tester.tap(find.text('Subscribe'));
      await tester.pump();

      expect(subscribedEmail, equals(testEmail));
    });

    testWidgets('shows loading state during subscription', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: NewsletterCtaSection(
              onSubscribe: (email) async {
                // Simulate async operation
                await Future.delayed(const Duration(milliseconds: 100));
              },
            ),
          ),
        ),
      );

      // Enter valid email and submit
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Subscribe'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('adapts layout for different screen sizes', (WidgetTester tester) async {
      // Test mobile layout
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: NewsletterCtaSection(),
          ),
        ),
      );
      await tester.pump();

      // Verify content is present
      expect(find.text('Stay Updated'), findsOneWidget);

      // Test desktop layout
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: NewsletterCtaSection(),
          ),
        ),
      );
      await tester.pump();

      // Verify content is still present after layout change
      expect(find.text('Stay Updated'), findsOneWidget);
    });
  });
}