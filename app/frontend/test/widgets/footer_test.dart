import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resp_gift_app/widgets/footer.dart';
import 'package:resp_gift_app/theme/app_theme.dart';

void main() {
  group('Footer', () {
    testWidgets('renders brand section correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Footer(),
          ),
        ),
      );

      // Verify brand elements
      expect(find.text('RESP Gifts'), findsOneWidget);
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
      expect(find.textContaining('Making education gifts meaningful'), findsOneWidget);
    });

    testWidgets('displays trust badges', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Footer(),
          ),
        ),
      );

      // Verify trust badges
      expect(find.text('Secure'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Canadian'), findsOneWidget);
      
      // Verify trust badge icons
      expect(find.byIcon(Icons.security_outlined), findsOneWidget);
      expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    });

    testWidgets('displays quick links section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Footer(),
          ),
        ),
      );

      // Verify quick links section
      expect(find.text('Quick Links'), findsOneWidget);
      expect(find.text('About Us'), findsOneWidget);
      expect(find.text('How It Works'), findsOneWidget);
      expect(find.text('Blog'), findsOneWidget);
      expect(find.text('Help Center'), findsOneWidget);
    });

    testWidgets('displays contact section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Footer(),
          ),
        ),
      );

      // Verify contact section
      expect(find.text('Contact'), findsOneWidget);
      expect(find.text('support@respgifts.ca'), findsOneWidget);
      expect(find.text('1-800-RESP-GIFT'), findsOneWidget);
      expect(find.text('Toronto, ON, Canada'), findsOneWidget);
      
      // Verify contact icons
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    });

    testWidgets('displays social media section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Footer(),
          ),
        ),
      );

      // Verify social section
      expect(find.text('Follow Us'), findsOneWidget);
      
      // Verify social icons
      expect(find.byIcon(Icons.facebook), findsOneWidget);
      expect(find.byIcon(Icons.alternate_email), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.business), findsOneWidget);
    });

    testWidgets('displays copyright and legal links', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Footer(),
          ),
        ),
      );

      // Verify copyright
      final currentYear = DateTime.now().year;
      expect(find.textContaining('© $currentYear RESP Gifts'), findsOneWidget);
      
      // Verify legal links
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);
    });

    testWidgets('calls callback functions when links are tapped', (WidgetTester tester) async {
      bool privacyPolicyCalled = false;
      bool termsOfServiceCalled = false;
      bool contactCalled = false;
      bool aboutCalled = false;
      bool helpCalled = false;
      bool blogCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Footer(
              onPrivacyPolicy: () => privacyPolicyCalled = true,
              onTermsOfService: () => termsOfServiceCalled = true,
              onContact: () => contactCalled = true,
              onAbout: () => aboutCalled = true,
              onHelp: () => helpCalled = true,
              onBlog: () => blogCalled = true,
            ),
          ),
        ),
      );

      // Test privacy policy callback
      await tester.tap(find.text('Privacy Policy'));
      await tester.pump();
      expect(privacyPolicyCalled, isTrue);

      // Test terms of service callback
      await tester.tap(find.text('Terms of Service'));
      await tester.pump();
      expect(termsOfServiceCalled, isTrue);

      // Test about callback
      await tester.tap(find.text('About Us'));
      await tester.pump();
      expect(aboutCalled, isTrue);

      // Test blog callback
      await tester.tap(find.text('Blog'));
      await tester.pump();
      expect(blogCalled, isTrue);
    });

    testWidgets('adapts layout for different screen sizes', (WidgetTester tester) async {
      // Test mobile layout
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Footer(),
          ),
        ),
      );
      await tester.pump();

      // Verify content is present
      expect(find.text('RESP Gifts'), findsOneWidget);

      // Test desktop layout
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Footer(),
          ),
        ),
      );
      await tester.pump();

      // Verify content is still present after layout change
      expect(find.text('RESP Gifts'), findsOneWidget);
    });

    testWidgets('has background color styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Footer(),
          ),
        ),
      );

      // Verify the footer has a container with background color
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('MinimalFooter', () {
    testWidgets('renders minimal layout correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: MinimalFooter(),
          ),
        ),
      );

      // Verify minimal copyright
      final currentYear = DateTime.now().year;
      expect(find.textContaining('© $currentYear RESP Gifts'), findsOneWidget);
    });

    testWidgets('displays minimal legal links', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: MinimalFooter(),
          ),
        ),
      );

      // Verify minimal legal links
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Terms'), findsOneWidget);
    });

    testWidgets('calls callback functions when links are tapped', (WidgetTester tester) async {
      bool privacyPolicyCalled = false;
      bool termsOfServiceCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: MinimalFooter(
              onPrivacyPolicy: () => privacyPolicyCalled = true,
              onTermsOfService: () => termsOfServiceCalled = true,
            ),
          ),
        ),
      );

      // Test privacy policy callback
      await tester.tap(find.text('Privacy'));
      await tester.pump();
      expect(privacyPolicyCalled, isTrue);

      // Test terms of service callback
      await tester.tap(find.text('Terms'));
      await tester.pump();
      expect(termsOfServiceCalled, isTrue);
    });

    testWidgets('adapts layout for different screen sizes', (WidgetTester tester) async {
      // Test mobile layout
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: MinimalFooter(),
          ),
        ),
      );
      await tester.pump();

      // Verify content is present
      final currentYear = DateTime.now().year;
      expect(find.textContaining('© $currentYear RESP Gifts'), findsOneWidget);

      // Test desktop layout
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: MinimalFooter(),
          ),
        ),
      );
      await tester.pump();

      // Verify content is still present after layout change
      expect(find.textContaining('© $currentYear RESP Gifts'), findsOneWidget);
    });
  });
}