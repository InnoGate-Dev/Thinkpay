class ApiEndpoints {
  // Base
  static const String health = '/health';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleAuth = '/auth/google';

<<<<<<< HEAD
  // // Users
=======
  // Users
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
  static const String upgradeToLeader = '/users/upgrade-to-leader';

  // Leader
  static const String leaderDashboard = '/leader/dashboard';

<<<<<<< HEAD
  //Communities
=======
  // Communities
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
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
<<<<<<< HEAD
  static String goalById(String id) => '/goals/$id';
=======
  static String goalById(int id) => '/goals/$id';
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7

  // Transactions
  static const String transactions = '/transactions';
  static String transactionById(int id) => '/transactions/$id';
<<<<<<< HEAD

  // Loans
  static const String loans = '/loans';
  static String loanById(int id) => '/loans/$id';
  static String loanPayments(int loanId) => '/loans/$loanId/payments';
=======
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
}