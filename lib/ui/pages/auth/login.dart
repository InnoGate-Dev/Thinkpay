import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _emailFocused = false;
  bool _passwordFocused = false;

  // Brand colours
  static const Color _bg = Color(0xFF0E0E0E);
  static const Color _lime = Color(0xFFBFFF3C);
  static const Color _surface = Color(0x0DFFFFFF); // 5% white
  static const Color _border = Color(0x12FFFFFF);  // 7% white
  static const Color _borderFocused = Color(0x73BFFF3C); // 45% lime
  static const Color _surfaceFocused = Color(0x0ABFFF3C); // 4% lime

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() => _emailFocused = _emailFocus.hasFocus));
    _passwordFocus.addListener(() => setState(() => _passwordFocused = _passwordFocus.hasFocus));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),

              // ── Logo ──────────────────────────────────────────────
              _LogoRow(),

              const SizedBox(height: 32),

              // ── Welcome tag ───────────────────────────────────────
              _WelcomeTag(),

              const SizedBox(height: 14),

              // ── Headline ──────────────────────────────────────────
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(text: 'Sign in &\n'),
                    TextSpan(
                      text: 'take control.',
                      style: TextStyle(
                        color: _lime,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Track every rupee. Think before you pay.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0x62FFFFFF),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 36),

              // ── Email field ───────────────────────────────────────
              _FieldLabel(label: 'Email address'),
              const SizedBox(height: 8),
              _InputField(
                controller: _emailController,
                focusNode: _emailFocus,
                isFocused: _emailFocused,
                hintText: 'you@example.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              // ── Password field ────────────────────────────────────
              _FieldLabel(label: 'Password'),
              const SizedBox(height: 8),
              _InputField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                isFocused: _passwordFocused,
                hintText: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: const Color(0x3DFFFFFF),
                  ),
                ),
              ),

              // ── Forgot password ───────────────────────────────────
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/forgetpass'),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 13,
                      color: _lime,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Sign in button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _lime,
                    foregroundColor: _bg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: _bg,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 19, color: _bg),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Divider ───────────────────────────────────────────
              const Row(
                children: [
                  Expanded(child: Divider(color: Color(0x12FFFFFF), thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'or continue with',
                      style: TextStyle(fontSize: 12, color: Color(0x38FFFFFF)),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0x12FFFFFF), thickness: 1)),
                ],
              ),

              const SizedBox(height: 24),

              // ── Social buttons ────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      label: 'Google',
                      icon: _GoogleIcon(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SocialButton(
                      label: 'Apple',
                      icon: const Icon(
                        Icons.apple,
                        size: 20,
                        color: Color(0x8DFFFFFF),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Sign up link ──────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0x47FFFFFF),
                      ),
                      children: [
                        TextSpan(text: 'New here? '),
                        TextSpan(
                          text: 'Create an account',
                          style: TextStyle(
                            color: _lime,
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

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _LogoRow extends StatelessWidget {
  static const Color _lime = Color(0xFFBFFF3C);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Hourglass icon drawn with CustomPaint
        SizedBox(
          width: 26,
          height: 26,
          child: CustomPaint(painter: _HourglassPainter()),
        ),
        const SizedBox(width: 8),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(
                text: 'Think',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Pay',
                style: TextStyle(color: _lime),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HourglassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()
      ..color = const Color(0xFF777777)
      ..style = PaintingStyle.fill;
    final topPaint = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.fill;
    final bottomPaint = Paint()
      ..color = const Color(0xCCBFFF3C)
      ..style = PaintingStyle.fill;
    final dotPaint = Paint()
      ..color = const Color(0xFFBFFF3C)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Top bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.1, w * 0.6, h * 0.1),
        const Radius.circular(2),
      ),
      barPaint,
    );
    // Bottom bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.8, w * 0.6, h * 0.1),
        const Radius.circular(2),
      ),
      barPaint,
    );

    // Top triangle (sand)
    final topPath = Path()
      ..moveTo(w * 0.2, h * 0.2)
      ..lineTo(w * 0.8, h * 0.2)
      ..lineTo(w * 0.5, h * 0.5)
      ..close();
    canvas.drawPath(topPath, topPaint);

    // Bottom triangle (sand — lime)
    final bottomPath = Path()
      ..moveTo(w * 0.2, h * 0.8)
      ..lineTo(w * 0.8, h * 0.8)
      ..lineTo(w * 0.5, h * 0.5)
      ..close();
    canvas.drawPath(bottomPath, bottomPaint);

    // Center dot
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.06, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WelcomeTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x1ABFFF3C),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0x40BFFF3C)),
      ),
      child: const Text(
        'WELCOME BACK',
        style: TextStyle(
          fontSize: 11,
          color: Color(0xFFBFFF3C),
          letterSpacing: 0.1 * 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        color: Color(0x59FFFFFF),
        letterSpacing: 0.09 * 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
      decoration: BoxDecoration(
        color: isFocused ? const Color(0x0ABFFF3C) : const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused ? const Color(0x73BFFF3C) : const Color(0x12FFFFFF),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, size: 20, color: const Color(0x40FFFFFF)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0x2EFFFFFF),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffix != null) ...[
            suffix!,
            const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;

  const _SocialButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x12FFFFFF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0x8DFFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 17,
      height: 17,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;

    void draw(Path p, Color c) =>
        canvas.drawPath(p, Paint()..color = c..style = PaintingStyle.fill);

    final blue = Path()
      ..moveTo(22.56 * s, 12.25 * s)
      ..cubicTo(22.56 * s, 11.47 * s, 22.49 * s, 10.72 * s, 22.36 * s, 10 * s)
      ..lineTo(12 * s, 10 * s)
      ..lineTo(12 * s, 14.26 * s)
      ..lineTo(17.92 * s, 14.26 * s)
      ..cubicTo(17.66 * s, 15.63 * s, 16.88 * s, 16.79 * s, 15.71 * s, 17.57 * s)
      ..lineTo(15.71 * s, 20.34 * s)
      ..lineTo(19.28 * s, 20.34 * s)
      ..cubicTo(21.36 * s, 18.42 * s, 22.56 * s, 15.6 * s, 22.56 * s, 12.25 * s)
      ..close();
    draw(blue, const Color(0xFF4285F4));

    final green = Path()
      ..moveTo(12 * s, 23 * s)
      ..cubicTo(14.97 * s, 23 * s, 17.46 * s, 22.02 * s, 19.28 * s, 20.34 * s)
      ..lineTo(15.71 * s, 17.57 * s)
      ..cubicTo(14.73 * s, 18.23 * s, 13.48 * s, 18.63 * s, 12 * s, 18.63 * s)
      ..cubicTo(9.14 * s, 18.63 * s, 6.71 * s, 16.7 * s, 5.84 * s, 14.1 * s)
      ..lineTo(2.18 * s, 14.1 * s)
      ..lineTo(2.18 * s, 16.94 * s)
      ..cubicTo(3.99 * s, 20.53 * s, 7.7 * s, 23 * s, 12 * s, 23 * s)
      ..close();
    draw(green, const Color(0xFF34A853));

    final yellow = Path()
      ..moveTo(5.84 * s, 14.09 * s)
      ..cubicTo(5.62 * s, 13.43 * s, 5.49 * s, 12.73 * s, 5.49 * s, 12 * s)
      ..cubicTo(5.49 * s, 11.27 * s, 5.62 * s, 10.57 * s, 5.84 * s, 9.91 * s)
      ..lineTo(5.84 * s, 7.07 * s)
      ..lineTo(2.18 * s, 7.07 * s)
      ..cubicTo(1.43 * s, 8.55 * s, 1 * s, 10.22 * s, 1 * s, 12 * s)
      ..cubicTo(1 * s, 13.78 * s, 1.43 * s, 15.45 * s, 2.18 * s, 16.93 * s)
      ..lineTo(5.84 * s, 14.09 * s)
      ..close();
    draw(yellow, const Color(0xFFFBBC05));

    final red = Path()
      ..moveTo(12 * s, 5.38 * s)
      ..cubicTo(13.62 * s, 5.38 * s, 15.06 * s, 5.94 * s, 16.21 * s, 7.02 * s)
      ..lineTo(19.36 * s, 3.87 * s)
      ..cubicTo(17.45 * s, 2.09 * s, 14.97 * s, 1 * s, 12 * s, 1 * s)
      ..cubicTo(7.7 * s, 1 * s, 3.99 * s, 3.47 * s, 2.18 * s, 7.07 * s)
      ..lineTo(5.84 * s, 9.91 * s)
      ..cubicTo(6.71 * s, 7.31 * s, 9.14 * s, 5.38 * s, 12 * s, 5.38 * s)
      ..close();
    draw(red, const Color(0xFFEA4335));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}