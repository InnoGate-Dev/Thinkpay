import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

/// Reddit-style community post card with upvote/downvote and comments.
class CommunityPostCard extends StatefulWidget {
  final String authorName;
  final String authorAvatarUrl;
  final String timeAgo;
  final String captionText;
  final String? imageUrl;
  final int initialScore;
  final int commentCount;
  final bool isOwner;
  final VoidCallback? onCommentTap;
  final VoidCallback? onDeleteTap;

  const CommunityPostCard({
    super.key,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.timeAgo,
    required this.captionText,
    this.imageUrl,
    this.initialScore = 0,
    this.commentCount = 0,
    this.isOwner = false,
    this.onCommentTap,
    this.onDeleteTap,
  });

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

enum _VoteState { none, up, down }

class _CommunityPostCardState extends State<CommunityPostCard>
    with SingleTickerProviderStateMixin {
  _VoteState _vote = _VoteState.none;
  late int _score;

  late AnimationController _scoreAnimController;
  late Animation<double> _scoreScaleAnim;

  @override
  void initState() {
    super.initState();
    _score = widget.initialScore;
    _scoreAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scoreScaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _scoreAnimController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scoreAnimController.dispose();
    super.dispose();
  }

  void _handleVote(_VoteState tapped) {
    setState(() {
      if (_vote == tapped) {
        // undo vote
        _score += tapped == _VoteState.up ? -1 : 1;
        _vote = _VoteState.none;
      } else {
        // switch or first vote
        if (_vote == _VoteState.up) _score--;
        if (_vote == _VoteState.down) _score++;
        _vote = tapped;
        _score += tapped == _VoteState.up ? 1 : -1;
      }
    });
    _scoreAnimController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Author row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(widget.authorAvatarUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.authorName,
                        style: AppTypography.bodySm.copyWith(
                          color: tc.text100,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.timeAgo,
                        style: AppTypography.bodySm.copyWith(
                          color: tc.text40,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isOwner)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz_rounded, color: tc.text40, size: 20),
                    color: tc.surface2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    onSelected: (value) {
                      if (value == 'delete') widget.onDeleteTap?.call();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, color: tc.red, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Delete Post',
                              style: AppTypography.bodySm.copyWith(color: tc.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ── Caption ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Text(
              widget.captionText,
              style: AppTypography.bodyMd.copyWith(color: tc.text100, height: 1.45),
            ),
          ),

          // ── Optional Image ───────────────────────────────────────────────
          if (widget.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
              child: Image.network(
                widget.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ],

          // ── Action Row ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Row(
              children: [
                // ── Vote pill ──────────────────────────────────────────────
                _VotePill(
                  vote: _vote,
                  score: _score,
                  scaleAnim: _scoreScaleAnim,
                  onUpvote: () => _handleVote(_VoteState.up),
                  onDownvote: () => _handleVote(_VoteState.down),
                  tc: tc,
                ),
                const SizedBox(width: 8),
                // ── Comments ───────────────────────────────────────────────
                _ActionChip(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${widget.commentCount}',
                  onTap: widget.onCommentTap,
                  tc: tc,
                ),
                const Spacer(),
                // ── Share ──────────────────────────────────────────────────
                _ActionChip(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {},
                  tc: tc,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vote Pill ────────────────────────────────────────────────────────────────
class _VotePill extends StatelessWidget {
  final _VoteState vote;
  final int score;
  final Animation<double> scaleAnim;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final ThemeColors tc;

  const _VotePill({
    required this.vote,
    required this.score,
    required this.scaleAnim,
    required this.onUpvote,
    required this.onDownvote,
    required this.tc,
  });

  Color get _upColor => vote == _VoteState.up ? tc.coreAction : tc.text40;
  Color get _downColor => vote == _VoteState.down ? tc.red : tc.text40;
  Color get _scoreColor {
    if (vote == _VoteState.up) return tc.coreAction;
    if (vote == _VoteState.down) return tc.red;
    return tc.text70;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tc.surface2,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: tc.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Upvote
          GestureDetector(
            onTap: onUpvote,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: _upColor,
                size: 20,
              ),
            ),
          ),
          // Score
          ScaleTransition(
            scale: scaleAnim,
            child: Text(
              '$score',
              style: AppTypography.bodySm.copyWith(
                color: _scoreColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          // Downvote
          GestureDetector(
            onTap: onDownvote,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(
                Icons.arrow_downward_rounded,
                color: _downColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Chip ──────────────────────────────────────────────────────────────
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final ThemeColors tc;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: tc.surface2,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: tc.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: tc.text40, size: 16),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.bodySm.copyWith(
                color: tc.text70,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
