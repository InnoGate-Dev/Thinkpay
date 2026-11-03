import '../../model/auth_responceModel.dart';
import '../../model/account_deletion_schedule.dart';
import '../../model/userModel.dart';
import '../../model/dashboardModel.dart';
import '../../services/auth_service.dart';
import '../../services/userService.dart';
import '../../services/leaderService.dart';
import '../../core/errors/exceptions.dart';
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
    _authService = AuthService(client);
    _userService = UserService(client);
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

  /// Logs the user out for real.
  ///
  /// The token is revoked on the backend first so it can no longer be used
  /// against the API; the local token is cleared regardless, so a failed or
  /// offline call (or an already-expired session) never traps the user in a
  /// signed-in state.
  Future<void> logout() async {
    try {
      await _authService.logout();
    } on ApiException {
      // Revocation failed (offline, expired or already revoked token).
      // Local cleanup below still ends the session.
    } finally {
      await _tokenStorage.deleteToken();
    }
  }

  // ── User ──────────────────────────────────────────────────────────────────

  Future<User> getProfile() async =>
      _parseUserResponse(await _userService.getProfile());

  Future<User> updateProfile({
    required String name,
    required DateTime? birthday,
  }) async => _parseUserResponse(await _userService.updateProfile(
        name: name,
        birthday: birthday?.toUtc().toIso8601String(),
      ));

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _userService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  /// Saves the profile preferences and returns the refreshed profile.
  ///
  /// Only the values passed are written: leaving the currency out keeps the one
  /// already stored, so toggling the theme cannot reset it. Changing the
  /// currency never converts existing amounts; the backend only stores the code
  /// so the app can render the matching symbol.
  Future<User> updateProfileConfig({
    String country = '',
    String currency = '',
    String theme = '',
  }) async => _parseUserResponse(
        await _userService.updateProfileConfig(
          country: country,
          currency: currency,
          theme: theme,
        ),
      );

  /// Schedules the deletion of the account on the backend, then drops the local
  /// session so the app can never keep talking to the API with the token of a
  /// deactivated profile.
  Future<AccountDeletionSchedule> deleteAccount() async {
    final raw = await _userService.deleteAccount();
    await _tokenStorage.deleteToken();
    return AccountDeletionSchedule.fromJson(raw);
  }

  User _parseUserResponse(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw FormatException('Profile response did not contain user data.');
    }
    return User.fromJson(data);
  }

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

  /// Parses a raw auth response map, saves the token + expiry, and returns [AuthResponse].
  Future<AuthResponse> _parseAndPersistAuth(Map<String, dynamic> raw) async {
    final authResponse = AuthResponse.fromJson(raw);
    await _tokenStorage.saveToken(authResponse.token);
    if (authResponse.expiresAt != null) {
      await _tokenStorage.saveExpiresAt(authResponse.expiresAt!);
    }
    return authResponse;
  }

  /// Returns the currently stored [User] token, or null if not authenticated.
  Future<String?> getStoredToken() => _tokenStorage.getToken();

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
  }
}
