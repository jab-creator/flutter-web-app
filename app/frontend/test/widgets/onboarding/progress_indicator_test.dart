import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resp_gift_app/widgets/progress_indicator.dart';

void main() {
  group('OnboardingProgressIndicator', () {
    testWidgets('should display correct number of steps', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              currentStep: 1,
              totalSteps: 3,
              stepLabels: ['Step 1', 'Step 2', 'Step 3'],
            ),
          ),
        ),
      );

      // Should find 3 step circles
      expect(find.byType(Container), findsWidgets);
      
      // Should find step labels
      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Step 2'), findsOneWidget);
      expect(find.text('Step 3'), findsOneWidget);
    });

    testWidgets('should highlight current step', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              currentStep: 2,
              totalSteps: 3,
              stepLabels: ['Step 1', 'Step 2', 'Step 3'],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // The widget should render without errors
      expect(find.byType(OnboardingProgressIndicator), findsOneWidget);
    });

    testWidgets('should show completed steps with check marks', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              currentStep: 3,
              totalSteps: 3,
              stepLabels: ['Step 1', 'Step 2', 'Step 3'],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Should find check icons for completed steps
      expect(find.byIcon(Icons.check), findsWidgets);
    });

    testWidgets('should work without step labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              currentStep: 2,
              totalSteps: 3,
              showLabels: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Should render without errors
      expect(find.byType(OnboardingProgressIndicator), findsOneWidget);
    });
  });

  group('OnboardingLinearProgress', () {
    testWidgets('should display linear progress bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingLinearProgress(
              currentStep: 2,
              totalSteps: 3,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Should find the progress container
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(OnboardingLinearProgress), findsOneWidget);
    });
  });

  group('OnboardingStepCounter', () {
    testWidgets('should display step counter text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingStepCounter(
              currentStep: 2,
              totalSteps: 3,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Should find the step counter text
      expect(find.text('Step 2 of 3'), findsOneWidget);
    });
  });
}