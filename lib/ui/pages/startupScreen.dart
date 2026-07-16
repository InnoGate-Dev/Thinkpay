import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:Thinkpay/constant/app_colors.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _loading = false);
        _entryCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    Navigator.of(context).pushNamed('/signup');
  }

  void _onSignIn() {
    Navigator.of(context).pushNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );

    if (_loading) {
      return Scaffold(
        backgroundColor: tc.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'lib/assets/b96e24fe-1177-11ee-8205-f72df299f15f.json',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                'ThinkPay',
                style: GoogleFonts.manrope(
                  color: tc.text100,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: tc.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _LogoBadge(tc: tc),

                  const Spacer(),
                  _TagPill(label: 'SMART FINANCE · AI POWERED', tc: tc),
                  const SizedBox(height: 14),

                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.manrope(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: tc.text100,
                        height: 1.15,
                        letterSpacing: -1.0,
                      ),
                      children: [
                        const TextSpan(text: 'Think\n'),
                        TextSpan(
                          text: 'before\n',
                          style: GoogleFonts.manrope(
                            color: tc.coreAction,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const TextSpan(text: 'you pay.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Track every rupee, spot bad habits,\nand take control of your finances.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.65,
                      fontWeight: FontWeight.w400,
                      color: tc.text70,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _onGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tc.coreAction,
                        foregroundColor: isDark ? const Color(0xFF141817) : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Center(
                    child: GestureDetector(
                      onTap: _onSignIn,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: tc.text40,
                            ),
                            children: [
                              const TextSpan(text: 'Already a member?  '),
                              TextSpan(
                                text: 'Sign in',
                                style: GoogleFonts.inter(
                                  color: tc.coreAction,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  final ThemeColors tc;
  const _LogoBadge({required this.tc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.manrope(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(text: 'Think', style: TextStyle(color: tc.text100)),
              TextSpan(text: 'Pay', style: TextStyle(color: tc.coreAction)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final ThemeColors tc;
  const _TagPill({required this.label, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: tc.coreActionDim,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tc.coreAction.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: tc.coreAction,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}
