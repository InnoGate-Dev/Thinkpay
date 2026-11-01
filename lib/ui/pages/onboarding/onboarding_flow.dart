import 'package:flutter/material.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/model/onboarding/onboarding_draft.dart';
import 'package:Thinkpay/ui/pages/onboarding/steps/step_account.dart';
import 'package:Thinkpay/ui/pages/onboarding/steps/step_country.dart';
import 'package:Thinkpay/ui/pages/onboarding/steps/step_credit_cards.dart';
import 'package:Thinkpay/ui/pages/onboarding/steps/step_goals.dart';
import 'package:Thinkpay/ui/pages/onboarding/steps/step_loans.dart';
import 'package:Thinkpay/ui/pages/onboarding/steps/step_money_list.dart';

/// Onboarding flow: country → income → expenses → cards → loans → goals →
/// account.
///
/// UI review build. Every step writes into one shared [OnboardingDraft] held
/// here; nothing is persisted and no service is called. The pages live in an
/// [IndexedStack] so moving backwards and forwards never loses a typed value,
/// and the system back button walks the steps instead of leaving the flow.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  /// Data steps are 0–5; step 6 is account creation.
  static const int _lastStep = 6;
  static const Duration _transition = Duration(milliseconds: 220);

  final OnboardingDraft _draft = OnboardingDraft();
  int _index = 0;

  void _goTo(int index) {
    if (index < 0 || index > _lastStep || index == _index) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _index = index);
  }

  void _back() => _goTo(_index - 1);

  void _next() => _goTo(_index + 1);

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _back();
      },
      child: ColoredBox(
        color: tc.background,
        child: TweenAnimationBuilder<double>(
          key: ValueKey<int>(_index),
          tween: Tween<double>(begin: 0, end: 1),
          duration: _transition,
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => Opacity(
            opacity: 0.35 + 0.65 * t,
            child: Transform.translate(
              offset: Offset(12 * (1 - t), 0),
              child: child,
            ),
          ),
          child: IndexedStack(
            index: _index,
            children: [
              CountryStep(draft: _draft, onNext: _next),
              MoneyListStep(
                draft: _draft,
                isIncome: true,
                stepIndex: 1,
                onNext: _next,
                onBack: _back,
                onSkip: _next,
              ),
              MoneyListStep(
                draft: _draft,
                isIncome: false,
                stepIndex: 2,
                onNext: _next,
                onBack: _back,
                onSkip: _next,
              ),
              CreditCardsStep(
                draft: _draft,
                stepIndex: 3,
                onNext: _next,
                onBack: _back,
                onSkip: _next,
              ),
              LoansStep(
                draft: _draft,
                stepIndex: 4,
                onNext: _next,
                onBack: _back,
                onSkip: _next,
              ),
              GoalsStep(
                draft: _draft,
                stepIndex: 5,
                onNext: _next,
                onBack: _back,
                onSkip: _next,
              ),
              AccountStep(draft: _draft, onBack: _back, onJumpTo: _goTo),
            ],
          ),
        ),
      ),
    );
  }
}
