import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resp_gift_app/widgets/landing/hero_section.dart';
import 'package:resp_gift_app/theme/app_theme.dart';

void main() {
  group('HeroSection', () {
    testWidgets('renders hero content correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HeroSection(),
          ),
        ),
      );

      // Verify main headline is present
      expect(find.text('Give the Gift of Education'), findsOneWidget);
      
      // Verify supporting text is present
      expect(find.textContaining('Help children build their future'), findsOneWidget);
      
      // Verify feature highlights are present
      expect(find.textContaining('Tax-free growth in RESPs'), findsOneWidget);
      expect(find.textContaining('Meaningful gifts that last'), findsOneWidget);
      expect(find.textContaining('Easy setup in minutes'), findsOneWidget);
    });

    testWidgets('calls onGetStarted when Get Started button is pressed', (WidgetTester tester) async {
      bool getStartedCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: HeroSection(
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

    testWidgets('calls onLearnMore when Learn More button is pressed', (WidgetTester tester) async {
      bool learnMoreCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: HeroSection(
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

    testWidgets('displays hero image with education icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HeroSection(),
          ),
        ),
      );

      // Verify education icon is present
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
      
      // Verify "Education Fund" text is present
      expect(find.text('Education Fund'), findsOneWidget);
    });

    testWidgets('adapts layout for different screen sizes', (WidgetTester tester) async {
      // Test mobile layout
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HeroSection(),
          ),
        ),
      );
      await tester.pump();

      // On mobile, buttons should be stacked vertically
      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsOneWidget);

      // Test desktop layout
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HeroSection(),
          ),
        ),
      );
      await tester.pump();

      // Verify content is still present after layout change
      expect(find.text('Give the Gift of Education'), findsOneWidget);
    });
  });

  group('DecoratedHeroSection', () {
    testWidgets('renders with gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: DecoratedHeroSection(),
          ),
        ),
      );

      // Verify the decorated container is present
      expect(find.byType(Container), findsWidgets);
      
      // Verify hero content is still present
      expect(find.text('Give the Gift of Education'), findsOneWidget);
    });

    testWidgets('passes callbacks to underlying HeroSection', (WidgetTester tester) async {
      bool getStartedCalled = false;
      bool learnMoreCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: DecoratedHeroSection(
              onGetStarted: () {
                getStartedCalled = true;
              },
              onLearnMore: () {
                learnMoreCalled = true;
              },
            ),
          ),
        ),
      );

      // Test Get Started callback
      await tester.tap(find.text('Get Started'));
      await tester.pump();
      expect(getStartedCalled, isTrue);

      // Test Learn More callback
      await tester.tap(find.text('Learn More'));
      await tester.pump();
      expect(learnMoreCalled, isTrue);
    });
  });
}