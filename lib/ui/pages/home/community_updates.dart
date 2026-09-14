import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

// ── Community Updates Section ─────────────────────────────────────────────────
class CommunityUpdatesSection extends StatelessWidget {
  const CommunityUpdatesSection({super.key, required this.tc});
  final ThemeColors tc;

  static final List<_CommunityPost> _posts = [
    _CommunityPost(
      channelName: 'Investing 101',
      channelInitial: 'I',
      channelColor: const Color(0xFF6C63FF),
      isVerified: true,
      timeAgo: '10 min ago',
      content:
          '📈 Top 5 ETFs for 2026 you should consider adding to your portfolio right now.',
      likes: 284,
      comments: 47,
      tag: 'Investing',
    ),
    _CommunityPost(
      channelName: 'Personal Finance',
      channelInitial: 'P',
      channelColor: const Color(0xFF00C896),
      isVerified: true,
      timeAgo: '1 hr ago',
      content:
          "💡 The 50/30/20 rule still works in 2026. Here's how to adapt it for rising inflation.",
      likes: 512,
      comments: 89,
      tag: 'Tips',
    ),
    _CommunityPost(
      channelName: 'Tech & Finance',
      channelInitial: 'T',
      channelColor: const Color(0xFFF59E0B),
      isVerified: false,
      timeAgo: '3 hrs ago',
      content:
          '🤖 AI-powered budgeting tools are changing the game. Our review of the best 2026 apps.',
      likes: 198,
      comments: 33,
      tag: 'Tech',
    ),
    _CommunityPost(
      channelName: 'Daily Crypto',
      channelInitial: 'D',
      channelColor: const Color(0xFFEF4444),
      isVerified: false,
      timeAgo: 'Yesterday',
      content:
          '🔴 Bitcoin breaks \$80K — what this means for your crypto holdings.',
      likes: 941,
      comments: 162,
      tag: 'Crypto',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Community Updates',
                  style: GoogleFonts.manrope(
                    color: tc.text100,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: 8),
                // Live indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFEF4444),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/community'),
              child: Text(
                'See all',
                style: GoogleFonts.inter(
                  color: tc.coreAction,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Quick channel row
        _ActiveChannelsRow(tc: tc),
        const SizedBox(height: 14),

        // Horizontal scrollable post cards
        SizedBox(
          height: 178,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _posts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _CommunityPostCard(post: _posts[index], tc: tc),
          ),
        ),


      ],
    );
  }
}

class _CommunityPost {
  final String channelName;
  final String channelInitial;
  final Color channelColor;
  final bool isVerified;
  final String timeAgo;
  final String content;
  final int likes;
  final int comments;
  final String tag;

  const _CommunityPost({
    required this.channelName,
    required this.channelInitial,
    required this.channelColor,
    required this.isVerified,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments,
    required this.tag,
  });
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({required this.post, required this.tc});
  final _CommunityPost post;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/community'),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tc.border, width: 0.8),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Channel header
            Row(
              children: [
                // Avatar
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: post.channelColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      post.channelInitial,
                      style: GoogleFonts.manrope(
                        color: post.channelColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.channelName,
                              style: GoogleFonts.inter(
                                color: tc.text100,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (post.isVerified) ...[
                            const SizedBox(width: 3),
                            Icon(
                              Icons.verified_rounded,
                              color: tc.coreAction,
                              size: 12,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        post.timeAgo,
                        style: GoogleFonts.inter(
                          color: tc.text40,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tag chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: post.channelColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    post.tag,
                    style: GoogleFonts.inter(
                      color: post.channelColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Content
            Expanded(
              child: Text(
                post.content,
                style: GoogleFonts.inter(
                  color: tc.text70,
                  fontSize: 12,
                  height: 1.55,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),

            // Engagement row
            Row(
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 13,
                  color: tc.text40,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likes}',
                  style: GoogleFonts.inter(
                    color: tc.text40,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 13,
                  color: tc.text40,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.comments}',
                  style: GoogleFonts.inter(
                    color: tc.text40,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: tc.text40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveChannelsRow extends StatelessWidget {
  const _ActiveChannelsRow({required this.tc});
  final ThemeColors tc;

  static const _channels = [
    _ChannelBubble('Investing\n101', Color(0xFF6C63FF), 'I', 3),
    _ChannelBubble('Personal\nFinance', Color(0xFF00C896), 'P', 0),
    _ChannelBubble('Tech &\nFinance', Color(0xFFF59E0B), 'T', 5),
    _ChannelBubble('Daily\nCrypto', Color(0xFFEF4444), 'D', 0),
    _ChannelBubble('Startup\nFounders', Color(0xFF8B5CF6), 'S', 2),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tc.border, width: 0.8),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < _channels.length; i++) ...[
                    _ChannelAvatarTile(channel: _channels[i], tc: tc),
                    if (i < _channels.length - 1)
                      const SizedBox(width: 18),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/community'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tc.coreAction.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: tc.coreAction,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelBubble {
  final String label;
  final Color color;
  final String initial;
  final int unread;
  const _ChannelBubble(this.label, this.color, this.initial, this.unread);
}

class _ChannelAvatarTile extends StatelessWidget {
  const _ChannelAvatarTile({required this.channel, required this.tc});
  final _ChannelBubble channel;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/community'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: channel.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: channel.color.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    channel.initial,
                    style: GoogleFonts.manrope(
                      color: channel.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (channel.unread > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: tc.coreAction,
                      shape: BoxShape.circle,
                      border: Border.all(color: tc.surface, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '${channel.unread}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 50,
            child: Text(
              channel.label,
              style: GoogleFonts.inter(
                color: tc.text70,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
