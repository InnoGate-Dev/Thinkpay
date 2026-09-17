import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

/// Bottom sheet that shows comments for a post and allows adding a new one.
class CommentsSheet extends StatefulWidget {
  final int postId;
  const CommentsSheet({super.key, required this.postId});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();

  static Future<void> show(BuildContext context, {required int postId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(postId: postId),
    );
  }
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Mock comments
  final List<_MockComment> _comments = [
    _MockComment(
      author: 'Sarah K.',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      content: 'This is exactly what I needed to read today. Been struggling with my budget!',
      timeAgo: '2h ago',
      likes: 12,
    ),
    _MockComment(
      author: 'Alex T.',
      avatarUrl: 'https://i.pravatar.cc/150?img=7',
      content: 'Great insight. I started tracking every rupee last month and saw 20% savings.',
      timeAgo: '4h ago',
      likes: 8,
    ),
    _MockComment(
      author: 'Priya R.',
      avatarUrl: 'https://i.pravatar.cc/150?img=9',
      content: 'Could you share a spreadsheet template for this?',
      timeAgo: '6h ago',
      likes: 3,
    ),
    _MockComment(
      author: 'Daniel M.',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      content: 'The 50-30-20 rule is what I follow. Changed my life completely.',
      timeAgo: '8h ago',
      likes: 21,
    ),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.insert(
        0,
        _MockComment(
          author: 'You',
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
          content: text,
          timeAgo: 'Just now',
          likes: 0,
        ),
      );
      _commentController.clear();
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: tc.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: tc.border),
          ),
          child: Column(
            children: [
              // ── Handle ────────────────────────────────────────────────
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ThemeColors.of(context).border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // ── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Text(
                      'Comments',
                      style: AppTypography.headlineMd.copyWith(
                        color: tc.text100,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tc.surface2,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${_comments.length}',
                        style: AppTypography.bodySm.copyWith(
                          color: tc.text70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: tc.text40),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(color: tc.divider, height: 1),

              // ── Comment list ──────────────────────────────────────────
              Expanded(
                child: _comments.isEmpty
                    ? Center(
                        child: Text(
                          'No comments yet. Be the first!',
                          style: AppTypography.bodyMd.copyWith(color: tc.text40),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        itemCount: _comments.length,
                        separatorBuilder: (_, _) => Divider(
                          color: tc.divider,
                          height: 20,
                          indent: 46,
                        ),
                        itemBuilder: (_, i) =>
                            _CommentTile(comment: _comments[i], tc: tc),
                      ),
              ),

              // ── Input bar ─────────────────────────────────────────────
              _CommentInputBar(
                controller: _commentController,
                focusNode: _focusNode,
                onSubmit: _addComment,
                tc: tc,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MockComment {
  final String author;
  final String avatarUrl;
  final String content;
  final String timeAgo;
  int likes;
  bool liked;

  _MockComment({
    required this.author,
    required this.avatarUrl,
    required this.content,
    required this.timeAgo,
    required this.likes,
  }) : liked = false;
}

class _CommentTile extends StatefulWidget {
  final _MockComment comment;
  final ThemeColors tc;
  const _CommentTile({required this.comment, required this.tc});

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  void _toggleLike() {
    setState(() {
      if (widget.comment.liked) {
        widget.comment.likes--;
        widget.comment.liked = false;
      } else {
        widget.comment.likes++;
        widget.comment.liked = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tc = widget.tc;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(widget.comment.avatarUrl),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.comment.author,
                    style: AppTypography.bodySm.copyWith(
                      color: tc.text100,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.comment.timeAgo,
                    style: AppTypography.bodySm.copyWith(
                      color: tc.text40,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.comment.content,
                style: AppTypography.bodySm.copyWith(
                  color: tc.text70,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _toggleLike,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.comment.liked
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 14,
                      color: widget.comment.liked ? tc.coreAction : tc.text40,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.comment.likes}',
                      style: AppTypography.bodySm.copyWith(
                        color: widget.comment.liked ? tc.coreAction : tc.text40,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final ThemeColors tc;

  const _CommentInputBar({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        decoration: BoxDecoration(
          color: tc.surface,
          border: Border(top: BorderSide(color: tc.border)),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: AppTypography.bodySm.copyWith(color: tc.text100),
                decoration: InputDecoration(
                  hintText: 'Add a comment…',
                  hintStyle: AppTypography.bodySm.copyWith(color: tc.text40),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    borderSide: BorderSide(color: tc.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    borderSide: BorderSide(color: tc.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    borderSide: BorderSide(color: tc.intelligenceAccent, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  isDense: true,
                  filled: true,
                  fillColor: tc.surface2,
                ),
                onSubmitted: (_) => onSubmit(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSubmit,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tc.intelligenceAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
