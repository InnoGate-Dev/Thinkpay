import 'dart:io';
import '../../model/communityModel.dart';
import '../../model/postModel.dart';
import '../../model/commentModel.dart';
import '../../model/dashboardModel.dart';
import '../../services/community_service.dart';
import '../../services/post_service.dart';
import '../../services/commentService.dart';
import '../../services/leaderService.dart';
import '../../core/constant/app_config.dart';
import '../../core/network/api_client.dart';
import '../../util/uploadmedia.dart';

/// Repository that orchestrates community, post, comment, and leader operations.
///
/// For any operation that involves local [File] objects (images / videos),
/// the repo first uploads them via [uploadMedia] / [uploadMediaFiles] and
/// passes the returned secure URLs to the corresponding service call.
class CommunityRepository {
  late final CommunityService _communityService;
  late final PostService _postService;
  late final CommentService _commentService;
  late final LeaderService _leaderService;

  CommunityRepository() {
    final client = ApiClient(baseUrl: AppConfig.baseUrl);
    _communityService = CommunityService(client);
    _postService      = PostService(client);
    _commentService   = CommentService(client);
    _leaderService    = LeaderService(client);
  }

  // ── Communities ───────────────────────────────────────────────────────────

  /// Creates a new community.
  ///
  /// Pass [logoFile] / [bannerFile] to upload images first;
  /// or supply [logoUrl] / [bannerUrl] if URLs are already known.
  Future<Community> createCommunity({
    required String name,
    required String description,
    File? logoFile,
    File? bannerFile,
    String? logoUrl,
    String? bannerUrl,
  }) async {
    final resolvedLogoUrl   = logoFile   != null ? await uploadMedia(logoFile)   : logoUrl;
    final resolvedBannerUrl = bannerFile != null ? await uploadMedia(bannerFile) : bannerUrl;

    final raw = await _communityService.createCommunity(
      name: name,
      description: description,
      logoUrl: resolvedLogoUrl,
      bannerUrl: resolvedBannerUrl,
    );
    return Community.fromJson(raw);
  }

  /// Fetches a single community by its [id].
  Future<Community> getCommunityById(int id) async {
    final raw = await _communityService.getCommunityById(id);
    return Community.fromJson(raw);
  }

  /// Updates an existing community.
  ///
  /// Accepts optional [File] objects for logo / banner — they are uploaded
  /// before the update request is sent.
  Future<Community> updateCommunity(
    int id, {
    required String name,
    required String description,
    File? logoFile,
    File? bannerFile,
    String? logoUrl,
    String? bannerUrl,
  }) async {
    final resolvedLogoUrl   = logoFile   != null ? await uploadMedia(logoFile)   : logoUrl;
    final resolvedBannerUrl = bannerFile != null ? await uploadMedia(bannerFile) : bannerUrl;

    final raw = await _communityService.updateCommunity(
      id,
      name: name,
      description: description,
      logoUrl: resolvedLogoUrl,
      bannerUrl: resolvedBannerUrl,
    );
    return Community.fromJson(raw);
  }

  /// Deletes a community by its [id].
  Future<void> deleteCommunity(int id) async {
    await _communityService.deleteCommunity(id);
  }

  /// Follows a community and returns the server confirmation message.
  Future<String> followCommunity(int id) async {
    final raw = await _communityService.followCommunity(id);
    return raw['message']?.toString() ?? 'followed';
  }

  /// Unfollows a community.
  Future<void> unfollowCommunity(int id) async {
    await _communityService.unfollowCommunity(id);
  }

  // ── Posts ─────────────────────────────────────────────────────────────────

  /// Creates a post inside [communityId].
  ///
  /// [mediaFiles] are uploaded first; the resulting URLs are bundled
  /// with any pre-resolved [mediaUrls] and sent in the request body.
  Future<Post> createPost(
    int communityId, {
    required String captionText,
    List<File> mediaFiles = const [],
    List<String> mediaUrls = const [],
  }) async {
    final uploadedUrls = mediaFiles.isNotEmpty
        ? await uploadMediaFiles(mediaFiles)
        : <String>[];

    final allMediaUrls = [...uploadedUrls, ...mediaUrls];

    final raw = await _postService.createPost(
      communityId,
      captionText: captionText,
      medias: allMediaUrls,
    );
    return Post.fromJson(raw);
  }

  /// Returns all posts for a given [communityId].
  Future<List<Post>> getCommunityPosts(int communityId) async {
    final rawList = await _postService.getCommunityPosts(communityId);
    return rawList
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single post by its [id].
  Future<Post> getPostById(int id) async {
    final raw = await _postService.getPostById(id);
    return Post.fromJson(raw);
  }

  /// Updates a post's caption and/or media.
  ///
  /// [mediaFiles] are uploaded before the request is sent.
  Future<Post> updatePost(
    int id, {
    required String captionText,
    List<File> mediaFiles = const [],
    List<String> mediaUrls = const [],
  }) async {
    final uploadedUrls = mediaFiles.isNotEmpty
        ? await uploadMediaFiles(mediaFiles)
        : <String>[];

    final allMediaUrls = [...uploadedUrls, ...mediaUrls];

    final raw = await _postService.updatePost(
      id,
      captionText: captionText,
      medias: allMediaUrls,
    );
    return Post.fromJson(raw);
  }

  /// Deletes a post by its [id].
  Future<void> deletePost(int id) async {
    await _postService.deletePost(id);
  }

  /// Likes a post.
  Future<void> likePost(int id) async {
    await _postService.likePost(id);
  }

  /// Removes a like from a post.
  Future<void> unlikePost(int id) async {
    await _postService.unlikePost(id);
  }

  // ── Comments ──────────────────────────────────────────────────────────────

  /// Creates a top-level or reply comment on [postId].
  Future<Comment> createComment(
    int postId, {
    required String content,
    int? parentCommentId,
  }) async {
    final raw = await _commentService.createComment(
      postId,
      content: content,
      parentCommentId: parentCommentId,
    );
    return Comment.fromJson(raw);
  }

  /// Returns all comments for [postId].
  Future<List<Comment>> getPostComments(int postId) async {
    final rawList = await _commentService.getPostComments(postId);
    return rawList
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Updates the content of a comment by its [id].
  Future<Comment> updateComment(int id, {required String content}) async {
    final raw = await _commentService.updateComment(id, content: content);
    return Comment.fromJson(raw);
  }

  /// Deletes a comment by its [id].
  Future<void> deleteComment(int id) async {
    await _commentService.deleteComment(id);
  }

  // ── Leader dashboard ──────────────────────────────────────────────────────

  /// Returns the leader's community dashboard statistics.
  Future<LeaderDashboard> getLeaderDashboard() async {
    final raw = await _leaderService.getDashboardStats();
    return LeaderDashboard.fromJson(raw);
  }
}
