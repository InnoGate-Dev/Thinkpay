
import 'package:Thinkpay/model/userModel.dart';

class Comment {
  final int id;
  final int postId;
  final int? authorId;
  final int? parentCommentId;
  final String content;
  final User? author;
  final List<Comment> replies;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Comment({
    required this.id,
    required this.postId,
    this.authorId,
    this.parentCommentId,
    required this.content,
    this.author,
    this.replies = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['post_id'],
      authorId: json['author_id'],
      parentCommentId: json['parent_comment_id'],
      content: json['content'] ?? '',
      author: json['author'] != null
          ? User.fromJson(json['author'])
          : null,
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((e) => Comment.fromJson(e))
              .toList()
          : [],
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
      'post_id': postId,
      'author_id': authorId,
      'parent_comment_id': parentCommentId,
      'content': content,
      'author': author?.toJson(),
      'replies': replies.map((e) => e.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}