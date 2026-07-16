import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/constant/app_colors.dart';

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
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: tc.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              _LogoRow(tc: tc),
              const SizedBox(height: 32),
              _WelcomeTag(tc: tc),
              const SizedBox(height: 14),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.manrope(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: tc.text100,
                    letterSpacing: -1.0,
                  ),
                  children: [
                    const TextSpan(text: 'Sign in &\n'),
                    TextSpan(
                      text: 'take control.',
                      style: GoogleFonts.manrope(
                        color: tc.coreAction,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track every rupee. Think before you pay.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: tc.text40,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),

              _FieldLabel(label: 'Email address', tc: tc),
              const SizedBox(height: 8),
              _InputField(
                controller: _emailController,
                focusNode: _emailFocus,
                isFocused: _emailFocused,
                hintText: 'you@example.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                tc: tc,
              ),
              const SizedBox(height: 20),

              _FieldLabel(label: 'Password', tc: tc),
              const SizedBox(height: 8),
              _InputField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                isFocused: _passwordFocused,
                hintText: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                tc: tc,
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: tc.text40,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/forgetpass'),
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: tc.coreAction,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/home'),
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
                        'Sign in',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 19),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: Divider(color: tc.divider, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'or continue with',
                      style: GoogleFonts.inter(fontSize: 12, color: tc.text40),
                    ),
                  ),
                  Expanded(child: Divider(color: tc.divider, thickness: 1)),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      label: 'Google',
                      icon: _GoogleIcon(),
                      tc: tc,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SocialButton(
                      label: 'Apple',
                      icon: Icon(
                        Icons.apple,
                        size: 20,
                        color: tc.text100,
                      ),
                      tc: tc,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: tc.text70,
                      ),
                      children: [
                        const TextSpan(text: 'New here? '),
                        TextSpan(
                          text: 'Create an account',
                          style: GoogleFonts.inter(
                            color: tc.coreAction,
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

class _LogoRow extends StatelessWidget {
  final ThemeColors tc;
  const _LogoRow({required this.tc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 26,
          height: 26,
          child: CustomPaint(painter: _HourglassPainter(tc: tc)),
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.manrope(
              fontSize: 20,
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

class _HourglassPainter extends CustomPainter {
  final ThemeColors tc;
  _HourglassPainter({required this.tc});

  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()..color = tc.text40..style = PaintingStyle.fill;
    final topPaint = Paint()..color = tc.text20..style = PaintingStyle.fill;
    final bottomPaint = Paint()..color = tc.coreAction.withValues(alpha: 0.8)..style = PaintingStyle.fill;
    final dotPaint = Paint()..color = tc.coreAction..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, h * 0.1, w * 0.6, h * 0.1), const Radius.circular(2)),
      barPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, h * 0.8, w * 0.6, h * 0.1), const Radius.circular(2)),
      barPaint,
    );
    final topPath = Path()
      ..moveTo(w * 0.2, h * 0.2)
      ..lineTo(w * 0.8, h * 0.2)
      ..lineTo(w * 0.5, h * 0.5)
      ..close();
    canvas.drawPath(topPath, topPaint);
    final bottomPath = Path()
      ..moveTo(w * 0.2, h * 0.8)
      ..lineTo(w * 0.8, h * 0.8)
      ..lineTo(w * 0.5, h * 0.5)
      ..close();
    canvas.drawPath(bottomPath, bottomPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.06, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WelcomeTag extends StatelessWidget {
  final ThemeColors tc;
  const _WelcomeTag({required this.tc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: tc.coreActionDim,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: tc.coreAction.withValues(alpha: 0.35)),
      ),
      child: Text(
        'WELCOME BACK',
        style: GoogleFonts.inter(
          fontSize: 11,
          color: tc.coreAction,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final ThemeColors tc;
  const _FieldLabel({required this.label, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        color: tc.text40,
        letterSpacing: 0.99,
        fontWeight: FontWeight.w600,
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
  final ThemeColors tc;

  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.hintText,
    required this.icon,
    required this.tc,
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
        color: isFocused ? tc.surface2 : tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused ? tc.coreAction : tc.border,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, size: 20, color: isFocused ? tc.coreAction : tc.text40),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: GoogleFonts.inter(
                color: tc.text100,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.inter(
                  color: tc.text20,
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
  final ThemeColors tc;

  const _SocialButton({required this.label, required this.icon, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tc.border, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: tc.text70,
              fontWeight: FontWeight.w600,
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

    draw(
      Path()
        ..moveTo(22.56 * s, 12.25 * s)
        ..cubicTo(22.56 * s, 11.47 * s, 22.49 * s, 10.72 * s, 22.36 * s, 10 * s)
        ..lineTo(12 * s, 10 * s)
        ..lineTo(12 * s, 14.26 * s)
        ..lineTo(17.92 * s, 14.26 * s)
        ..cubicTo(17.66 * s, 15.63 * s, 16.88 * s, 16.79 * s, 15.71 * s, 17.57 * s)
        ..lineTo(15.71 * s, 20.34 * s)
        ..lineTo(19.28 * s, 20.34 * s)
        ..cubicTo(21.36 * s, 18.42 * s, 22.56 * s, 15.6 * s, 22.56 * s, 12.25 * s)
        ..close(),
      const Color(0xFF4285F4),
    );
    draw(
      Path()
        ..moveTo(12 * s, 23 * s)
        ..cubicTo(14.97 * s, 23 * s, 17.46 * s, 22.02 * s, 19.28 * s, 20.34 * s)
        ..lineTo(15.71 * s, 17.57 * s)
        ..cubicTo(14.73 * s, 18.23 * s, 13.48 * s, 18.63 * s, 12 * s, 18.63 * s)
        ..cubicTo(9.14 * s, 18.63 * s, 6.71 * s, 16.7 * s, 5.84 * s, 14.1 * s)
        ..lineTo(2.18 * s, 14.1 * s)
        ..lineTo(2.18 * s, 16.94 * s)
        ..cubicTo(3.99 * s, 20.53 * s, 7.7 * s, 23 * s, 12 * s, 23 * s)
        ..close(),
      const Color(0xFF34A853),
    );
    draw(
      Path()
        ..moveTo(5.84 * s, 14.09 * s)
        ..cubicTo(5.62 * s, 13.43 * s, 5.49 * s, 12.73 * s, 5.49 * s, 12 * s)
        ..cubicTo(5.49 * s, 11.27 * s, 5.62 * s, 10.57 * s, 5.84 * s, 9.91 * s)
        ..lineTo(5.84 * s, 7.07 * s)
        ..lineTo(2.18 * s, 7.07 * s)
        ..cubicTo(1.43 * s, 8.55 * s, 1 * s, 10.22 * s, 1 * s, 12 * s)
        ..cubicTo(1 * s, 13.78 * s, 1.43 * s, 15.45 * s, 2.18 * s, 16.93 * s)
        ..lineTo(5.84 * s, 14.09 * s)
        ..close(),
      const Color(0xFFFBBC05),
    );
    draw(
      Path()
        ..moveTo(12 * s, 5.38 * s)
        ..cubicTo(13.62 * s, 5.38 * s, 15.06 * s, 5.94 * s, 16.21 * s, 7.02 * s)
        ..lineTo(19.36 * s, 3.87 * s)
        ..cubicTo(17.45 * s, 2.09 * s, 14.97 * s, 1 * s, 12 * s, 1 * s)
        ..cubicTo(7.7 * s, 1 * s, 3.99 * s, 3.47 * s, 2.18 * s, 7.07 * s)
        ..lineTo(5.84 * s, 9.91 * s)
        ..cubicTo(6.71 * s, 7.31 * s, 9.14 * s, 5.38 * s, 12 * s, 5.38 * s)
        ..close(),
      const Color(0xFFEA4335),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}