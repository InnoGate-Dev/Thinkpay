class LeaderDashboard {
  final int totalCommunities;
  final int totalFollowers;
  final int totalPosts;
  final int totalReactions;

  LeaderDashboard({
    required this.totalCommunities,
    required this.totalFollowers,
    required this.totalPosts,
    required this.totalReactions,
  });

  factory LeaderDashboard.fromJson(Map<String, dynamic> json) {
    return LeaderDashboard(
      totalCommunities: json['total_communities'] ?? 0,
      totalFollowers: json['total_followers'] ?? 0,
      totalPosts: json['total_posts'] ?? 0,
      totalReactions: json['total_reactions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_communities': totalCommunities,
      'total_followers': totalFollowers,
      'total_posts': totalPosts,
      'total_reactions': totalReactions,
    };
  }
}