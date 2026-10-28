import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// DayOne – redesigned startup screen.
///
/// Design notes
/// • One memorable moment: an ivory balance card rises onto a deep forest
///   canvas, its growth line draws itself, then two small proof chips pop in.
///   Everything else is static, so the eye lands on the product first.
/// • Palette is self-contained (see [_C]) so it can be dropped into the app
///   without touching ThemeColors. Move values into ThemeColors if you adopt it.
/// • One primary action, one clearly secondary action, one trust line.
class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

// ── Palette ──────────────────────────────────────────────────────────────────
class _C {
  _C._();
  static const forestTop = Color(0xFF17513A);
  static const forestBottom = Color(0xFF0B2218);
  static const forestRaised = Color(0xFF1F5C43); // chips on the canvas
  static const ivory = Color(0xFFF6F2E7); // card + primary text
  static const ivoryMuted = Color(0xFFB9CBBF); // secondary text on forest
  static const ink = Color(0xFF12281D); // text on ivory
  static const inkMuted = Color(0xFF5E7266);
  static const growth = Color(0xFF1E7A4E); // line + positive
  static const mintTint = Color(0xFFD7EDDD);
  static const marigold = Color(0xFFF2B84B); // action colour
  static const line = Color(0x33F6F2E7);
}

class _StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final Animation<double> _card;
  late final Animation<double> _line;
  late final Animation<double> _chipA;
  late final Animation<double> _chipB;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _card = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.40, curve: Curves.easeOutCubic),
    );
    _line = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.25, 0.80, curve: Curves.easeInOutCubic),
    );
    _chipA = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.60, 0.88, curve: Curves.easeOutBack),
    );
    _chipB = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.72, 1.0, curve: Curves.easeOutBack),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Respect the system "reduce motion" setting.
    if (MediaQuery.disableAnimationsOf(context)) {
      _intro.value = 1;
    } else {
      _intro.forward();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _go(String route) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _C.forestBottom,
      ),
      child: Scaffold(
        backgroundColor: _C.forestBottom,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_C.forestTop, _C.forestBottom],
              stops: [0.0, 0.75],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Logo(),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _Hero(
                          card: _card,
                          line: _line,
                          chipA: _chipA,
                          chipB: _chipB,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Money that grows\nwhen you do.',
                    style: GoogleFonts.manrope(
                      fontSize: 36,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                      color: _C.ivory,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Track spending, reach your goals, and get AI insights that help you improve a little every day.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.5,
                      color: _C.ivoryMuted,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _PrimaryButton(
                    label: 'Create your account',
                    onPressed: () => _go('/signup'),
                  ),
                  const SizedBox(height: 12),
                  _SecondaryButton(
                    label: 'I already have an account',
                    onPressed: () => _go('/login'),
                  ),
                  const SizedBox(height: 16),
                  const _TrustLine(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logo ─────────────────────────────────────────────────────────────────────
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'DayOne',
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _C.marigold,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '1',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _C.ink,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'DayOne',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: _C.ivory,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero: balance card + two proof chips ──────────────────────────────────────
class _Hero extends StatelessWidget {
  const _Hero({
    required this.card,
    required this.line,
    required this.chipA,
    required this.chipB,
  });

  final Animation<double> card;
  final Animation<double> line;
  final Animation<double> chipA;
  final Animation<double> chipB;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 328,
        height: 304,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 16,
              top: 40,
              child: FadeTransition(
                opacity: card,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.12),
                    end: Offset.zero,
                  ).animate(card),
                  child: _BalanceCard(line: line),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: ScaleTransition(
                scale: chipA,
                alignment: Alignment.bottomLeft,
                child: const _InsightChip(),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 0,
              child: ScaleTransition(
                scale: chipB,
                alignment: Alignment.topLeft,
                child: const _StreakChip(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.line});
  final Animation<double> line;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: _C.ivory,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total balance',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _C.inkMuted,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.mintTint,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up_rounded,
                        size: 14, color: _C.growth),
                    const SizedBox(width: 4),
                    Text(
                      '4.2% this month',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _C.growth,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '\$12,480.50',
            style: GoogleFonts.manrope(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: _C.ink,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 64,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: line,
              builder: (_, __) => CustomPaint(
                painter: _SparklinePainter(progress: line.value),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Emergency fund',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _C.ink,
                ),
              ),
              Text(
                '68%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _C.inkMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Stack(
              children: [
                Container(height: 6, color: const Color(0xFFE4E0D3)),
                AnimatedBuilder(
                  animation: line,
                  builder: (_, __) => FractionallySizedBox(
                    widthFactor: 0.68 * line.value,
                    child: Container(height: 6, color: _C.growth),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
      decoration: BoxDecoration(
        color: _C.forestRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: _C.marigold,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                size: 15, color: _C.ink),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AI insight',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  color: _C.ivoryMuted,
                ),
              ),
              Text(
                'Save \$120 on dining',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _C.ivory,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _C.marigold,
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_rounded,
              size: 18, color: _C.ink),
          const SizedBox(width: 6),
          Text(
            '12-day streak',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _C.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sparkline ────────────────────────────────────────────────────────────────
class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.progress});
  final double progress;

  static const _data = [
    0.30, 0.38, 0.34, 0.48, 0.44, 0.56, 0.52, 0.68, 0.63, 0.80, 0.92,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final pts = <Offset>[
      for (var i = 0; i < _data.length; i++)
        Offset(
          i / (_data.length - 1) * size.width,
          size.height - _data[i] * size.height,
        ),
    ];

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final a = pts[i - 1];
      final b = pts[i];
      final cx = (a.dx + b.dx) / 2;
      path.cubicTo(cx, a.dy, cx, b.dy, b.dx, b.dy);
    }

    final metric = path.computeMetrics().first;
    final len = metric.length * progress;
    final shown = metric.extractPath(0, len);
    final end = metric.getTangentForOffset(len)?.position ?? pts.first;

    // Soft fill under the line.
    final fill = Path.from(shown)
      ..lineTo(end.dx, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _C.growth.withValues(alpha: 0.22),
            _C.growth.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & size),
    );

    // The line.
    canvas.drawPath(
      shown,
      Paint()
        ..color = _C.growth
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Leading dot.
    canvas.drawCircle(
      end,
      9,
      Paint()..color = _C.growth.withValues(alpha: 0.18),
    );
    canvas.drawCircle(end, 5, Paint()..color = _C.ivory);
    canvas.drawCircle(
      end,
      5,
      Paint()
        ..color = _C.growth
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.progress != progress;
}

// ── Buttons ──────────────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.marigold,
          foregroundColor: _C.ink,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _C.ivory,
          side: const BorderSide(color: _C.line, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Trust line ───────────────────────────────────────────────────────────────
class _TrustLine extends StatelessWidget {
  const _TrustLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline_rounded,
            size: 14, color: _C.ivoryMuted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'We only get what you add.',
            style: GoogleFonts.inter(fontSize: 12, color: _C.ivoryMuted),
          ),
        ),
      ],
    );
  }
}