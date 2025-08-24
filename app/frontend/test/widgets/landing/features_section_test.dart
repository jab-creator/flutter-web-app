import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resp_gift_app/widgets/landing/features_section.dart';
import 'package:resp_gift_app/theme/app_theme.dart';

void main() {
  group('FeaturesSection', () {
    testWidgets('renders section header correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: FeaturesSection(),
          ),
        ),
      );

      // Verify section title
      expect(find.text('Why Choose RESP Gifts?'), findsOneWidget);
      
      // Verify section subtitle
      expect(find.textContaining('Give meaningful gifts that grow'), findsOneWidget);
    });

    testWidgets('displays all feature cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: FeaturesSection(),
          ),
        ),
      );

      // Verify all 6 feature titles are present
      expect(find.text('Tax-Free Growth'), findsOneWidget);
      expect(find.text('Meaningful Gifts'), findsOneWidget);
      expect(find.text('Easy to Use'), findsOneWidget);
      expect(find.text('Family Friendly'), findsOneWidget);
      expect(find.text('Watch It Grow'), findsOneWidget);
      expect(find.text('Education Focus'), findsOneWidget);
    });

    testWidgets('displays feature descriptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: FeaturesSection(),
          ),
        ),
      );

      // Verify feature descriptions are present
      expect(find.textContaining('RESP contributions grow tax-free'), findsOneWidget);
      expect(find.textContaining('Give something that truly matters'), findsOneWidget);
      expect(find.textContaining('Simple, secure platform'), findsOneWidget);
    });

    testWidgets('displays feature benefits with checkmarks', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: FeaturesSection(),
          ),
        ),
      );

      // Verify checkmark icons are present
      expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
      
      // Verify some benefit text is present
      expect(find.textContaining('No tax on investment gains'), findsOneWidget);
      expect(find.textContaining('Government matching'), findsOneWidget);
      expect(find.textContaining('Set up in under 5 minutes'), findsOneWidget);
    });

    testWidgets('displays feature icons with proper colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: FeaturesSection(),
          ),
        ),
      );

      // Verify feature icons are present
      expect(find.byIcon(Icons.savings_outlined), findsOneWidget);
      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
      expect(find.byIcon(Icons.smartphone_outlined), findsOneWidget);
      expect(find.byIcon(Icons.family_restroom_outlined), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_outlined), findsOneWidget);
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
    });

    testWidgets('uses responsive grid layout', (WidgetTester tester) async {
      // Test mobile layout (1 column)
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: FeaturesSection(),
          ),
        ),
      );
      await tester.pump();

      // Verify content is present
      expect(find.text('Tax-Free Growth'), findsOneWidget);

      // Test desktop layout (3 columns)
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: FeaturesSection(),
          ),
        ),
      );
      await tester.pump();

      // Verify content is still present after layout change
      expect(find.text('Tax-Free Growth'), findsOneWidget);
    });

    testWidgets('uses card layout for features', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: FeaturesSection(),
          ),
        ),
      );

      // Verify cards are present (should be 6 feature cards)
      expect(find.byType(Card), findsNWidgets(6));
    });
  });

  group('CompactFeaturesSection', () {
    testWidgets('renders compact layout correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CompactFeaturesSection(),
          ),
        ),
      );

      // Verify compact section title
      expect(find.text('Key Benefits'), findsOneWidget);
      
      // Verify compact features are present (should be 3)
      expect(find.text('Tax-Free Growth'), findsOneWidget);
      expect(find.text('Meaningful Impact'), findsOneWidget);
      expect(find.text('Simple Setup'), findsOneWidget);
    });

    testWidgets('displays compact feature subtitles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CompactFeaturesSection(),
          ),
        ),
      );

      // Verify subtitles are present
      expect(find.text('Government matching + compound interest'), findsOneWidget);
      expect(find.text('Gifts that last a lifetime'), findsOneWidget);
      expect(find.text('Ready in under 5 minutes'), findsOneWidget);
    });

    testWidgets('uses row layout for compact features', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CompactFeaturesSection(),
          ),
        ),
      );

      // Verify icons are present
      expect(find.byIcon(Icons.savings_outlined), findsOneWidget);
      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
      expect(find.byIcon(Icons.smartphone_outlined), findsOneWidget);
    });
  });
}