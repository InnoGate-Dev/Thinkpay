import 'package:flutter/material.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/model/onboarding/onboarding_draft.dart';
import 'package:Thinkpay/ui/pages/onboarding/widgets/onboarding_widgets.dart';
import 'package:Thinkpay/util/credit_card_format.dart';

/// Opens the card editor. Pops with the saved [CardDraft], or null on cancel.
Future<CardDraft?> showCardEditorSheet({
  required BuildContext context,
  required String symbol,
  CardDraft? initial,
}) {
  return showOnboardingSheet<CardDraft>(
    context: context,
    builder: (_) => _CardEditorSheet(symbol: symbol, initial: initial),
  );
}

class _CardEditorSheet extends StatefulWidget {
  const _CardEditorSheet({required this.symbol, this.initial});

  final String symbol;
  final CardDraft? initial;

  @override
  State<_CardEditorSheet> createState() => _CardEditorSheetState();
}

class _CardEditorSheetState extends State<_CardEditorSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _limitCtrl;
  late final TextEditingController _aprCtrl;
  late final TextEditingController _graceCtrl;

  int? _statementDay;
  String? _error;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _nameCtrl = TextEditingController(text: i?.name ?? '');
    _limitCtrl = TextEditingController(
      text: i == null || i.creditLimit == 0 ? '' : plainAmount(i.creditLimit),
    );
    _aprCtrl = TextEditingController(text: i == null ? '' : plainAmount(i.apr));
    _graceCtrl = TextEditingController(text: '${i?.graceDays ?? 21}');
    _statementDay = i?.statementDay;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _limitCtrl.dispose();
    _aprCtrl.dispose();
    _graceCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final limit = parseMoney(_limitCtrl.text) ?? 0;

    if (name.isEmpty) {
      setState(() => _error = 'Give the card a name so you can tell it apart.');
      return;
    }
    if (limit <= 0) {
      setState(() => _error = 'Enter the card limit.');
      return;
    }

    Navigator.pop(
      context,
      CardDraft(
        name: name,
        creditLimit: limit,
        apr: parseMoney(_aprCtrl.text) ?? 0,
        statementDay: _statementDay ?? 1,
        graceDays: int.tryParse(_graceCtrl.text.trim()) ?? 21,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return SheetShell(
      title: widget.initial == null ? 'Add a card' : 'Edit card',
      subtitle: 'Enter these once. You can log payments afterwards.',
      onClose: () => Navigator.pop(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetTextField(
            controller: _nameCtrl,
            label: 'Card name',
            hint: 'e.g. Commercial Bank Visa',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppSpacing.marginMobile),
          SheetTextField(
            controller: _limitCtrl,
            label: 'Card limit',
            hint: '100000',
            prefixText: '${widget.symbol} ',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppSpacing.marginMobile),
          SheetTextField(
            controller: _aprCtrl,
            label: 'Interest rate per year',
            hint: '28',
            suffixText: '% p.a.',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppSpacing.md),

          const SectionLabel('Statement closing date'),
          const SizedBox(height: AppSpacing.base),
          _DayGrid(
            selected: _statementDay,
            onSelect: (day) => setState(() => _statementDay = day),
          ),
          const SizedBox(height: AppSpacing.md),

          SheetTextField(
            controller: _graceCtrl,
            label: 'Grace period',
            hint: '21',
            suffixText: 'days',
            helperText: 'Days between statement closing and payment due date',
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.marginMobile),

          _DueDatePreview(
            statementDay: _statementDay,
            graceDays: int.tryParse(_graceCtrl.text.trim()),
          ),

          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!, style: AppTypography.bodySm.copyWith(color: tc.red)),
          ],
        ],
      ),
      footer: PrimaryCta(
        label: widget.initial == null ? 'Save card' : 'Save changes',
        onTap: _save,
      ),
    );
  }
}

/// One-tap day picker. A 31-item dropdown costs open-scroll-pick-close for a
/// single number and pushes the keyboard area off screen.
class _DayGrid extends StatelessWidget {
  const _DayGrid({required this.selected, required this.onSelect});

  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 1.35,
      children: [
        for (var day = 1; day <= 31; day++)
          GestureDetector(
            onTap: () => onSelect(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected == day ? tc.intelligenceAccent : tc.surface2,
                borderRadius: BorderRadius.circular(AppRadius.base),
              ),
              child: Text(
                '$day',
                style: AppTypography.bodySm.copyWith(
                  color: selected == day
                      ? (isDark ? tc.background : Colors.white)
                      : tc.text70,
                  fontWeight: selected == day
                      ? FontWeight.w700
                      : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DueDatePreview extends StatelessWidget {
  const _DueDatePreview({required this.statementDay, required this.graceDays});

  final int? statementDay;
  final int? graceDays;

  @override
  Widget build(BuildContext context) {
    final ready = statementDay != null && graceDays != null;

    if (!ready) {
      return const InfoNote(
        icon: Icons.event_outlined,
        text: 'Pick a closing date to see your payment due date.',
      );
    }

    final close = nextStatementClose(statementDay!, DateTime.now());
    final due = close.add(Duration(days: graceDays!));

    return InfoNote(
      icon: Icons.event_outlined,
      tone: NoteTone.positive,
      text:
          'Next statement closes ${fmtShortDate(close)}. '
          'Payment due ${fmtShortDate(due)}.',
    );
  }
}
