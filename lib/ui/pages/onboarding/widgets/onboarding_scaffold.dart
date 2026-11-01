import 'package:flutter/material.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';

/// Frame shared by every onboarding step: progress header, scrolling body and a
/// sticky footer that rides above the keyboard.
///
/// Steps supply their own scrollable content and (optionally) a footer; this
/// widget owns the header, the CTA placement and the safe-area handling so no
/// step can get them wrong.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.stepIndex,
    required this.stepLabel,
    required this.content,
    this.footer,
    this.onBack,
    this.onSkip,
    this.totalSteps = 6,
    this.showBack = true,
    this.showSkip = true,
  });

  /// Zero-based index of the current step. Step 6 is the account step.
  final int stepIndex;
  final String stepLabel;
  final Widget content;
  final Widget? footer;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final int totalSteps;
  final bool showBack;
  final bool showSkip;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                _Header(
                  stepIndex: stepIndex,
                  stepLabel: stepLabel,
                  totalSteps: totalSteps,
                  onBack: onBack,
                  onSkip: onSkip,
                  showBack: showBack,
                  showSkip: showSkip,
                ),
                Expanded(child: content),
                if (footer != null) _Footer(child: footer!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.stepIndex,
    required this.stepLabel,
    required this.totalSteps,
    required this.onBack,
    required this.onSkip,
    required this.showBack,
    required this.showSkip,
  });

  final int stepIndex;
  final String stepLabel;
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final bool showBack;
  final bool showSkip;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final filled = (stepIndex + 1).clamp(0, totalSteps);
    final isLast = stepIndex >= totalSteps;
    final label = isLast
        ? 'Last step'
        : 'Step ${stepIndex + 1} of $totalSteps · $stepLabel';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        4,
        AppSpacing.base,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: showBack
                    ? IconButton(
                        onPressed: onBack,
                        tooltip: 'Back',
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: tc.text100,
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: Semantics(
                  label: label,
                  child: Row(
                    children: [
                      for (var i = 0; i < totalSteps; i++)
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutCubic,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: i < filled
                                  ? tc.intelligenceAccent
                                  : tc.border,
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 64,
                height: 44,
                child: showSkip
                    ? TextButton(
                        onPressed: onSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: tc.text70,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Skip',
                          style: AppTypography.bodySm.copyWith(
                            color: tc.text70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.base + AppSpacing.xs,
              top: 2,
              bottom: AppSpacing.base,
            ),
            child: Text(
              label.toUpperCase(),
              style: AppTypography.labelCaps.copyWith(
                color: tc.text40,
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: tc.background,
          border: Border(top: BorderSide(color: tc.divider)),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.marginMobile,
          AppSpacing.md,
          AppSpacing.marginMobile + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: child,
      ),
    );
  }
}
