import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/ui/component/community_post_card.dart';
import 'package:Thinkpay/ui/pages/community/comments_sheet.dart';
import 'package:Thinkpay/ui/pages/community/create_post_sheet.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full community profile page with Posts and About tabs.
class CommunityProfilePage extends StatefulWidget {
  /// Pass true when the current user is the community owner.
  final bool isOwner;
  const CommunityProfilePage({super.key, this.isOwner = false});

  @override
  State<CommunityProfilePage> createState() => _CommunityProfilePageState();
}

class _CommunityProfilePageState extends State<CommunityProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;

  // Mock community data
  static const _communityName = 'Investing 101';
  static const _communityDesc =
      'A focused community for people who want to learn investing from scratch. '
      'We share weekly market insights, ETF picks, and long-term wealth-building strategies.';
  static const _followerCount = '14.2K';
  static const _postCount = '328';
  static const _memberCount = '1.4K';
  static const _categories = ['Investing', 'Personal Finance', 'ETFs'];
  static const _rules = [
    'Be respectful and constructive in all discussions.',
    'No self-promotion or spam.',
    'Share only verified financial information.',
    'Tag posts appropriately.',
  ];

  // Mock posts
  final List<_MockPost> _posts = [
    _MockPost(
      author: 'James M.',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
      timeAgo: '2h ago',
      caption:
          '📈 Top 5 ETFs to watch in Q4 2026:\n\n1. VOO – S&P 500 index\n2. QQQ – Nasdaq 100\n3. SCHD – Dividend growth\n4. VTI – Total US market\n5. ARKK – Innovation\n\nWhich one is in your portfolio?',
      score: 127,
      comments: 34,
      imageUrl: null,
      isLeaderPost: true,
    ),
    _MockPost(
      author: 'James M.',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
      timeAgo: 'Yesterday',
      caption:
          'Compound interest is the 8th wonder of the world 🌍\n\nIf you invest Rs 5,000/month at 12% annual return:\n• 10 years → Rs 11.6L\n• 20 years → Rs 49.9L\n• 30 years → Rs 1.76 Crore\n\nStart early. Stay consistent.',
      score: 89,
      comments: 21,
      imageUrl: 'https://picsum.photos/seed/invest1/600/300',
      isLeaderPost: true,
    ),
    _MockPost(
      author: 'Priya S.',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      timeAgo: '3 days ago',
      caption:
          'Just crossed Rs 1 Lakh in my SIP portfolio after 18 months! 🎉 '
          'Staying consistent even during market dips was the hardest part. Thank you this community!',
      score: 52,
      comments: 15,
      imageUrl: null,
      isLeaderPost: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _CommunityAppBar(
              communityName: _communityName,
              tc: tc,
              innerBoxIsScrolled: innerBoxIsScrolled,
            ),
            SliverToBoxAdapter(
              child: _CommunityHeader(
                communityName: _communityName,
                description: _communityDesc,
                followerCount: _followerCount,
                postCount: _postCount,
                memberCount: _memberCount,
                categories: _categories,
                isOwner: widget.isOwner,
                isFollowing: _isFollowing,
                onFollowTap: () => setState(() => _isFollowing = !_isFollowing),
                onDashboardTap: () =>
                    Navigator.pushNamed(context, '/community-dashboard'),
                tc: tc,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: tc.intelligenceAccent,
                  indicatorWeight: 2.5,
                  labelColor: tc.intelligenceAccent,
                  unselectedLabelColor: tc.text40,
                  labelStyle: AppTypography.bodySm
                      .copyWith(fontWeight: FontWeight.w700),
                  unselectedLabelStyle:
                      AppTypography.bodySm.copyWith(fontWeight: FontWeight.w400),
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'About'),
                  ],
                ),
                tc.background,
                tc.border,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── Posts Tab ────────────────────────────────────────────────
            _PostsTab(posts: _posts, isOwner: widget.isOwner, tc: tc),
            // ── About Tab ────────────────────────────────────────────────
            _AboutTab(
              description: _communityDesc,
              categories: _categories,
              rules: _rules,
              tc: tc,
            ),
          ],
        ),
      ),
      floatingActionButton: widget.isOwner
          ? FloatingActionButton.extended(
              onPressed: () =>
                  CreatePostSheet.show(context, communityName: _communityName),
              backgroundColor: tc.intelligenceAccent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'New Post',
                style: AppTypography.bodySm
                    .copyWith(fontWeight: FontWeight.w700, color: Colors.white),
              ),
              elevation: 2,
            )
          : null,
    );
  }
}

