import 'package:flutter/material.dart';
import 'package:Thinkpay/constant/app_colors.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: tc.text100, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: tc.intelligenceAccentDim,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(Icons.auto_awesome_rounded, color: tc.intelligenceAccent, size: 28),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome back.',
                style: AppTypography.headlineLg.copyWith(
                  color: tc.text100,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in with Google to continue your journey to financial mastery and disciplined tracking.',
                style: AppTypography.bodyMd.copyWith(color: tc.text70),
              ),
              const SizedBox(height: 64),
              _GoogleAuthButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                isPrimary: true,
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                tc: tc,
              ),
              const SizedBox(height: 16),
              _GoogleAuthButton(
                label: 'Continue with Apple',
                icon: Icons.apple_rounded,
                isPrimary: false,
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                tc: tc,
              ),
              const SizedBox(height: 48),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                  child: RichText(
                    text: TextSpan(
                      style: AppTypography.bodySm.copyWith(color: tc.text70),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Join the 1%',
                          style: TextStyle(
                            color: tc.intelligenceAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleAuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;
  final ThemeColors tc;

  const _GoogleAuthButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? tc.intelligenceAccent : tc.surface,
          foregroundColor: isPrimary ? Colors.white : tc.text100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary ? BorderSide.none : BorderSide(color: tc.border),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: isPrimary ? Colors.white : tc.text100),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : tc.text100,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
