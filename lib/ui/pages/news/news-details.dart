import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/model/news_model.dart';
import 'package:flutter/material.dart';

class NewsDetailsPage extends StatelessWidget {
  final NewsModel news;

  const NewsDetailsPage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                news.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: colors.surface2,
                  child: Icon(Icons.image_outlined, color: colors.text40, size: 64),
                ),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.3),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  child: IconButton(
                    icon: const Icon(Icons.bookmark_border_rounded, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.intelligenceAccentDim,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          news.category,
                          style: AppTypography.labelCaps.copyWith(
                            color: colors.intelligenceAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        news.timeAgo,
                        style: AppTypography.bodySm.copyWith(color: colors.text40),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    news.title,
                    style: AppTypography.headlineLgMobile.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.text100,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(news.sourceIconUrl),
                        backgroundColor: colors.surface2,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        news.sourceName,
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.text100,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 48),
                  
                  // Why this matters section
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.intelligenceAccentDim.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: colors.intelligenceAccent.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: colors.intelligenceAccent, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'WHY THIS MATTERS',
                              style: AppTypography.labelCaps.copyWith(
                                color: colors.intelligenceAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Text(
                          news.whyItMatters,
                          style: AppTypography.bodyMd.copyWith(
                            color: colors.text70,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  Text(
                    news.content,
                    style: AppTypography.bodyLg.copyWith(
                      color: colors.text70,
                      height: 1.8,
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Space at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