// ── SliverAppBar ──────────────────────────────────────────────────────────────
class _CommunityAppBar extends StatelessWidget {
  final String communityName;
  final ThemeColors tc;
  final bool innerBoxIsScrolled;

  const _CommunityAppBar({
    required this.communityName,
    required this.tc,
    required this.innerBoxIsScrolled,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: tc.background,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: tc.background.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: tc.text100, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _CommunityBanner(tc: tc),
        title: innerBoxIsScrolled
            ? Text(
                communityName,
                style: GoogleFonts.manrope(
                  color: tc.text100,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 12),
      ),
    );
  }
}

class _CommunityBanner extends StatelessWidget {
  final ThemeColors tc;
  const _CommunityBanner({required this.tc});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tc.intelligenceAccent.withValues(alpha: 0.3),
            tc.limeDim,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.trending_up_rounded,
          size: 64,
          color: tc.intelligenceAccent.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

// ── Community Header Section ──────────────────────────────────────────────────
class _CommunityHeader extends StatelessWidget {
  final String communityName;
  final String description;
  final String followerCount;
  final String postCount;
  final String memberCount;
  final List<String> categories;
  final bool isOwner;
  final bool isFollowing;
  final VoidCallback onFollowTap;
  final VoidCallback onDashboardTap;
  final ThemeColors tc;

