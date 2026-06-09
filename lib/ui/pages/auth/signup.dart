import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _firstNameFocused = false;
  bool _lastNameFocused = false;
  bool _emailFocused = false;
  bool _passwordFocused = false;
  bool _confirmPasswordFocused = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Brand colours
  static const Color _bg = Color(0xFF0E0E0E);
  static const Color _lime = Color(0xFFBFFF3C);

  @override
  void initState() {
    super.initState();
    _firstNameFocus.addListener(() => setState(() => _firstNameFocused = _firstNameFocus.hasFocus));
    _lastNameFocus.addListener(() => setState(() => _lastNameFocused = _lastNameFocus.hasFocus));
    _emailFocus.addListener(() => setState(() => _emailFocused = _emailFocus.hasFocus));
    _passwordFocus.addListener(() => setState(() => _passwordFocused = _passwordFocus.hasFocus));
    _confirmPasswordFocus.addListener(() => setState(() => _confirmPasswordFocused = _confirmPasswordFocus.hasFocus));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
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

              // ── Tag ───────────────────────────────────────────────
              _TagPill(label: 'Create account'),

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
                    TextSpan(text: 'Start\n'),
                    TextSpan(
                      text: 'thinking smart.',
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
                'One account to track every rupee you spend.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0x62FFFFFF),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 36),

              // ── First & Last name row ─────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel(label: 'First name'),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _firstNameController,
                          focusNode: _firstNameFocus,
                          isFocused: _firstNameFocused,
                          hintText: 'John',
                          icon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.name,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel(label: 'Last name'),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _lastNameController,
                          focusNode: _lastNameFocus,
                          isFocused: _lastNameFocused,
                          hintText: 'Doe',
                          icon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.name,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Email ─────────────────────────────────────────────
              const _FieldLabel(label: 'Email address'),
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

              // ── Password ──────────────────────────────────────────
              const _FieldLabel(label: 'Password'),
              const SizedBox(height: 8),
              _InputField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                isFocused: _passwordFocused,
                hintText: '8+ characters',
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

              const SizedBox(height: 20),

              // ── Confirm password ──────────────────────────────────
              const _FieldLabel(label: 'Confirm password'),
              const SizedBox(height: 8),
              _InputField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocus,
                isFocused: _confirmPasswordFocused,
                hintText: 'Repeat password',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscureConfirmPassword,
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  child: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: const Color(0x3DFFFFFF),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Password hint ─────────────────────────────────────
              const Text(
                'Use at least 8 characters with a number and a symbol.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0x40FFFFFF),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // ── Sign up button ────────────────────────────────────
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
                        'Create account',
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

              const SizedBox(height: 16),

              // ── Terms note ────────────────────────────────────────
              Center(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0x3DFFFFFF),
                      height: 1.6,
                    ),
                    children: [
                      const TextSpan(text: 'By signing up you agree to our '),
                      TextSpan(
                        text: 'Terms',
                        style: const TextStyle(
                          color: _lime,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: _lime,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
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
                      'or sign up with',
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
                      icon: SizedBox(
                        width: 17,
                        height: 17,
                        child: CustomPaint(painter: _GooglePainter()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _SocialButton(
                      label: 'Apple',
                      icon: Icon(
                        Icons.apple,
                        size: 20,
                        color: Color(0x8DFFFFFF),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Login link ────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/login'),
                  child: Text.rich(
                    const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0x47FFFFFF),
                      ),
                      children: [
                        TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign in',
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
              TextSpan(text: 'Think', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Pay', style: TextStyle(color: _lime)),
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
    final w = size.width;
    final h = size.height;

    final barPaint = Paint()..color = const Color(0xFF777777);
    final topPaint = Paint()..color = const Color(0xFF555555);
    final bottomPaint = Paint()..color = const Color(0xCCBFFF3C);
    final dotPaint = Paint()..color = const Color(0xFFBFFF3C);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, h * 0.1, w * 0.6, h * 0.1), const Radius.circular(2)),
      barPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, h * 0.8, w * 0.6, h * 0.1), const Radius.circular(2)),
      barPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.2, h * 0.2)
        ..lineTo(w * 0.8, h * 0.2)
        ..lineTo(w * 0.5, h * 0.5)
        ..close(),
      topPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.2, h * 0.8)
        ..lineTo(w * 0.8, h * 0.8)
        ..lineTo(w * 0.5, h * 0.5)
        ..close(),
      bottomPaint,
    );
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.06, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x1ABFFF3C),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0x40BFFF3C)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFFBFFF3C),
          letterSpacing: 1.1,
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
        letterSpacing: 0.99,
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
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Color(0x2EFFFFFF), fontSize: 15),
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
            style: const TextStyle(fontSize: 13, color: Color(0x8DFFFFFF)),
          ),
        ],
      ),
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