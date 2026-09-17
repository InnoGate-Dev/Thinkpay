import '../../model/auth_responceModel.dart';
import '../../model/userModel.dart';
import '../../model/dashboardModel.dart';
import '../../services/auth_service.dart';
import '../../services/userService.dart';
import '../../services/leaderService.dart';
import '../../core/storage/token_storage.dart';
import '../../core/constant/app_config.dart';
import '../../core/network/api_client.dart';

/// Repository that orchestrates auth, user profile, and leader operations.
///
/// This is the single entry-point the UI / providers should call.
/// It wires together [AuthService], [UserService], [LeaderService],
/// and [TokenStorage] so callers never have to touch raw Maps.
class UserRepository {
  late final AuthService _authService;
  late final UserService _userService;
  late final LeaderService _leaderService;
  final TokenStorage _tokenStorage = TokenStorage();

  UserRepository() {
    final client = ApiClient(baseUrl: AppConfig.baseUrl);
<<<<<<< HEAD
    _authService = AuthService(client);
    _userService = UserService(client);
=======
    _authService  = AuthService(client);
    _userService  = UserService(client);
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
    _leaderService = LeaderService(client);
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Registers a new user and persists the returned JWT token.
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required DateTime birthday,
    bool isLeader = false,
    String? socialMediaChannelName,
  }) async {
    final raw = await _authService.register(
      name: name,
      email: email,
      password: password,
      birthday: birthday.toUtc().toIso8601String(),
      isLeader: isLeader,
      socialMediaChannelName: socialMediaChannelName,
    );
    return _parseAndPersistAuth(raw);
  }

  /// Signs in an existing user and persists the returned JWT token.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final raw = await _authService.login(email: email, password: password);
    return _parseAndPersistAuth(raw);
  }

  /// Authenticates via Google OAuth and persists the returned JWT token.
  Future<AuthResponse> googleSignIn({
    required String googleProviderId,
    required String email,
    required String name,
  }) async {
    final raw = await _authService.googleAuth(
      googleProviderId: googleProviderId,
      email: email,
      name: name,
    );
    return _parseAndPersistAuth(raw);
  }

  /// Removes the stored JWT (logout).
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }

  // ── User ──────────────────────────────────────────────────────────────────

  /// Upgrades the currently logged-in user to a leader role.
  Future<void> upgradeToLeader({
    required String socialMediaChannelName,
    required int roughFollowCount,
  }) async {
    await _userService.upgradeToLeader(
      socialMediaChannelName: socialMediaChannelName,
      roughFollowCount: roughFollowCount,
    );
  }

  // ── Leader ────────────────────────────────────────────────────────────────

  /// Returns the leader's dashboard statistics.
  Future<LeaderDashboard> getLeaderDashboard() async {
    final raw = await _leaderService.getDashboardStats();
    return LeaderDashboard.fromJson(raw);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

<<<<<<< HEAD
  /// Parses a raw auth response map, saves the token + expiry, and returns [AuthResponse].
  Future<AuthResponse> _parseAndPersistAuth(Map<String, dynamic> raw) async {
    final authResponse = AuthResponse.fromJson(raw);
    await _tokenStorage.saveToken(authResponse.token);
    if (authResponse.expiresAt != null) {
      await _tokenStorage.saveExpiresAt(authResponse.expiresAt!);
    }
=======
  /// Parses a raw auth response map, saves the token, and returns [AuthResponse].
  Future<AuthResponse> _parseAndPersistAuth(Map<String, dynamic> raw) async {
    final authResponse = AuthResponse.fromJson(raw);
    await _tokenStorage.saveToken(authResponse.token);
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
    return authResponse;
  }

  /// Returns the currently stored [User] token, or null if not authenticated.
  Future<String?> getStoredToken() => _tokenStorage.getToken();

<<<<<<< HEAD
  /// Returns true if a valid, non-expired JWT is currently stored.
  Future<bool> get isLoggedIn async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) return false;
    final expiresAt = await _tokenStorage.getExpiresAt();
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      // Token has expired — clean up and redirect to login
      await _tokenStorage.deleteToken();
      return false;
    }
    return true;
=======
  /// Returns true if a JWT is currently stored (user is logged in).
  Future<bool> get isLoggedIn async {
    final token = await _tokenStorage.getToken();
    return token != null && token.isNotEmpty;
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
  }
}
