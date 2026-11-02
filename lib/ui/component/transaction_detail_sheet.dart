import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

/// A single `label → value` line rendered inside [TransactionDetailSheet].
class TransactionFact {
  const TransactionFact(this.label, this.value);

  final String label;
  final String value;
}

/// Everything the sheet needs to describe one transaction record.
///
/// The caller resolves and formats every value — including the amount string,
/// which must already come from `core/utils/number_format.dart` — so the sheet
/// holds no repository access and no knowledge of the calling screen's models.
class TransactionDetailData {
  const TransactionDetailData({
    required this.title,
    required this.typeLabel,
    required this.amountText,
    required this.amountColor,
    required this.icon,
    this.badge,
    this.facts = const <TransactionFact>[],
    this.note,
    this.progress,
    this.progressLabel,
  });

  /// Primary line — the category, goal or loan the money went to.
  final String title;

  /// Short description of the movement (Expense, Transfer to goal, …).
  final String typeLabel;

  /// Pre-formatted, signed amount, e.g. `− Rs. 1,200`.
  final String amountText;

  /// Accent used for the icon, amount and badge.
  final Color amountColor;

  final IconData icon;

  /// Optional `Goal` / `Loan` tag shown next to the title.
  final String? badge;

  /// Record details, shown in order after the amount.
  final List<TransactionFact> facts;

  /// Optional free-text note.
  final String? note;

  /// Optional 0–1 progress of the linked goal, rendered as a bar.
  final double? progress;

  /// Caption shown above the progress bar, e.g. `45% funded`.
  final String? progressLabel;
}

/// Read-only bottom sheet that expands a transaction row into its full details.
///
/// Keeps the list row scannable while still letting the user confirm exactly
/// what a record is: type, category, goal/loan reference, timestamps and the
/// backend record id. When [onEdit] / [onDelete] are supplied, the sheet closes
/// itself and hands control back to the caller, which owns the confirmation
/// and the network calls.
class TransactionDetailSheet extends StatelessWidget {
  const TransactionDetailSheet({
    super.key,
    required this.data,
    this.onEdit,
    this.onDelete,
  });

  final TransactionDetailData data;

  /// Opens the edit form. The sheet is already dismissed when this runs.
  final VoidCallback? onEdit;

  /// Starts the delete flow. The sheet is already dismissed when this runs.
  final VoidCallback? onDelete;

  bool get _hasActions => onEdit != null || onDelete != null;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final note = data.note?.trim();

    return Container(
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle ────────────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tc.text20,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Title ─────────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: data.amountColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(data.icon, color: data.amountColor, size: 22),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              data.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.headlineMd.copyWith(
                                color: tc.text100,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (data.badge != null) ...[
                            const SizedBox(width: AppSpacing.base),
                            _Badge(
                              label: data.badge!,
                              color: data.amountColor,
                              tc: tc,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.typeLabel,
                        style: AppTypography.bodySm.copyWith(color: tc.text40),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Amount ────────────────────────────────────────────────────
            Center(
              child: Text(
                data.amountText,
                textAlign: TextAlign.center,
                style: AppTypography.headlineLg.copyWith(
                  color: data.amountColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // ── Goal progress ─────────────────────────────────────────────
            if (data.progress != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data.progressLabel ?? 'Progress',
                      style: AppTypography.bodySm.copyWith(color: tc.text40),
                    ),
                  ),
                  Text(
                    '${(data.progress!.clamp(0.0, 1.0) * 100).round()}%',
                    style: AppTypography.bodySm.copyWith(
                      color: data.amountColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: data.progress!.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: tc.surface2,
                  color: data.amountColor,
                ),
              ),
            ],

            // ── Facts ─────────────────────────────────────────────────────
            if (data.facts.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: tc.surface2,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                  vertical: AppSpacing.xs,
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < data.facts.length; i++) ...[
                      if (i > 0)
                        Divider(
                          color: tc.divider,
                          height: 1,
                          thickness: 0.5,
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 92,
                              child: Text(
                                data.facts[i].label.toUpperCase(),
                                style: AppTypography.labelCaps.copyWith(
                                  color: tc.text40,
                                  fontSize: 10,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                data.facts[i].value,
                                textAlign: TextAlign.right,
                                style: AppTypography.bodySm.copyWith(
                                  color: tc.text100,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // ── Note ──────────────────────────────────────────────────────
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: tc.surface2,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOTE',
                      style: AppTypography.labelCaps.copyWith(
                        color: tc.text40,
                        fontSize: 10,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      note,
                      style: AppTypography.bodySm.copyWith(
                        color: tc.text70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Edit / Delete ─────────────────────────────────────────────
            if (_hasActions) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (onEdit != null)
                    Expanded(
                      child: _SheetAction(
                        label: 'Edit',
                        icon: Icons.edit_outlined,
                        color: tc.background,
                        background: tc.coreAction,
                        onTap: () {
                          Navigator.pop(context);
                          onEdit!();
                        },
                      ),
                    ),
                  if (onEdit != null && onDelete != null)
                    const SizedBox(width: AppSpacing.base),
                  if (onDelete != null)
                    Expanded(
                      child: _SheetAction(
                        label: 'Delete',
                        icon: Icons.delete_outline_rounded,
                        color: tc.accentExpense,
                        background:
                            tc.accentExpense.withValues(alpha: 0.1),
                        onTap: () {
                          Navigator.pop(context);
                          onDelete!();
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
            ],

            // ── Close ─────────────────────────────────────────────────────
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: tc.surface2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  'Close',
                  style: AppTypography.bodySm.copyWith(
                    color: tc.text100,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sheet action ──────────────────────────────────────────────────────────────
/// Full-width pill used for the Edit / Delete pair.
class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 48,
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            backgroundColor: background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.base),
              Text(
                label,
                style: AppTypography.bodySm.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Badge ─────────────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, required this.tc});

  final String label;
  final Color color;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          style: AppTypography.labelCaps.copyWith(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      );
}
