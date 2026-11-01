import 'package:flutter/material.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/model/onboarding/onboarding_draft.dart';
import 'package:Thinkpay/ui/pages/onboarding/widgets/onboarding_scaffold.dart';
import 'package:Thinkpay/ui/pages/onboarding/widgets/onboarding_widgets.dart';

/// Step 7 — account creation.
///
/// UI preview only: nothing is submitted and no service is called. In
/// production this summary strip moves into `auth/signup.dart` and the button
/// runs the existing registration flow.
class AccountStep extends StatefulWidget {
  const AccountStep({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onJumpTo,
  });

  final OnboardingDraft draft;
  final VoidCallback onBack;

  /// Jumps back to a completed step so the summary can be corrected.
  final ValueChanged<int> onJumpTo;

  @override
  State<AccountStep> createState() => _AccountStepState();
}

class _AccountStepState extends State<AccountStep> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _birthdayCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  DateTime? _birthday;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _birthdayCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final lastDate = DateTime(now.year - 13, now.month, now.day);
    final initial = _birthday ?? DateTime(now.year - 25, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(lastDate) ? lastDate : initial,
      firstDate: DateTime(1900),
      lastDate: lastDate,
      helpText: 'Select your birthday',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _birthday = picked;
      _birthdayCtrl.text =
          '${picked.year}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _openChangeSheet() async {
    final target = await showOnboardingSheet<int>(
      context: context,
      builder: (_) => _SetupIndexSheet(draft: widget.draft),
    );
    if (target == null || !mounted) return;
    widget.onJumpTo(target);
  }

  /// UI preview: skip validation and the API call, land on Home.
  void _createAccount() {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your name.');
      return;
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return OnboardingScaffold(
      stepIndex: 6,
      stepLabel: 'Account',
      showSkip: false,
      onBack: widget.onBack,
      content: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.base,
          AppSpacing.md,
          AppSpacing.md,
        ),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const StepTitle(
            title: 'Create account',
            subtitle: 'Save your setup to this account.',
          ),
          const SizedBox(height: AppSpacing.md),

          _SummaryStrip(draft: widget.draft, onChange: _openChangeSheet),
          const SizedBox(height: AppSpacing.md),

          _AccountField(
            controller: _nameCtrl,
            label: 'Full name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: AppSpacing.marginMobile),

          _AccountField(
            controller: _emailCtrl,
            label: 'Email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.marginMobile),

          _AccountField(
            controller: _birthdayCtrl,
            label: 'Birthday',
            icon: Icons.cake_outlined,
            hint: 'Tap to select birthday',
            readOnly: true,
            onTap: _pickBirthday,
            suffixIcon: Icon(
              _birthday == null
                  ? Icons.calendar_today_outlined
                  : Icons.check_circle_rounded,
              size: 20,
              color: _birthday == null ? tc.text70 : tc.intelligenceAccent,
            ),
          ),
          const SizedBox(height: AppSpacing.marginMobile),

          _AccountField(
            controller: _passwordCtrl,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: tc.text70,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.marginMobile),

          _AccountField(
            controller: _confirmCtrl,
            label: 'Confirm password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscureConfirm,
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: tc.text70,
              ),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!, style: AppTypography.bodySm.copyWith(color: tc.red)),
          ],

          const SizedBox(height: AppSpacing.marginMobile),
          Text(
            'By creating an account, you agree to our Terms and Privacy Policy.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: tc.text40,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: RichText(
                text: TextSpan(
                  style: AppTypography.bodySm.copyWith(color: tc.text70),
                  children: [
                    const TextSpan(text: 'Already a member? '),
                    TextSpan(
                      text: 'Sign in',
                      style: TextStyle(
                        color: tc.intelligenceAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      footer: PrimaryCta(label: 'Create account', onTap: _createAccount),
    );
  }
}

// ── Summary strip ─────────────────────────────────────────────────────────────
class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.draft, required this.onChange});

  final OnboardingDraft draft;
  final VoidCallback onChange;

  String _plural(int count, String singular, String plural) =>
      '$count ${count == 1 ? singular : plural}';

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    final money = draft.incomes.isEmpty && draft.expenses.isEmpty
        ? 'No income or expenses yet'
        : '${_plural(draft.incomes.length, 'income source', 'income sources')}'
              ' · ${_plural(draft.expenses.length, 'expense', 'expenses')}';

    final commitments =
        draft.cards.isEmpty && draft.loans.isEmpty && draft.goals.isEmpty
        ? 'No cards, loans or goals yet'
        : '${_plural(draft.cards.length, 'card', 'cards')}'
              ' · ${_plural(draft.loans.length, 'loan', 'loans')}'
              ' · ${_plural(draft.goals.length, 'goal', 'goals')}';

    final location = draft.country == null
        ? 'Country not set · ${draft.currencyCode}'
        : '${draft.country!.emoji} ${draft.country!.name} · '
              '${draft.currencyCode}';

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.marginMobile,
      ),
      decoration: BoxDecoration(
        color: tc.surface2,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your starting point',
                  style: AppTypography.bodySm.copyWith(
                    color: tc.text100,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: onChange,
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 36),
                  foregroundColor: tc.intelligenceAccent,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Change',
                  style: AppTypography.bodySm.copyWith(
                    color: tc.intelligenceAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            location,
            style: AppTypography.bodySm.copyWith(color: tc.text70),
          ),
          const SizedBox(height: 2),
          Text(money, style: AppTypography.bodySm.copyWith(color: tc.text70)),
          const SizedBox(height: 2),
          Text(
            commitments,
            style: AppTypography.bodySm.copyWith(color: tc.text70),
          ),
        ],
      ),
    );
  }
}

class _SetupIndexSheet extends StatelessWidget {
  const _SetupIndexSheet({required this.draft});

  final OnboardingDraft draft;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final entries = <(int, String, String)>[
      (0, 'Country & currency', draft.currencyCode),
      (
        1,
        'Income',
        '${draft.incomes.length} ${draft.incomes.length == 1 ? 'source' : 'sources'}',
      ),
      (
        2,
        'Expenses',
        '${draft.expenses.length} ${draft.expenses.length == 1 ? 'category' : 'categories'}',
      ),
      (3, 'Credit cards', '${draft.cards.length}'),
      (4, 'Loans', '${draft.loans.length}'),
      (5, 'Goals', '${draft.goals.length}'),
    ];

    return SheetShell(
      title: 'Change a section',
      subtitle: 'Your answers are kept when you come back here.',
      onClose: () => Navigator.pop(context),
      body: Column(
        children: [
          for (final entry in entries)
            InkWell(
              onTap: () => Navigator.pop(context, entry.$1),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.$2,
                        style: AppTypography.bodySm.copyWith(
                          color: tc.text100,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      entry.$3,
                      style: AppTypography.bodySm.copyWith(
                        color: tc.text40,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: tc.text40,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Field ─────────────────────────────────────────────────────────────────────
class _AccountField extends StatelessWidget {
  const _AccountField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.hint,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? hint;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      style: AppTypography.bodyMd.copyWith(color: tc.text100),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: AppTypography.bodySm.copyWith(color: tc.text40),
        labelStyle: AppTypography.bodySm.copyWith(color: tc.text70),
        prefixIcon: Icon(icon, color: tc.text70, size: 22),
        suffixIcon: suffixIcon,
        filled: false,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: tc.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: tc.intelligenceAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpacing.marginMobile,
          horizontal: AppSpacing.marginMobile,
        ),
      ),
    );
  }
}
