import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Owner-only community management dashboard.
class CommunityDashboardPage extends StatelessWidget {
  const CommunityDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.background,
      appBar: AppBar(
        backgroundColor: tc.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: tc.text100, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Dashboard',
              style: GoogleFonts.manrope(
                color: tc.text100,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Investing 101',
              style: AppTypography.bodySm
                  .copyWith(color: tc.intelligenceAccent, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: tc.text70, size: 22),
            onPressed: () {},
            tooltip: 'Community Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        children: [
          const SizedBox(height: 8),

          // ── Quick Stats ──────────────────────────────────────────────
          _SectionHeader(title: 'Overview', tc: tc),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _StatCard(
                label: 'Total Followers',
                value: '14,218',
                icon: Icons.people_outline_rounded,
                change: '+4.2%',
                isPositive: true,
                tc: tc,
              ),
              _StatCard(
                label: 'Total Posts',
                value: '328',
                icon: Icons.article_outlined,
                change: '+12 this week',
                isPositive: true,
                tc: tc,
              ),
              _StatCard(
                label: 'New This Week',
                value: '342',
                icon: Icons.person_add_outlined,
                change: '+18.6%',
                isPositive: true,
                tc: tc,
              ),
              _StatCard(
                label: 'Engagement Rate',
                value: '7.4%',
                icon: Icons.trending_up_rounded,
                change: '-0.3%',
                isPositive: false,
                tc: tc,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Follower Growth Chart ────────────────────────────────────
          _SectionHeader(title: 'Follower Growth', subtitle: 'Last 6 months', tc: tc),
          const SizedBox(height: 12),
          _GrowthChartCard(tc: tc),
          const SizedBox(height: 24),

          // ── Post Performance ─────────────────────────────────────────
          _SectionHeader(title: 'Top Posts', subtitle: 'by engagement', tc: tc),
          const SizedBox(height: 12),
          ..._topPosts.map((post) => _TopPostRow(post: post, tc: tc)),
          const SizedBox(height: 24),

          // ── Top Members ──────────────────────────────────────────────
          _SectionHeader(
              title: 'Most Active Members', subtitle: 'this week', tc: tc),
          const SizedBox(height: 12),
          ..._topMembers.asMap().entries.map((e) =>
              _MemberRow(rank: e.key + 1, member: e.value, tc: tc)),
          const SizedBox(height: 24),

          // ── Moderation Actions ────────────────────────────────────────
          _SectionHeader(title: 'Community Management', tc: tc),
          const SizedBox(height: 12),
          _ManagementCard(tc: tc),
        ],
      ),
    );
  }

  static final _topPosts = [
    _PostStat(
        title: 'Top 5 ETFs to watch in Q4 2026',
        upvotes: 127,
        comments: 34,
        views: 2840),
    _PostStat(
        title: 'Compound interest — the 8th wonder',
        upvotes: 89,
        comments: 21,
        views: 1920),
    _PostStat(
        title: 'How I built a Rs 1L SIP portfolio',
        upvotes: 52,
        comments: 15,
        views: 1140),
  ];

  static final _topMembers = [
    _MemberStat(
        name: 'Priya S.',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        contribution: '8 posts, 64 upvotes'),
    _MemberStat(
        name: 'Alex T.',
        avatarUrl: 'https://i.pravatar.cc/150?img=7',
        contribution: '5 posts, 41 upvotes'),
    _MemberStat(
        name: 'Daniel M.',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        contribution: '3 posts, 38 upvotes'),
    _MemberStat(
        name: 'Sarah K.',
        avatarUrl: 'https://i.pravatar.cc/150?img=9',
        contribution: '4 posts, 29 upvotes'),
  ];
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final ThemeColors tc;
  const _SectionHeader({required this.title, this.subtitle, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: tc.text100,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 6),
          Text(
            subtitle!,
            style: AppTypography.bodySm
                .copyWith(color: tc.text40, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String change;
  final bool isPositive;
  final ThemeColors tc;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.change,
    required this.isPositive,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = isPositive ? tc.coreAction : tc.red;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: tc.text40, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodySm
                      .copyWith(color: tc.text40, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: tc.text100,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: isPositive ? tc.limeDim : tc.redDim,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: changeColor,
                  size: 11,
                ),
                const SizedBox(width: 3),
                Text(
                  change,
                  style: AppTypography.bodySm.copyWith(
                    color: changeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Growth Chart (bar chart) ──────────────────────────────────────────────────
class _GrowthChartCard extends StatelessWidget {
  final ThemeColors tc;
  const _GrowthChartCard({required this.tc});

  static const _months = ['Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];
  static const _values = [7400, 8900, 10200, 11500, 12800, 14218];

  @override
  Widget build(BuildContext context) {
    final maxVal = _values.reduce((a, b) => a > b ? a : b).toDouble();

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
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tc.limeDim,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '+91.9% total growth',
                  style: AppTypography.bodySm.copyWith(
                    color: tc.coreAction,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _values.asMap().entries.map((e) {
                final frac = e.value / maxVal;
                return Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: frac,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      tc.intelligenceAccent,
                                      tc.intelligenceAccentDim,
                                    ],
                                  ),
                                  borderRadius:
                                      const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _months[e.key],
                          style: AppTypography.bodySm.copyWith(
                            color: tc.text40,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top Post Row ──────────────────────────────────────────────────────────────
class _PostStat {
  final String title;
  final int upvotes;
  final int comments;
  final int views;
  const _PostStat(
      {required this.title,
      required this.upvotes,
      required this.comments,
      required this.views});
}

class _TopPostRow extends StatelessWidget {
  final _PostStat post;
  final ThemeColors tc;
  const _TopPostRow({required this.post, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: AppTypography.bodySm.copyWith(
              color: tc.text100,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _PostMetric(
                  icon: Icons.arrow_upward_rounded,
                  value: '${post.upvotes}',
                  color: tc.coreAction),
              const SizedBox(width: 14),
              _PostMetric(
                  icon: Icons.chat_bubble_outline_rounded,
                  value: '${post.comments}',
                  color: tc.text40),
              const SizedBox(width: 14),
              _PostMetric(
                  icon: Icons.visibility_outlined,
                  value: '${post.views}',
                  color: tc.text40),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  const _PostMetric(
      {required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(value,
            style: AppTypography.bodySm
                .copyWith(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Member Row ────────────────────────────────────────────────────────────────
class _MemberStat {
  final String name;
  final String avatarUrl;
  final String contribution;
  const _MemberStat(
      {required this.name,
      required this.avatarUrl,
      required this.contribution});
}

class _MemberRow extends StatelessWidget {
  final int rank;
  final _MemberStat member;
  final ThemeColors tc;
  const _MemberRow(
      {required this.rank, required this.member, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tc.border),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank == 1
                  ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                  : rank == 2
                      ? const Color(0xFFC0C0C0).withValues(alpha: 0.15)
                      : tc.surface2,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: AppTypography.bodySm.copyWith(
                  color: rank == 1
                      ? const Color(0xFFFFD700)
                      : rank == 2
                          ? const Color(0xFFC0C0C0)
                          : tc.text40,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(member.avatarUrl),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppTypography.bodySm.copyWith(
                      color: tc.text100, fontWeight: FontWeight.w700),
                ),
                Text(
                  member.contribution,
                  style: AppTypography.bodySm
                      .copyWith(color: tc.text40, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: tc.text20, size: 20),
        ],
      ),
    );
  }
}

// ── Management Card ───────────────────────────────────────────────────────────
class _ManagementCard extends StatelessWidget {
  final ThemeColors tc;
  const _ManagementCard({required this.tc});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        children: [
          _ManagementRow(
            icon: Icons.edit_outlined,
            label: 'Edit Community Profile',
            onTap: () {},
            tc: tc,
          ),
          Divider(height: 1, color: tc.divider),
          _ManagementRow(
            icon: Icons.people_outline_rounded,
            label: 'Manage Members',
            onTap: () {},
            tc: tc,
          ),
          Divider(height: 1, color: tc.divider),
          _ManagementRow(
            icon: Icons.shield_outlined,
            label: 'Moderation Queue',
            badge: '3',
            onTap: () {},
            tc: tc,
          ),
          Divider(height: 1, color: tc.divider),
          _ManagementRow(
            icon: Icons.notifications_outlined,
            label: 'Post Announcement',
            onTap: () {},
            tc: tc,
          ),
          Divider(height: 1, color: tc.divider),
          _ManagementRow(
            icon: Icons.bar_chart_rounded,
            label: 'Export Analytics',
            onTap: () {},
            tc: tc,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ManagementRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ThemeColors tc;
  final String? badge;
  final bool isLast;

  const _ManagementRow({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.tc,
    this.badge,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.vertical(
              bottom: Radius.circular(AppRadius.lg))
          : BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: tc.text70, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMd
                    .copyWith(color: tc.text100, fontWeight: FontWeight.w500),
              ),
            ),
            if (badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tc.red,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  badge!,
                  style: AppTypography.bodySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: tc.text20, size: 20),
          ],
        ),
      ),
    );
  }
}
