import 'package:flutter/foundation.dart';

import '../core/repository/userRepo.dart';
import 'user_profile_store.dart';

/// Keeps [UserProfileStore] in step with the backend.
///
/// The drawer, the home greeting and the profile screen all render the store
/// directly, so the profile has to be fetched before they paint — otherwise
/// they show the signed-out placeholder ("User" / "user@thinkpay.app") the
/// first time they are opened.
class ProfileSync {
  ProfileSync._();

  static Future<bool>? _inFlight;

  /// Loads the profile unless it is already in the store.
  ///
  /// Safe to call from every screen: concurrent callers share one request, and
  /// a failed call leaves the previously loaded values untouched so screens
  /// can simply retry.
  static Future<bool> ensureLoaded({bool force = false}) {
    final store = UserProfileStore();
    if (!force && store.isLoaded) return Future.value(true);
    return _inFlight ??= _load(store).whenComplete(() => _inFlight = null);
  }

  static Future<bool> _load(UserProfileStore store) async {
    try {
      store.setUser(await UserRepository().getProfile());
      return true;
    } catch (error) {
      debugPrint('PROFILE SYNC ERROR: $error');
      return false;
    }
  }
}
