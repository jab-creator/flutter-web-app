import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resp_gift_app/screens/landing_screen.dart';
import 'package:resp_gift_app/theme/app_theme.dart';

void main() {
  group('LandingScreen', () {
    testWidgets('renders app bar correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LandingScreen(),
        ),
      );

      // Verify app bar elements
      expect(find.text('RESP Gifts'), findsOneWidget);
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
    });

    testWidgets('displays desktop navigation links', (WidgetTester tester) async {
      // Set desktop screen size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LandingScreen(),
        ),
      );
      await tester.pump();

      // Verify desktop navigation links
      expect(find.text('Features'), findsOneWidget);
      expect(find.text('How It Works'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Get Started'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays mobile menu button', (WidgetTester tester) async {
      // Set mobile screen size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LandingScreen(),
        ),
      );
      await tester.pump();

      // Verify mobile menu button
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });

    testWidgets('renders all landing page sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LandingScreen(),
        ),
      );

      // Verify hero section content
      expect(find.text('Give the Gift of Education'), findsOneWidget);
      
      // Verify features section content
      expect(find.text('Why Choose RESP Gifts?'), findsOneWidget);
      
      // Verify how it works section content
      expect(find.text('How It Works'), findsOneWidget);
      
      // Verify CTA section content
      expect(find.text('Ready to Give the Gift of Education?'), findsOneWidget);
      
      // Verify footer content
      expect(find.textContaining('© ${DateTime.now().year} RESP Gifts'), findsOneWidget);
    });

    testWidgets('handles mobile menu selections', (WidgetTester tester) async {
      // Set mobile screen size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Screen')),
            '/signup': (context) => const Scaffold(body: Text('Signup Screen')),
          },
          home: const LandingScreen(),
        ),
      );
      await tester.pump();

      // Open mobile menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Verify menu items are present
      expect(find.text('Features'), findsOneWidget);
      expect(find.text('How It Works'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('navigates to login screen when login is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Screen')),
          },
          home: const LandingScreen(),
        ),
      );

      // Find and tap login button (desktop view)
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verify navigation to login screen
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('shows scroll to top button when scrolled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LandingScreen(),
        ),
      );

      // Initially, scroll to top button should not be visible
      expect(find.byType(FloatingActionButton), findsNothing);

      // Scroll down significantly
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1000));
      await tester.pump();

      // Now scroll to top button should be visible
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
    });

    testWidgets('scrolls to top when scroll to top button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LandingScreen(),
        ),
      );

      // Scroll down to make the button appear
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1000));
      await tester.pump();

      // Tap the scroll to top button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // The button should disappear as we're back at the top
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('shows info dialogs when footer links are tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LandingScreen(),
        ),
      );

      // Scroll to footer
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      // Tap privacy policy link
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Privacy Policy'), findsAtLeastNWidgets(1));
      expect(find.text('Close'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('handles get started button taps', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            '/signup': (context) => const Scaffold(body: Text('Signup Screen')),
          },
          home: const LandingScreen(),
        ),
      );

      // Find and tap any Get Started button
      await tester.tap(find.text('Get Started').first);
      await tester.pumpAndSettle();

      // Verify navigation to signup screen
      expect(find.text('Signup Screen'), findsOneWidget);
    });
  });

  group('CompactLandingScreen', () {
    testWidgets('renders compact layout correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CompactLandingScreen(),
        ),
      );

      // Verify app bar
      expect(find.text('RESP Gifts'), findsOneWidget);
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);

      // Verify compact sections are present
      expect(find.text('Give the Gift of Education'), findsOneWidget);
      expect(find.text('Key Benefits'), findsOneWidget);
      expect(find.text('Simple 3-Step Process'), findsOneWidget);
      expect(find.text('Ready to get started?'), findsOneWidget);
    });

    testWidgets('navigates to login screen when login is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Screen')),
          },
          home: const CompactLandingScreen(),
        ),
      );

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verify navigation to login screen
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('navigates to signup screen when get started is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            '/signup': (context) => const Scaffold(body: Text('Signup Screen')),
          },
          home: const CompactLandingScreen(),
        ),
      );

      // Find and tap Get Started button
      await tester.tap(find.text('Get Started').first);
      await tester.pumpAndSettle();

      // Verify navigation to signup screen
      expect(find.text('Signup Screen'), findsOneWidget);
    });

    testWidgets('shows features bottom sheet when learn more is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CompactLandingScreen(),
        ),
      );

      // Find and tap Learn More button
      await tester.tap(find.text('Learn More'));
      await tester.pumpAndSettle();

      // Verify bottom sheet with features is shown
      expect(find.text('Why Choose RESP Gifts?'), findsOneWidget);
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });
  });
}