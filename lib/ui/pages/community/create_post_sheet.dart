import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

/// Bottom sheet for a community leader to create a new post.
class CreatePostSheet extends StatefulWidget {
  final String communityName;
  const CreatePostSheet({super.key, required this.communityName});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();

  static Future<void> show(BuildContext context,
      {required String communityName}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreatePostSheet(communityName: communityName),
    );
  }
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _captionController = TextEditingController();
  bool _hasImage = false;
  bool _isPublishing = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_captionController.text.trim().isEmpty) return;
    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isPublishing = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: ThemeColors.of(context).coreAction, size: 18),
            const SizedBox(width: 8),
            Text(
              'Post published to ${widget.communityName}!',
              style: AppTypography.bodySm
                  .copyWith(color: ThemeColors.of(context).text100),
            ),
          ],
        ),
        backgroundColor: ThemeColors.of(context).surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: ThemeColors.of(context).border),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: keyboardHeight),
      decoration: BoxDecoration(
        color: tc.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──────────────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: tc.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Post',
                      style: AppTypography.headlineMd.copyWith(
                        color: tc.text100,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.communityName,
                      style: AppTypography.bodySm.copyWith(
                        color: tc.intelligenceAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: tc.text40),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(color: tc.divider, height: 20),

          // ── Author row ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [tc.intelligenceAccentDim, tc.limeDim],
                    ),
                    border: Border.all(color: tc.intelligenceAccent, width: 1.5),
                  ),
                  child: Icon(Icons.person_rounded, color: tc.intelligenceAccent, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You',
                      style: AppTypography.bodySm.copyWith(
                        color: tc.text100,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tc.limeDim,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: tc.limeBorder),
                      ),
                      child: Text(
                        'Community Leader',
                        style: AppTypography.bodySm.copyWith(
                          color: tc.coreAction,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Caption input ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _captionController,
              style: AppTypography.bodyMd.copyWith(color: tc.text100),
              maxLines: 6,
              minLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText:
                    "Share an insight, update, or motivation with your community...",
                hintStyle: AppTypography.bodyMd.copyWith(color: tc.text40),
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // ── Image placeholder ────────────────────────────────────────
          if (_hasImage) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: tc.surface2,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: tc.border),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, color: tc.text40, size: 36),
                      const SizedBox(height: 6),
                      Text(
                        'Image attached',
                        style: AppTypography.bodySm.copyWith(color: tc.text40),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // ── Toolbar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                _ToolbarButton(
                  icon: Icons.image_outlined,
                  label: 'Image',
                  onTap: () => setState(() => _hasImage = !_hasImage),
                  isActive: _hasImage,
                  tc: tc,
                ),
                const SizedBox(width: 8),
                _ToolbarButton(
                  icon: Icons.link_rounded,
                  label: 'Link',
                  onTap: () {},
                  tc: tc,
                ),
                const Spacer(),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _isPublishing ? null : _publish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tc.intelligenceAccent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: tc.border,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      elevation: 0,
                    ),
                    child: _isPublishing
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          )
                        : Text(
                            'Publish',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(child: const SizedBox(height: 8)),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final ThemeColors tc;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? tc.intelligenceAccentDim : tc.surface2,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isActive ? tc.intelligenceAccent : tc.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? tc.intelligenceAccent : tc.text40,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.bodySm.copyWith(
                color: isActive ? tc.intelligenceAccent : tc.text70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
