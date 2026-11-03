class ApiEndpoints {
  // Base
  static const String health = '/health';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleAuth = '/auth/google';
  static const String logout = '/auth/logout';

  // // Users
  static const String upgradeToLeader = '/users/upgrade-to-leader';
  static const String currentUser = '/users/me';
  static const String changePassword = '/users/me/password';

  /// Country + currency stored in `profile_config` (PUT).
  static const String profileConfig = '/users/me/profile-config';

  // Leader
  static const String leaderDashboard = '/leader/dashboard';

  //Communities
  static const String communities = '/communities';
  static String communityById(int id) => '/communities/$id';
  static String followCommunity(int id) => '/communities/$id/follow';
  static String unfollowCommunity(int id) => '/communities/$id/follow';

  // Posts
  static String communityPosts(int communityId) => '/communities/$communityId/posts';
  static String postById(int id) => '/posts/$id';
  static String likePost(int id) => '/posts/$id/like';
  static String unlikePost(int id) => '/posts/$id/like';

  // Comments
  static String postComments(int postId) => '/posts/$postId/comments';
  static String commentById(int id) => '/comments/$id';

  // Categories
  static const String categories = '/categories';
  static String categoryById(int id) => '/categories/$id';

  // Goals
  static const String goals = '/goals';
  static String goalById(String id) => '/goals/$id';

  // Transactions
  static const String transactions = '/transactions';
  static String transactionById(int id) => '/transactions/$id';

  // Loans
  static const String loans = '/loans';
  static String loanById(int id) => '/loans/$id';
  static String loanPayments(int loanId) => '/loans/$loanId/payments';
  static String loanPaymentById(int loanId, int id) =>
      '/loans/$loanId/payments/$id';

  // Credit Cards
  static const String creditCards = '/credit-cards';
  static String creditCardById(int id) => '/credit-cards/$id';

  /// Credit card spending entries themselves (`POST` / `GET`).
  static const String creditCardTransactions = '/credit-card-transactions';

  /// Entries charged to one card (`GET`, paginated).
  static String creditCardTransactionsByCard(int id) =>
      '/credit-cards/$id/transactions';

  // goal transaction

  static const String goalTrasections = '/goaltransactions';

  static String getgoalTrasection() => goalTrasections;

  /// Single goal-transaction resource. Note the path id is the *transaction*
  /// id, not the goal id — the route is `PUT|DELETE /goaltransactions/{id}`.
  static String goalTrasectionById(int id) => '/goaltransactions/$id';

  // Notifications
  static const String notifications = '/notifications';
  static const String unreadNotificationCount = '/notifications/unread-count';
  static String notificationById(int id) => '/notifications/$id';
  static String markNotificationAsRead(int id) => '/notifications/$id/read';
  static const String markAllNotificationsAsRead = '/notifications/read-all';
  static String deleteNotification(int id) => '/notifications/$id';
}