  const _CommunityHeader({
    required this.communityName,
    required this.description,
    required this.followerCount,
    required this.postCount,
    required this.memberCount,
    required this.categories,
    required this.isOwner,
    required this.isFollowing,
    required this.onFollowTap,
    required this.onDashboardTap,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo + Name row ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 72,
                height: 36,
                child: OverflowBox(
                  alignment: Alignment.bottomCenter,
                  minHeight: 72,
                  maxHeight: 72,
                  minWidth: 72,
                  maxWidth: 72,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: tc.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: tc.background, width: 4),
                      gradient: LinearGradient(
                        colors: [tc.intelligenceAccentDim, tc.limeDim],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.trending_up_rounded,
                        color: tc.intelligenceAccent,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  communityName,
                                  style: GoogleFonts.manrope(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: tc.text100,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.verified_rounded,
                                    color: tc.coreAction, size: 18),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Stats row ──────────────────────────────────────────────────
          Row(
            children: [
              _StatBadge(value: followerCount, label: 'Followers', tc: tc),
              _StatDivider(tc: tc),
              _StatBadge(value: postCount, label: 'Posts', tc: tc),
              _StatDivider(tc: tc),
              _StatBadge(value: memberCount, label: 'Members', tc: tc),
            ],
          ),
          const SizedBox(height: 12),

          // ── Description ────────────────────────────────────────────────
          Text(
            description,
            style: AppTypography.bodySm.copyWith(
              color: tc.text70,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // ── Category chips ─────────────────────────────────────────────
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: categories
                .map((c) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tc.surface2,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: tc.border),
                      ),
                      child: Text(
                        c,
                        style: AppTypography.bodySm.copyWith(
                          color: tc.text70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // ── Action buttons ─────────────────────────────────────────────
          Row(
            children: [
              if (!isOwner)
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: onFollowTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing
                            ? tc.surface2
                            : tc.intelligenceAccent,
                        foregroundColor: isFollowing
                            ? tc.text70
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                          side: isFollowing
                              ? BorderSide(color: tc.border)
                              : BorderSide.none,
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(
                        isFollowing
                            ? Icons.check_rounded
                            : Icons.add_rounded,
                        size: 18,
                      ),
                      label: Text(
                        isFollowing ? 'Following' : 'Follow',
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              if (isOwner) ...[
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: onDashboardTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tc.intelligenceAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.bar_chart_rounded, size: 18),
                      label: Text(
                        'Dashboard',
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 10),
              SizedBox(
                height: 42,
                width: 42,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: tc.border),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Icon(
                    Icons.share_outlined,
                    color: tc.text70,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final ThemeColors tc;
  const _StatBadge(
      {required this.value, required this.label, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTypography.bodyMd.copyWith(
              color: tc.text100,
              fontWeight: FontWeight.w700,
            )),
        Text(label,
            style: AppTypography.bodySm
                .copyWith(color: tc.text40, fontSize: 11)),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  final ThemeColors tc;
  const _StatDivider({required this.tc});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: tc.border,
    );
  }
}

// ── Tab bar delegate ─────────────────────────────────────────────────────────
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;
  final Color borderColor;

  _SliverTabBarDelegate(this.tabBar, this.backgroundColor, this.borderColor);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          tabBar,
          Divider(height: 1, color: borderColor),
        ],
      ),
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  double get minExtent => tabBar.preferredSize.height + 1;

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

// ── Posts Tab ─────────────────────────────────────────────────────────────────
class _PostsTab extends StatelessWidget {
  final List<_MockPost> posts;
  final bool isOwner;
  final ThemeColors tc;

  const _PostsTab(
      {required this.posts, required this.isOwner, required this.tc});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, color: tc.text20, size: 56),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: AppTypography.bodyMd.copyWith(color: tc.text40),
            ),
            if (isOwner) ...[
              const SizedBox(height: 8),
              Text(
                'Tap + New Post to get started',
                style: AppTypography.bodySm.copyWith(color: tc.text40),
              ),
            ],
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return CommunityPostCard(
          authorName: post.author,
          authorAvatarUrl: post.avatarUrl,
          timeAgo: post.timeAgo,
          captionText: post.caption,
          imageUrl: post.imageUrl,
          initialScore: post.score,
          commentCount: post.comments,
          isOwner: isOwner && post.isLeaderPost,
          onCommentTap: () =>
              CommentsSheet.show(context, postId: index),
          onDeleteTap: () => _showDeleteDialog(context),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: tc.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text('Delete post?',
            style: AppTypography.headlineMd.copyWith(color: tc.text100)),
        content: Text(
          'This will permanently delete this post. This action cannot be undone.',
          style: AppTypography.bodySm.copyWith(color: tc.text70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: tc.text70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Delete',
                style: TextStyle(
                    color: tc.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── About Tab ─────────────────────────────────────────────────────────────────
class _AboutTab extends StatelessWidget {
  final String description;
  final List<String> categories;
  final List<String> rules;
  final ThemeColors tc;

  const _AboutTab({
    required this.description,
    required this.categories,
    required this.rules,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        _AboutSection(
          title: 'About',
          tc: tc,
          child: Text(
            description,
            style: AppTypography.bodyMd.copyWith(color: tc.text70, height: 1.55),
          ),
        ),
        const SizedBox(height: 20),
        _AboutSection(
          title: 'Topics',
          tc: tc,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map((c) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: tc.intelligenceAccentDim,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: tc.intelligenceAccent),
                      ),
                      child: Text(c,
                          style: AppTypography.bodySm.copyWith(
                            color: tc.intelligenceAccent,
                            fontWeight: FontWeight.w600,
                          )),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        _AboutSection(
          title: 'Community Rules',
          tc: tc,
          child: Column(
            children: rules.asMap().entries.map((e) {
              final idx = e.key + 1;
              final rule = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: tc.limeDim,
                        shape: BoxShape.circle,
                        border: Border.all(color: tc.limeBorder),
                      ),
                      child: Center(
                        child: Text(
                          '$idx',
                          style: AppTypography.bodySm.copyWith(
                            color: tc.coreAction,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        rule,
                        style: AppTypography.bodySm
                            .copyWith(color: tc.text70, height: 1.4),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        _AboutSection(
          title: 'Created',
          tc: tc,
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  color: tc.text40, size: 16),
              const SizedBox(width: 8),
              Text(
                'January 15, 2025',
                style: AppTypography.bodySm.copyWith(color: tc.text70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  final String title;
  final Widget child;
  final ThemeColors tc;

  const _AboutSection({
    required this.title,
    required this.child,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headlineMd.copyWith(
              color: tc.text100,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ── Mock data model ──────────────────────────────────────────────────────────
class _MockPost {
  final String author;
  final String avatarUrl;
  final String timeAgo;
  final String caption;
  final String? imageUrl;
  final int score;
  final int comments;
  final bool isLeaderPost;

  const _MockPost({
    required this.author,
    required this.avatarUrl,
    required this.timeAgo,
    required this.caption,
    this.imageUrl,
    required this.score,
    required this.comments,
    required this.isLeaderPost,
  });
}
