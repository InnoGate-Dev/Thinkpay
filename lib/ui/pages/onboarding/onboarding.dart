import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
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
            _StepIndicator(currentStep: _currentStep, totalSteps: 2, tc: tc),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _WelcomeStep(onNext: _nextPage, tc: tc)
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
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: tc.intelligenceAccentDim,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(Icons.auto_awesome_rounded, color: tc.intelligenceAccent, size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DayOne',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: tc.text100,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'The society of 1%',
                    style: AppTypography.bodyMd.copyWith(color: tc.text70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Build your Discipline.\nBuild yourself.',
            style: AppTypography.display.copyWith(
              color: tc.text100,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'DayOne helps you build yourself, financial discipline, and achieve your goals. '
            'No distractions, absolute focus. '
            'AI chat allows you to make the right financial decisions based on your numbers effortlessly.',
            style: AppTypography.bodyMd.copyWith(color: tc.text70),
          ),
          const Spacer(flex: 2),
          _PrimaryButton(label: 'Get Started', onPressed: onNext, tc: tc),
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
