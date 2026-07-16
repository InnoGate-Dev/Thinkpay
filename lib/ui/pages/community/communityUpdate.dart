import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/ui/component/news_category_chip.dart';
import 'package:flutter/material.dart';

class CommunityUpdatePage extends StatefulWidget {
  const CommunityUpdatePage({super.key});

  @override
  State<CommunityUpdatePage> createState() => _CommunityUpdatePageState();
}

class _CommunityUpdatePageState extends State<CommunityUpdatePage> {
  String selectedCategory = 'Investing';

  final List<String> categories = [
    'All Discussions',
    'Investing',
    'Business & Side',
  ];

  final List<CommunityPost> posts = [
    CommunityPost(
      author: 'Marcus J.',
      badge: 'High Impact Contributor',
      title: 'The psychological barrier of the first \$10k invested',
      snippet:
          'Reaching your first \$10,000 in investments often feels significantly harder than reaching \$50,000. It require...',
      helpfulCount: 12,
    ),
    CommunityPost(
      author: 'Sarah K.',
      title: 'Index Funds vs. Individual Stocks: Finding Mental Peace',
      snippet:
          'After years of trying to pick individual stocks and constantly checking market tickers, I shifted 90% of my portfolio to...',
      helpfulCount: 45,
    ),
    CommunityPost(
      author: 'Elena R.',
      badge: 'High Impact Contributor',
      title: 'Rethinking emergency funds in a high-inflation environment',
      snippet:
          'Keeping 6-12 months of expenses purely in cash feels secure, but with rising inflation, it\'s losing purchasing power...',
      helpfulCount: 28,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface3,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline, color: colors.text70, size: 20),
          ),
        ),
        title: Text(
          'DayOne',
          style: AppTypography.headlineMd.copyWith(
            color: colors.text100,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.chat_bubble_outline, color: colors.text100),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            // Categories
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      selectedColor: const Color(0xFF90A494), // Muted sage green from image
                      backgroundColor: colors.surface3,
                      labelStyle: AppTypography.bodySm.copyWith(
                        color: isSelected ? Colors.white : colors.text70,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      side: BorderSide.none,
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Ask a question button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.base),
                    border: Border.all(color: colors.border),
                  ),
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.mode_comment_outlined, size: 16, color: colors.text100),
                    label: Text(
                      'Ask a question',
                      style: AppTypography.bodySm.copyWith(
                        color: colors.text100,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Posts List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              itemCount: posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                return _PostCard(post: posts[index]);
              },
            ),
            const SizedBox(height: 120), // Space for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: _CustomBottomNavBar(colors: colors),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final ThemeColors colors;
  const _CustomBottomNavBar({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(icon: Icons.home_outlined, label: 'Home', isSelected: false, colors: colors),
          _NavBarItem(icon: Icons.account_balance_wallet_outlined, label: 'Finances', isSelected: false, colors: colors),
          _NavBarItem(icon: Icons.people_alt_rounded, label: 'Community', isSelected: true, colors: colors),
          _NavBarItem(icon: Icons.menu_book_outlined, label: 'Learn', isSelected: false, colors: colors),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final ThemeColors colors;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSelected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFD6E9E0), // Very light green highlight
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(icon, color: const Color(0xFF4A6657), size: 24),
          )
        else
          Icon(icon, color: colors.text40, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelCaps.copyWith(
            fontSize: 10,
            color: isSelected ? const Color(0xFF4A6657) : colors.text40,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                post.author,
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.text100,
                ),
              ),
              if (post.badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.surface3,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_outlined, size: 12, color: colors.text70),
                      const SizedBox(width: 4),
                      Text(
                        post.badge!,
                        style: AppTypography.labelCaps.copyWith(
                          fontSize: 10,
                          color: colors.text70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            post.title,
            style: AppTypography.headlineMd.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.text100,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            post.snippet,
            style: AppTypography.bodySm.copyWith(
              color: colors.text70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined, size: 16, color: colors.text40),
              const SizedBox(width: 8),
              Text(
                '${post.helpfulCount} people found this helpful',
                style: AppTypography.bodySm.copyWith(
                  color: colors.text40,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CommunityPost {
  final String author;
  final String? badge;
  final String title;
  final String snippet;
  final int helpfulCount;

  CommunityPost({
    required this.author,
    this.badge,
    required this.title,
    required this.snippet,
    required this.helpfulCount,
  });
}
