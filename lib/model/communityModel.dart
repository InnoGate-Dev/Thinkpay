class Community {
  final int id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final int? ownerId;
  final int? followerCount;
  final int? postCount;
  final bool? isFollowing;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Community({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.ownerId,
    this.followerCount,
    this.postCount,
    this.isFollowing,
    this.createdAt,
    this.updatedAt,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logo_url'],
      bannerUrl: json['banner_url'],
      ownerId: json['owner_id'],
      followerCount: json['follower_count'],
      postCount: json['post_count'],
      isFollowing: json['is_following'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'owner_id': ownerId,
      'follower_count': followerCount,
      'post_count': postCount,
      'is_following': isFollowing,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}