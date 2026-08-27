
import 'package:Thinkpay/model/userModel.dart';

class Post {
  final int id;
  final int? communityId;
  final int? authorId;
  final String captionText;
  final List<String> medias;
  final int? likeCount;
  final int? commentCount;
  final bool? isLiked;
  final User? author;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Post({
    required this.id,
    this.communityId,
    this.authorId,
    required this.captionText,
    required this.medias,
    this.likeCount,
    this.commentCount,
    this.isLiked,
    this.author,
    this.createdAt,
    this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      communityId: json['community_id'],
      authorId: json['author_id'],
      captionText: json['caption_text'] ?? '',
      medias: json['medias'] != null
          ? List<String>.from(json['medias'])
          : [],
      likeCount: json['like_count'],
      commentCount: json['comment_count'],
      isLiked: json['is_liked'],
      author: json['author'] != null
          ? User.fromJson(json['author'])
          : null,
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
      'community_id': communityId,
      'author_id': authorId,
      'caption_text': captionText,
      'medias': medias,
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_liked': isLiked,
      'author': author?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}