import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/model/news_model.dart';
import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {
  final NewsModel news;
  final VoidCallback onTap;

  const NewsCard({
    super.key,
    required this.news,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.network(
                news.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: colors.surface2,
                  child: Icon(Icons.image_outlined, color: colors.text40, size: 48),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Category Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surface2,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                news.category,
                style: AppTypography.labelCaps.copyWith(
                  color: colors.text70,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            
            // Title
            Text(
              news.title,
              style: AppTypography.headlineMd.copyWith(
                color: colors.text100,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Why this matters section
            Container(
              decoration: BoxDecoration(
                color: colors.intelligenceAccentDim.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.base),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: colors.intelligenceAccent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.base),
                          bottomLeft: Radius.circular(AppRadius.base),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline, size: 14, color: colors.text70),
                                const SizedBox(width: 4),
                                Text(
                                  "WHY THIS MATTERS TO YOU",
                                  style: AppTypography.labelCaps.copyWith(
                                    color: colors.text70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              news.whyItMatters,
                              style: AppTypography.bodySm.copyWith(
                                color: colors.text70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Footer
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(news.sourceIconUrl),
                  backgroundColor: colors.surface2,
                ),
                const SizedBox(width: 8),
                Text(
                  news.sourceName,
                  style: AppTypography.bodySm.copyWith(
                    color: colors.text70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  news.timeAgo,
                  style: AppTypography.bodySm.copyWith(
                    color: colors.text40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
