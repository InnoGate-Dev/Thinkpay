import 'package:flutter/material.dart';

/// A single-line amount that shrinks to fit instead of overflowing.
///
/// Amounts live in tight slots — a balance hero, a list row's trailing column,
/// a two-up metric card — and a big enough number will overflow those boxes and
/// paint Flutter's yellow-and-black stripe. [AmountText] lays the value out on
/// one line and scales it down when the parent hands it a bounded width, so the
/// number stays fully readable at any size.
///
/// Format the value with `compactNumber` / `compactMoney` first; the compact
/// form is what keeps the text short enough that scaling rarely kicks in.
class AmountText extends StatelessWidget {
  const AmountText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.semanticsLabel,
  });

  /// Already-formatted amount, e.g. `Rs. 1.25M`.
  final String text;

  final TextStyle? style;
  final TextAlign? textAlign;

  /// Spoken form for screen readers, e.g. `1250000 rupees`.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      maxLines: 1,
      softWrap: false,
      style: style,
      textAlign: textAlign,
      semanticsLabel: semanticsLabel,
      overflow: TextOverflow.visible,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Inside a Row without Expanded the width is unbounded; scaling would
        // have nothing to scale against, so lay out at the natural size.
        if (!constraints.hasBoundedWidth) return label;

        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: switch (textAlign) {
            TextAlign.center => Alignment.center,
            TextAlign.right || TextAlign.end => Alignment.centerRight,
            _ => Alignment.centerLeft,
          },
          child: label,
        );
      },
    );
  }
}
