import 'package:Thinkpay/ui/pages/finance/finacedashboard.dart';
import 'package:Thinkpay/ui/pages/loan/loan_list_page.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/theme_provider.dart';
import 'package:Thinkpay/ui/component/navbar.dart';
import 'package:Thinkpay/ui/pages/Splash_screen.dart';
import 'package:Thinkpay/ui/pages/auth/forgetpass.dart';
import 'package:Thinkpay/ui/pages/auth/login.dart';
import 'package:Thinkpay/ui/pages/auth/signup.dart';
import 'package:Thinkpay/model/news_model.dart';
import 'package:Thinkpay/ui/pages/community/communityUpdate.dart';
import 'package:Thinkpay/ui/pages/community/create_community.dart';
import 'package:Thinkpay/ui/pages/community/community_profile.dart';
import 'package:Thinkpay/ui/pages/community/community_dashboard.dart';
import 'package:Thinkpay/ui/pages/news/news-details.dart';
import 'package:Thinkpay/ui/pages/news/news.dart';
import 'package:Thinkpay/ui/pages/profile/EditProfile.dart';
import 'package:Thinkpay/ui/pages/profile/Profile.dart';
import 'package:Thinkpay/ui/pages/security/security.dart';
import 'package:Thinkpay/ui/pages/startupScreen.dart';
import 'package:Thinkpay/ui/pages/onboarding/onboarding.dart';
import 'package:Thinkpay/ui/pages/support/support.dart';
import 'package:Thinkpay/ui/pages/Notification.dart';
import 'package:Thinkpay/ui/pages/transections/Trasections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const ThinkPay());
}

class ThinkPay extends StatelessWidget {
  const ThinkPay({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeNotifier(),
      builder: (context, _) {
        return MaterialApp(
          title: 'Society of 1%',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeNotifier().mode,
          home: const SplashScreen(),
          routes: routes,
        );
      },
    );
  }
}

final routes = <String, WidgetBuilder>{
  '/startup': (context) => StartupScreen(),
  '/onboarding': (context) => const OnboardingPage(),
  '/signup': (context) => const SignUp(),
  '/login': (context) => const Login(),
  '/forgetpass': (context) => const ForgotPassword(),
  '/home': (context) => const AppShell(initialIndex: 0),
  '/notification': (context) => NotificationPage(),
  '/budget': (context) => const AppShell(initialIndex: 1),
  '/goal': (context) => const AppShell(initialIndex: 4),
  '/profile': (context) => const Profile(),
  '/editprofile': (context) => const EditProfilePage(),
  '/security': (context) => const SecurityPage(),
  '/support': (context) => const SupportPage(),
  '/transaction': (context) => Transection(),
  '/news': (context) => const NewsPage(),
  '/loan': (context) => LoanListPage(),
  '/news-details': (context) => NewsDetailsPage(
    news: ModalRoute.of(context)!.settings.arguments as NewsModel,
  ),
  '/finance-dashboard': (context) => const FinanceDashboardPage(),
  '/community-update': (context) => CommunityUpdatePage(),
  '/create-community': (context) => const CreateCommunityPage(),
  '/community-profile': (context) => const CommunityProfilePage(),
  '/community-profile-owner': (context) =>
      const CommunityProfilePage(isOwner: true),
  '/community-dashboard': (context) => const CommunityDashboardPage(),
};
