import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  bool _emailFocused = false;
  bool _submitted = false;

  // Brand colours
  static const Color _bg = Color(0xFF0E0E0E);
  static const Color _lime = Color(0xFFBFFF3C);

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(
          () => setState(() => _emailFocused = _emailFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_emailController.text.trim().isEmpty) return;
    setState(() => _submitted = true);
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

              // ── Back button ───────────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0x0DFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x12FFFFFF)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Icon illustration ─────────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0x1ABFFF3C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x33BFFF3C)),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: _lime,
                  size: 30,
                ),
              ),

              const SizedBox(height: 20),

              // ── Tag ───────────────────────────────────────────────
              _TagPill(label: 'Password reset'),

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
                    TextSpan(text: 'Forgot your\n'),
                    TextSpan(
                      text: 'password?',
                      style: TextStyle(
                        color: _lime,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "No worries — enter your email and we'll send you a reset link.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0x62FFFFFF),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 36),

              // ── Success state ─────────────────────────────────────
              if (_submitted) ...[
                _SuccessBanner(email: _emailController.text.trim()),
                const SizedBox(height: 28),
              ],

              // ── Email field ───────────────────────────────────────
              if (!_submitted) ...[
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

                const SizedBox(height: 28),

                // ── Submit button ─────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
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
                          'Send reset link',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: _bg,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: _bg,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),
              ],

              // ── Divider ───────────────────────────────────────────
              const Row(
                children: [
                  Expanded(child: Divider(color: Color(0x12FFFFFF), thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'or',
                      style: TextStyle(fontSize: 12, color: Color(0x38FFFFFF)),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0x12FFFFFF), thickness: 1)),
                ],
              ),

              const SizedBox(height: 28),

              // ── Back to login ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0x20FFFFFF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: Color(0x8DFFFFFF),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Back to sign in',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0x8DFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Sign up nudge ─────────────────────────────────────
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                  child: Text.rich(
                    const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0x47FFFFFF),
                      ),
                      children: [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Create one',
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

// ── Success banner ────────────────────────────────────────────────────────────

class _SuccessBanner extends StatelessWidget {
  final String email;
  const _SuccessBanner({required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x1ABFFF3C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x40BFFF3C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x33BFFF3C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFFBFFF3C),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Check your inbox',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFBFFF3C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'We sent a reset link to $email. It expires in 15 minutes.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xA0BFFF3C),
              height: 1.5,
            ),
          ),
        ],
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
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.1, w * 0.6, h * 0.1),
        const Radius.circular(2),
      ),
      barPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.8, w * 0.6, h * 0.1),
        const Radius.circular(2),
      ),
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
          if (suffix != null) ...[suffix!, const SizedBox(width: 16)],
        ],
      ),
    );
  }
}