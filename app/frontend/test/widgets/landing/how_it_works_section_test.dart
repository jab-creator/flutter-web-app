import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resp_gift_app/widgets/landing/how_it_works_section.dart';
import 'package:resp_gift_app/theme/app_theme.dart';

void main() {
  group('HowItWorksSection', () {
    testWidgets('renders section header correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HowItWorksSection(),
          ),
        ),
      );

      // Verify section title
      expect(find.text('How It Works'), findsOneWidget);
      
      // Verify section subtitle
      expect(find.textContaining('Getting started is simple'), findsOneWidget);
    });

    testWidgets('displays all three steps', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HowItWorksSection(),
          ),
        ),
      );

      // Verify all step titles are present
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Share with Family'), findsOneWidget);
      expect(find.text('Watch It Grow'), findsOneWidget);
    });

    testWidgets('displays step descriptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HowItWorksSection(),
          ),
        ),
      );

      // Verify step descriptions are present
      expect(find.textContaining('Sign up and set up your child\'s RESP'), findsOneWidget);
      expect(find.textContaining('Send the unique gift page link'), findsOneWidget);
      expect(find.textContaining('Track contributions and watch'), findsOneWidget);
    });

    testWidgets('displays step numbers correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HowItWorksSection(),
          ),
        ),
      );

      // Verify step numbers are present
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('displays step icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HowItWorksSection(),
          ),
        ),
      );

      // Verify step icons are present
      expect(find.byIcon(Icons.person_add_outlined), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
      expect(find.byIcon(Icons.celebration_outlined), findsOneWidget);
    });

    testWidgets('displays step details with checkmarks', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HowItWorksSection(),
          ),
        ),
      );

      // Verify checkmark icons are present for step details
      expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
      
      // Verify some step details are present
      expect(find.textContaining('Quick registration'), findsOneWidget);
      expect(find.textContaining('Unique gift page URL'), findsOneWidget);
      expect(find.textContaining('Real-time updates'), findsOneWidget);
    });

    testWidgets('uses card layout for steps', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HowItWorksSection(),
          ),
        ),
      );

      // Verify cards are present (should be 3 step cards)
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('adapts layout for different screen sizes', (WidgetTester tester) async {
      // Test mobile layout
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HowItWorksSection(),
          ),
        ),
      );
      await tester.pump();

      // Verify content is present
      expect(find.text('Create Account'), findsOneWidget);

      // Test desktop layout
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HowItWorksSection(),
          ),
        ),
      );
      await tester.pump();

      // Verify content is still present after layout change
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('has background color styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HowItWorksSection(),
          ),
        ),
      );

      // Verify the section has a container with background color
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('SimpleHowItWorksSection', () {
    testWidgets('renders simple layout correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SimpleHowItWorksSection(),
          ),
        ),
      );

      // Verify simple section title
      expect(find.text('Simple 3-Step Process'), findsOneWidget);
    });

    testWidgets('displays simplified step descriptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SimpleHowItWorksSection(),
          ),
        ),
      );

      // Verify simplified step descriptions
      expect(find.text('Create your child\'s gift page'), findsOneWidget);
      expect(find.text('Share with family and friends'), findsOneWidget);
      expect(find.text('Watch the education fund grow'), findsOneWidget);
    });

    testWidgets('displays step numbers in circles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SimpleHowItWorksSection(),
          ),
        ),
      );

      // Verify step numbers are present
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('uses row layout for simple steps', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SimpleHowItWorksSection(),
          ),
        ),
      );

      // Verify the layout uses rows for each step
      expect(find.byType(Row), findsWidgets);
    });
  });
}