import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/utils/number_format.dart';

import '../../../core/errors/exceptions.dart';
import '../../../model/credit_card_model.dart';
import '../../../services/creditCardService.dart';
import '../../../util/credit_card_format.dart';

// ── Screen wrapper ────────────────────────────────────────────────────────────
/// Creates a card, or edits [initial] when one is supplied.
///
/// Pops with the saved [CreditCardModel] so the caller can refresh its list.
class AddCreditCardScreen extends StatelessWidget {
  AddCreditCardScreen({super.key, CreditCardService? service, this.initial})
      : service = service ?? CreditCardService();

  final CreditCardService service;

  /// Pass an existing card to use this screen for editing.
  final CreditCardModel? initial;

  @override
  Widget build(BuildContext context) {
    final isEditing = initial != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit credit card' : 'Add credit card'),
      ),
      body: SafeArea(
        child: AddCreditCardForm(
          service: service,
          initial: initial,
          submitLabel: isEditing ? 'Save changes' : 'Save card',
        ),
      ),
    );
  }
}

// ── Form ──────────────────────────────────────────────────────────────────────
class AddCreditCardForm extends StatefulWidget {
  AddCreditCardForm({
    super.key,
    CreditCardService? service,
    this.initial,
    this.submitLabel = 'Save card',
  }) : service = service ?? CreditCardService();

  final CreditCardService service;

  /// Pass an existing card to use this form for editing.
  final CreditCardModel? initial;
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

  bool _submitting = false;
  String? _error;

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

  // ── Submit ──
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final draft = CreditCardModel(
      id: widget.initial?.id ?? 0,
      name: _nameCtrl.text.trim(),
      creditLimit: double.parse(_limitCtrl.text),
      apr: double.parse(_aprCtrl.text),
      statementDay: _statementDay!,
      graceDays: int.parse(_graceCtrl.text),
    );

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final saved = widget.initial == null
          ? await widget.service.createCard(draft)
          : await widget.service.updateCard(draft);
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = _messageFor(e);
      });
    }
  }

  /// Surfaces the backend's validation message when there is one, otherwise
  /// falls back to a generic failure line.
  String _messageFor(Object error) {
    if (error is ApiException) return error.message;
    return widget.initial == null
        ? 'Could not save the card. Please try again.'
        : 'Could not update the card. Please try again.';
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
            decoration: InputDecoration(
              labelText: 'Card limit',
              hintText: '100000',
              prefixText: '$activeCurrencySymbol ',
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
                DropdownMenuItem(
                    value: d, child: Text('${ordinalDay(d)} of every month')),
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

          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error!,
              style: AppTypography.bodySm.copyWith(color: c.red),
            ),
          ],
          const SizedBox(height: AppSpacing.md),

          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.onAccent,
                    ),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
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
      text = 'Next statement closes ${fmtShortDate(close)}. '
          'Payment due ${fmtShortDate(due)}.';
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
