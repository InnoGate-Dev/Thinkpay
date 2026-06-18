import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

const _kGreen = Color(0xFFC1FF72);
const _kDark = Color(0xFF0A0A0A);

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoCtrl;
  bool _videoReady = false;

  late final AnimationController _entryCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();

    // Make status-bar icons light for dark video background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
    );

    // Entry animation – slides content up while fading in
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    // Shimmer loop on the button
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _shimmerAnim = CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear);

    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoCtrl = VideoPlayerController.asset('lib/assets/startup_video.mp4');
    await _videoCtrl.initialize();
    _videoCtrl
      ..setLooping(true)
      ..setVolume(0.0)
      ..play();
    if (mounted) {
      setState(() => _videoReady = true);
      _entryCtrl.forward();
    }
  }

  @override
  void dispose() {
    _videoCtrl.dispose();
    _entryCtrl.dispose();
    _shimmerCtrl.dispose();
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
    if (!_videoReady) {
      return const _LoadingShell();
    }

    return Scaffold(
      backgroundColor: _kDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoCtrl.value.size.width,
              height: _videoCtrl.value.size.height,
              child: VideoPlayer(_videoCtrl),
            ),
          ),

          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.35, 0.65, 1.0],
                colors: [
                  _kDark.withOpacity(0.40),
                  Colors.transparent,
                  _kDark.withOpacity(0.60),
                  _kDark.withOpacity(0.98),
                ],
              ),
            ),
          ),

          SafeArea(
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
                      _LogoBadge(),

                      const Spacer(),
                      _TagPill(label: 'SMART FINANCE · AI POWERED'),
                      const SizedBox(height: 14),

                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.15,
                            letterSpacing: -1.0,
                          ),
                          children: [
                            TextSpan(text: 'Think\n'),
                            TextSpan(
                              text: 'before\n',
                              style: TextStyle(
                                color: _kGreen,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            TextSpan(text: 'you pay.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Track every rupee, spot bad habits,\nand take control of your finances.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.65,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.60),
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 40),

                      _ShimmerButton(
                        shimmer: _shimmerAnim,
                        label: 'Get Started',
                        onTap: _onGetStarted,
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
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.45),
                                ),
                                children: [
                                  const TextSpan(text: 'Already a member?  '),
                                  TextSpan(
                                    text: 'Sign in',
                                    style: TextStyle(
                                      color: _kGreen.withOpacity(0.9),
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
        ],
      ),
    );
  }
}

class _LoadingShell extends StatelessWidget {
  const _LoadingShell();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDark,
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
            const Text(
              'ThinkPay',
              style: TextStyle(
                color: _kGreen,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // const SizedBox(width: 10),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            children: [
              TextSpan(
                text: 'Think',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Pay',
                style: TextStyle(color: _kGreen),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _kGreen.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _kGreen.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: _kGreen,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}

class _ShimmerButton extends StatelessWidget {
  final Animation<double> shimmer;
  final String label;
  final VoidCallback onTap;

  const _ShimmerButton({
    required this.shimmer,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: shimmer,
        builder: (_, __) {
          return Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: const [_kGreen, Color(0xFFDFFF8A), _kGreen],
                stops: [
                  (shimmer.value - 0.35).clamp(0.0, 1.0),
                  shimmer.value.clamp(0.0, 1.0),
                  (shimmer.value + 0.35).clamp(0.0, 1.0),
                ],
              ),

            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kDark,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 32,
                  height: 32,

                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: _kDark,
                    size: 18,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
