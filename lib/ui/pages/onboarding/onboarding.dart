import 'package:flutter/material.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isSetupComplete = false;

  void _nextPage() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    } else {
      setState(() => _isSetupComplete = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    if (_isSetupComplete) {
      return _SuccessScreen(tc: tc);
    }

    return Scaffold(
      backgroundColor: tc.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _StepIndicator(currentStep: _currentStep, totalSteps: 3, tc: tc),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _WelcomeStep(onNext: _nextPage, tc: tc),
                  _FocusAreasStep(onNext: _nextPage, tc: tc),
                  _GoalStep(onNext: _nextPage, tc: tc),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final ThemeColors tc;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index <= currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? tc.intelligenceAccent : tc.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  final ThemeColors tc;

  const _WelcomeStep({required this.onNext, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: tc.intelligenceAccentDim,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: tc.intelligenceAccent, size: 32),
          ),
          const SizedBox(height: 32),
          Text(
            'Build your finances.\nBuild yourself.',
            style: AppTypography.display.copyWith(
              color: tc.text100,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Society of 1% helps you master your money with AI-powered insights and simple tracking.',
            style: AppTypography.bodyMd.copyWith(color: tc.text70),
          ),
          const Spacer(flex: 2),
          _PrimaryButton(label: 'Get Started', onPressed: onNext, tc: tc),
        ],
      ),
    );
  }
}

class _FocusAreasStep extends StatefulWidget {
  final VoidCallback onNext;
  final ThemeColors tc;

  const _FocusAreasStep({required this.onNext, required this.tc});

  @override
  State<_FocusAreasStep> createState() => _FocusAreasStepState();
}

class _FocusAreasStepState extends State<_FocusAreasStep> {
  final Set<String> _selectedAreas = {};
  final List<String> _areas = [
    'Personal Finance',
    'Investing',
    'Business',
    'Personal Growth',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s your focus?',
            style: AppTypography.headlineLg.copyWith(color: widget.tc.text100),
          ),
          const SizedBox(height: 12),
          Text(
            'Select the areas you want to master first.',
            style: AppTypography.bodyMd.copyWith(color: widget.tc.text70),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _areas.map((area) {
              final isSelected = _selectedAreas.contains(area);
              return FilterChip(
                label: Text(area),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAreas.add(area);
                    } else {
                      _selectedAreas.remove(area);
                    }
                  });
                },
                selectedColor: widget.tc.intelligenceAccentDim,
                checkmarkColor: widget.tc.intelligenceAccent,
                labelStyle: AppTypography.bodySm.copyWith(
                  color: isSelected ? widget.tc.intelligenceAccent : widget.tc.text70,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                backgroundColor: widget.tc.surface2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  side: BorderSide(
                    color: isSelected ? widget.tc.intelligenceAccent : widget.tc.border,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              );
            }).toList(),
          ),
          const Spacer(),
          _PrimaryButton(
            label: 'Continue',
            onPressed: _selectedAreas.isNotEmpty ? widget.onNext : null,
            tc: widget.tc,
          ),
        ],
      ),
    );
  }
}

class _GoalStep extends StatefulWidget {
  final VoidCallback onNext;
  final ThemeColors tc;

  const _GoalStep({required this.onNext, required this.tc});

  @override
  State<_GoalStep> createState() => _GoalStepState();
}

class _GoalStepState extends State<_GoalStep> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set a financial goal.',
            style: AppTypography.headlineLg.copyWith(color: widget.tc.text100),
          ),
          const SizedBox(height: 12),
          Text(
            'Start small. What are you saving for?',
            style: AppTypography.bodyMd.copyWith(color: widget.tc.text70),
          ),
          const SizedBox(height: 32),
          _Label('Goal Name'),
          _TextField(controller: _nameController, hint: 'e.g. Emergency Fund', tc: widget.tc),
          const SizedBox(height: 20),
          _Label('Target Amount'),
          _TextField(
            controller: _amountController,
            hint: '0.00',
            keyboardType: TextInputType.number,
            isAmount: true,
            tc: widget.tc,
          ),
          const SizedBox(height: 20),
          _Label('Target Date'),
          _TextField(
            controller: _dateController,
            hint: 'MM / YYYY',
            tc: widget.tc,
            onTap: () async {
              // Simple date picker simulation or implementation
            },
          ),
          const Spacer(),
          _PrimaryButton(label: 'Complete Setup', onPressed: widget.onNext, tc: widget.tc),
        ],
      ),
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  final ThemeColors tc;
  const _SuccessScreen({required this.tc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tc.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: tc.intelligenceAccentDim,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, color: tc.intelligenceAccent, size: 48),
              ),
              const SizedBox(height: 32),
              Text(
                'You\'re all set up!',
                style: AppTypography.headlineLg.copyWith(color: tc.text100),
              ),
              const SizedBox(height: 12),
              Text(
                'Welcome to the Society of 1%. Let\'s build your financial future together.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(color: tc.text70),
              ),
              const SizedBox(height: 48),
              _PrimaryButton(
                label: 'Go to Dashboard',
                onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                tc: tc,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.labelCaps.copyWith(color: tc.text40, fontSize: 10),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool isAmount;
  final VoidCallback? onTap;
  final ThemeColors tc;

  const _TextField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.isAmount = false,
    this.onTap,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tc.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onTap: onTap,
        readOnly: onTap != null,
        style: isAmount
            ? AppTypography.dataMono.copyWith(color: tc.text100, fontSize: 18)
            : AppTypography.bodyMd.copyWith(color: tc.text100),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodyMd.copyWith(color: tc.text20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixText: isAmount ? 'Rs. ' : null,
          prefixStyle: AppTypography.dataMono.copyWith(color: tc.text40, fontSize: 18),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ThemeColors tc;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: tc.intelligenceAccent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: tc.border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
