import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

/// Floating action button pinned to the bottom-right corner of a content area.
///
/// Views hosted inside a [TabBarView] can't own `Scaffold.floatingActionButton`,
/// so they surface their primary action through this widget instead. It is a
/// drop-in replacement: the position matches
/// [FloatingActionButtonLocation.endFloat].
///
/// Must be a direct child of a [Stack]; the [heroTag] must be unique across all
/// FABs that can be mounted at the same time.
class PinnedFab extends StatelessWidget {
  const PinnedFab({
    super.key,
    required this.heroTag,
    required this.icon,
    required this.onPressed,
    this.label,
    this.inset = 16,
  });

  final Object heroTag;
  final IconData icon;
  final VoidCallback onPressed;

  /// When set the button expands into a labelled pill.
  final String? label;

  /// Distance kept from the bottom/right edges of the parent [Stack].
  final double inset;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    final text = label;

    return Positioned(
      right: inset,
      bottom: inset,
      child: text == null
          ? FloatingActionButton(
              heroTag: heroTag,
              onPressed: onPressed,
              backgroundColor: tc.coreAction,
              foregroundColor: tc.background,
              shape: shape,
              child: Icon(icon, size: 24),
            )
          : FloatingActionButton.extended(
              heroTag: heroTag,
              onPressed: onPressed,
              backgroundColor: tc.coreAction,
              foregroundColor: tc.background,
              elevation: 2,
              shape: shape,
              icon: Icon(icon, size: 20),
              label: Text(
                text,
                style: AppTypography.bodyMd.copyWith(
                  color: tc.background,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}
