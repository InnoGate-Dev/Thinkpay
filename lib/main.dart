import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/constant/theme_provider.dart';
import 'package:Thinkpay/ui/component/navbar.dart';
import 'package:Thinkpay/ui/pages/Budget/budget.dart';
import 'package:Thinkpay/ui/pages/Splash_screen.dart';
import 'package:Thinkpay/ui/pages/auth/forgetpass.dart';
import 'package:Thinkpay/ui/pages/auth/login.dart';
import 'package:Thinkpay/ui/pages/auth/signup.dart';
import 'package:Thinkpay/ui/pages/startupScreen.dart';
import 'package:Thinkpay/ui/pages/Notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
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
          title: 'ThinkPay',
          debugShowCheckedModeBanner: false,
          theme:      AppTheme.light(),
          darkTheme:  AppTheme.dark(),
          themeMode:  ThemeNotifier().mode,
          home: const SplashScreen(),
          routes: routes,
        );
      },
    );
  }
}

final routes = <String, WidgetBuilder>{
  '/startup':      (context) => StartupScreen(),
  '/signup':       (context) => const SignUp(),
  '/login':        (context) => const Login(),
  '/forgetpass':   (context) => const ForgotPassword(),
  '/home':         (context) => const AppShell(),
  '/notification': (context) => NotificationPage(),
  '/budget':       (context) => BudgetPage(),
};