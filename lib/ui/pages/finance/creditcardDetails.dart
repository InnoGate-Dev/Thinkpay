import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

// ── Model ─────────────────────────────────────────────────────────────────────
// Only what the user types in. Payment due date is NOT stored: it is always
// statement closing date + grace period, so we calculate it.
class CreditCardDetails {
  const CreditCardDetails({
    required this.name,
    required this.creditLimit,
    required this.apr,
    required this.statementDay,
    required this.graceDays,
  });

  final String name;
  final double creditLimit;
  final double apr; // annual interest rate in %
  final int statementDay; // 1-31, day of month the statement closes
  final int graceDays; // days from statement close to payment due date

  Map<String, dynamic> toMap() => {
    'name': name,
    'creditLimit': creditLimit,
    'apr': apr,
    'statementDay': statementDay,
    'graceDays': graceDays,
  };
}

// ── Date helpers ──────────────────────────────────────────────────────────────
// Day 31 doesn't exist in every month, so clamp to the last day of the month.
DateTime closeDateFor(int year, int month, int day) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, day > lastDay ? lastDay : day);
}

DateTime nextStatementClose(int day, DateTime today) {
  final t = DateTime(today.year, today.month, today.day);
  final thisMonth = closeDateFor(t.year, t.month, day);
  if (!thisMonth.isBefore(t)) return thisMonth;
  return closeDateFor(t.year, t.month + 1, day);
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatShortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

// ── Screen wrapper ────────────────────────────────────────────────────────────
class AddCreditCardScreen extends StatelessWidget {
  const AddCreditCardScreen({super.key, this.onSave});

  final ValueChanged<CreditCardDetails>? onSave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add credit card')),
      body: SafeArea(
        child: AddCreditCardForm(
          onSubmit: (card) {
            onSave?.call(card);
            Navigator.of(context).maybePop(card);
          },
        ),
      ),
    );
  }
}

// ── Form ──────────────────────────────────────────────────────────────────────
class AddCreditCardForm extends StatefulWidget {
  const AddCreditCardForm({
    super.key,
    required this.onSubmit,
    this.initial,
    this.submitLabel = 'Save card',
  });

  final ValueChanged<CreditCardDetails> onSubmit;

  /// Pass an existing card to use this form for editing.
  final CreditCardDetails? initial;
  final String submitLabel;

  @override
  State<AddCreditCardForm> createState() => _AddCreditCardFormState();
}

class _AddCreditCardFormState extends State<AddCreditCardForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _limitCtrl;
  late final TextEditingController _aprCtrl;
  late final TextEditingController _graceCtrl;
  int? _statementDay;

  static final _decimalFormatter =
  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _nameCtrl = TextEditingController(text: i?.name ?? '');
    _limitCtrl = TextEditingController(
        text: i == null ? '' : _trimZeros(i.creditLimit));
    _aprCtrl = TextEditingController(text: i == null ? '' : _trimZeros(i.apr));
    _graceCtrl = TextEditingController(text: '${i?.graceDays ?? 21}');
    _statementDay = i?.statementDay;

    // Rebuild the live preview as the user types.
    _graceCtrl.addListener(_refresh);
  }

  @override
  void dispose() {
    _graceCtrl.removeListener(_refresh);
    _nameCtrl.dispose();
    _limitCtrl.dispose();
    _aprCtrl.dispose();
    _graceCtrl.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  static String _trimZeros(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  // ── Validators ──
  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? 'Enter $label' : null;

  String? _validateName(String? v) {
    final r = _required(v, 'a card name');
    if (r != null) return r;
    if (v!.trim().length > 40) return 'Keep it under 40 characters';
    return null;
  }

  String? _validateLimit(String? v) {
    final r = _required(v, 'your card limit');
    if (r != null) return r;
    final n = double.tryParse(v!);
    if (n == null || n <= 0) return 'Enter an amount greater than 0';
    return null;
  }

  String? _validateApr(String? v) {
    final r = _required(v, 'the interest rate');
    if (r != null) return r;
    final n = double.tryParse(v!);
    if (n == null || n < 0 || n > 100) return 'Enter a rate between 0 and 100';
    return null;
  }

  String? _validateGrace(String? v) {
    final r = _required(v, 'the grace period');
    if (r != null) return r;
    final n = int.tryParse(v!);
    if (n == null || n < 0 || n > 90) return 'Enter 0 to 90 days';
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit(
      CreditCardDetails(
        name: _nameCtrl.text.trim(),
        creditLimit: double.parse(_limitCtrl.text),
        apr: double.parse(_aprCtrl.text),
        statementDay: _statementDay!,
        graceDays: int.parse(_graceCtrl.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Text('Card details',
              style: AppTypography.headlineMd.copyWith(color: c.text100)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Enter these once. You can log purchases and payments afterwards.',
            style: AppTypography.bodySm.copyWith(color: c.text70),
          ),
          const SizedBox(height: AppSpacing.md),

          // Name
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Card name',
              hintText: 'e.g. Commercial Bank Visa',
            ),
            validator: _validateName,
          ),
          const SizedBox(height: AppSpacing.md),

          // Limit
          TextFormField(
            controller: _limitCtrl,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_decimalFormatter],
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Card limit',
              hintText: '100000',
              prefixText: 'Rs. ',
            ),
            validator: _validateLimit,
          ),
          const SizedBox(height: AppSpacing.md),

          // Interest
          TextFormField(
            controller: _aprCtrl,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_decimalFormatter],
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Interest rate (yearly)',
              hintText: '28',
              suffixText: '% p.a.',
            ),
            validator: _validateApr,
          ),
          const SizedBox(height: AppSpacing.md),

          // Statement closing day
          DropdownButtonFormField<int>(
            // ignore: deprecated_member_use
            value: _statementDay,
            isExpanded: true,
            menuMaxHeight: 320,
            decoration: const InputDecoration(
              labelText: 'Statement closing date',
              hintText: 'Pick a day of the month',
            ),
            items: [
              for (var d = 1; d <= 31; d++)
                DropdownMenuItem(value: d, child: Text('${_ordinal(d)} of every month')),
            ],
            onChanged: (v) => setState(() => _statementDay = v),
            validator: (v) => v == null ? 'Pick the closing day' : null,
          ),
          const SizedBox(height: AppSpacing.md),

          // Grace period
          TextFormField(
            controller: _graceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Grace period',
              hintText: '21',
              suffixText: 'days',
              helperText: 'Days between statement closing and payment due date',
            ),
            validator: _validateGrace,
          ),
          const SizedBox(height: AppSpacing.md),

          _DueDatePreview(
            statementDay: _statementDay,
            graceDays: int.tryParse(_graceCtrl.text),
          ),
          const SizedBox(height: AppSpacing.md),

          ElevatedButton(
            onPressed: _submit,
            child: Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }

  static String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }
}

// ── Live preview of the calculated due date ───────────────────────────────────
class _DueDatePreview extends StatelessWidget {
  const _DueDatePreview({required this.statementDay, required this.graceDays});

  final int? statementDay;
  final int? graceDays;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    final ready = statementDay != null && graceDays != null;
    String text = 'Pick a closing date to see your payment due date.';

    if (ready) {
      final close = nextStatementClose(statementDay!, DateTime.now());
      final due = close.add(Duration(days: graceDays!));
      text = 'Next statement closes ${formatShortDate(close)}. '
          'Payment due ${formatShortDate(due)}.';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.accentDim,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_outlined, size: 20, color: c.text100),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySm.copyWith(color: c.text100),
            ),
          ),
        ],
      ),
    );
  }
}