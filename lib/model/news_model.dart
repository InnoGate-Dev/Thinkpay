class NewsModel {
  final String title;
  final String category;
  final String whyItMatters;
  final String imageUrl;
  final String sourceName;
  final String sourceIconUrl;
  final String timeAgo;
  final String content;

  NewsModel({
    required this.title,
    required this.category,
    required this.whyItMatters,
    required this.imageUrl,
    required this.sourceName,
    required this.sourceIconUrl,
    required this.timeAgo,
    this.content = '',
  });
}
