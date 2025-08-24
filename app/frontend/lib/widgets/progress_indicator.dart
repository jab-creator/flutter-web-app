import 'package:flutter/material.dart';

/// A custom progress indicator widget for the onboarding flow.
class OnboardingProgressIndicator extends StatelessWidget {
  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
    this.showLabels = true,
    this.showStepNumbers = true,
  });

  /// The current active step (1-based index).
  final int currentStep;

  /// The total number of steps.
  final int totalSteps;

  /// Optional labels for each step.
  final List<String>? stepLabels;

  /// Color for the active step.
  final Color? activeColor;

  /// Color for inactive steps.
  final Color? inactiveColor;

  /// Color for completed steps.
  final Color? completedColor;

  /// Whether to show step labels below the indicators.
  final bool showLabels;

  /// Whether to show step numbers inside the circles.
  final bool showStepNumbers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final activeStepColor = activeColor ?? colorScheme.primary;
    final inactiveStepColor = inactiveColor ?? colorScheme.outline;
    final completedStepColor = completedColor ?? colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps, (index) {
            final stepNumber = index + 1;
            final isActive = stepNumber == currentStep;
            final isCompleted = stepNumber < currentStep;
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step circle
                _StepCircle(
                  stepNumber: stepNumber,
                  isActive: isActive,
                  isCompleted: isCompleted,
                  activeColor: activeStepColor,
                  inactiveColor: inactiveStepColor,
                  completedColor: completedStepColor,
                  showStepNumber: showStepNumbers,
                ),
                
                // Connector line (except for last step)
                if (index < totalSteps - 1)
                  Container(
                    width: 40,
                    height: 2,
                    color: isCompleted ? completedStepColor : inactiveStepColor,
                  ),
              ],
            );
          }),
        ),
        
        // Step labels
        if (showLabels && stepLabels != null) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(totalSteps, (index) {
              final stepNumber = index + 1;
              final isActive = stepNumber == currentStep;
              final isCompleted = stepNumber < currentStep;
              final label = stepLabels![index];
              
              return Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isActive
                        ? activeStepColor
                        : isCompleted
                            ? completedStepColor
                            : inactiveStepColor,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

/// Individual step circle widget.
class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.stepNumber,
    required this.isActive,
    required this.isCompleted,
    required this.activeColor,
    required this.inactiveColor,
    required this.completedColor,
    required this.showStepNumber,
  });

  final int stepNumber;
  final bool isActive;
  final bool isCompleted;
  final Color activeColor;
  final Color inactiveColor;
  final Color completedColor;
  final bool showStepNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color foregroundColor;
    Widget? icon;
    
    if (isCompleted) {
      backgroundColor = completedColor;
      foregroundColor = theme.colorScheme.onPrimary;
      icon = const Icon(
        Icons.check,
        size: 16,
        color: Colors.white,
      );
    } else if (isActive) {
      backgroundColor = activeColor;
      foregroundColor = theme.colorScheme.onPrimary;
    } else {
      backgroundColor = theme.colorScheme.surface;
      foregroundColor = inactiveColor;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive || isCompleted ? backgroundColor : inactiveColor,
          width: 2,
        ),
      ),
      child: Center(
        child: icon ??
            (showStepNumber
                ? Text(
                    stepNumber.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null),
      ),
    );
  }
}

/// A linear progress indicator for the onboarding flow.
class OnboardingLinearProgress extends StatelessWidget {
  const OnboardingLinearProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.height = 4,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius,
  });

  /// The current step (1-based index).
  final int currentStep;

  /// The total number of steps.
  final int totalSteps;

  /// Height of the progress bar.
  final double height;

  /// Background color of the progress bar.
  final Color? backgroundColor;

  /// Color of the progress fill.
  final Color? progressColor;

  /// Border radius of the progress bar.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final progress = currentStep / totalSteps;
    final bgColor = backgroundColor ?? colorScheme.surfaceVariant;
    final fillColor = progressColor ?? colorScheme.primary;
    final radius = borderRadius ?? BorderRadius.circular(height / 2);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: radius,
          ),
        ),
      ),
    );
  }
}

/// A compact progress indicator showing "Step X of Y".
class OnboardingStepCounter extends StatelessWidget {
  const OnboardingStepCounter({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.style,
  });

  /// The current step (1-based index).
  final int currentStep;

  /// The total number of steps.
  final int totalSteps;

  /// Text style for the counter.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Text(
      'Step $currentStep of $totalSteps',
      style: style ?? theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}