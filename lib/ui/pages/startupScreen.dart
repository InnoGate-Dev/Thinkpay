import 'dart:ui';

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

// ── Helpers ──────────────────────────────────────────────────────────────────
String _money(double v, {int decimals = 2}) {
  final parts = v.toStringAsFixed(decimals).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
  );
  return decimals == 0 ? '\$$whole' : '\$$whole.${parts[1]}';
}

List<double> _lerpList(List<double> a, List<double> b, double t) => [
  for (var i = 0; i < a.length; i++) lerpDouble(a[i], b[i], t)!,
];

// ── Balance card ─────────────────────────────────────────────────────────────
class _BalanceCard extends StatefulWidget {
  const _BalanceCard({required this.line});
  final Animation<double> line;

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard>
    with TickerProviderStateMixin {
  static const _total = 12480.50;
  static const _goalSaved = 3400.0;
  static const _goalTarget = 5000.0;
  static const _ranges = ['1W', '1M', '3M'];

  // Same number of points per range so they can morph into each other.
  static const _series = <List<double>>[
    [12260, 12240, 12310, 12290, 12350, 12330, 12400, 12390, 12430, 12460, 12480.5],
    [11977, 12060, 12010, 12150, 12110, 12240, 12200, 12330, 12290, 12420, 12480.5],
    [10890, 11120, 11010, 11400, 11330, 11720, 11650, 12010, 11940, 12300, 12480.5],
  ];

  late final AnimationController _morph = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
    value: 1,
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  int _range = 1;
  List<double> _from = _series[1];
  List<double> _to = _series[1];
  int? _scrub; // index of the point being touched
  bool _hidden = false;
  bool _reduceMotion = false;

  List<double> get _shown =>
      _lerpList(_from, _to, Curves.easeOutCubic.transform(_morph.value));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _pulse.stop();
      _pulse.value = 0;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _morph.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _setRange(int i) {
    if (i == _range) return;
    HapticFeedback.selectionClick();
    setState(() {
      _from = _shown; // start from wherever the chart currently is
      _to = _series[i];
      _range = i;
      _scrub = null;
    });
    if (_reduceMotion) {
      _morph.value = 1;
    } else {
      _morph.forward(from: 0);
    }
  }

  void _scrubTo(double dx, double width) {
    if (widget.line.value < 1 || width <= 0) return; // wait for intro
    final n = _to.length;
    final i = (dx / width * (n - 1)).round().clamp(0, n - 1).toInt();
    if (i != _scrub) {
      HapticFeedback.selectionClick();
      setState(() => _scrub = i);
    }
  }

  void _clearScrub() {
    if (_scrub != null) setState(() => _scrub = null);
  }

  void _toggleHidden() {
    HapticFeedback.lightImpact();
    setState(() => _hidden = !_hidden);
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
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
      child: AnimatedBuilder(
        animation: Listenable.merge([line, _morph]),
        builder: (context, _) {
          final vals = _shown;
          final intro = line.value;
          final scrub = _scrub;

          // Real value (for % change) vs. displayed value (count-up on intro).
          final real = scrub != null ? vals[scrub] : _total;
          final shownValue = scrub != null
              ? real
              : lerpDouble(_total * 0.9, _total, intro)!;
          final pct = (real - vals.first) / vals.first * 100;
          final goalT = Curves.easeOutCubic.transform(intro);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: label + privacy toggle + change pill
              Row(
                children: [
                  Text(
                    'Total balance',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _C.inkMuted,
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: _hidden ? 'Show balance' : 'Hide balance',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _toggleHidden,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            _hidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            key: ValueKey(_hidden),
                            size: 16,
                            color: _C.inkMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _DeltaPill(pct: pct),
                ],
              ),

              // Balance (tabular figures so it doesn't jitter while scrubbing)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
                child: Text(
                  _hidden ? '••••••' : _money(shownValue),
                  key: ValueKey(_hidden),
                  style: GoogleFonts.manrope(
                    fontSize: 34,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: _C.ink,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Chart: drag or tap to explore values
              SizedBox(
                height: 64,
                width: double.infinity,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    return Semantics(
                      label: 'Balance trend chart. Drag to explore values.',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (d) => _scrubTo(d.localPosition.dx, w),
                        onTapUp: (_) => _clearScrub(),
                        onTapCancel: _clearScrub,
                        onHorizontalDragStart: (d) =>
                            _scrubTo(d.localPosition.dx, w),
                        onHorizontalDragUpdate: (d) =>
                            _scrubTo(d.localPosition.dx, w),
                        onHorizontalDragEnd: (_) => _clearScrub(),
                        onHorizontalDragCancel: _clearScrub,
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _SparklinePainter(
                            from: _from,
                            to: _to,
                            morph: _morph,
                            intro: line,
                            pulse: _pulse,
                            scrub: scrub,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Range selector with a sliding thumb
              _RangeSelector(
                labels: _ranges,
                index: _range,
                onChanged: _setRange,
              ),

              const SizedBox(height: 12),
              Container(height: 1, color: const Color(0x1A12281D)),
              const SizedBox(height: 12),

              // Goal
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: _C.mintTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined,
                        size: 13, color: _C.growth),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Emergency fund',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _C.ink,
                      ),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: _hidden
                              ? '•••'
                              : _money(_goalSaved * goalT, decimals: 0),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _C.ink,
                          ),
                        ),
                        if (!_hidden)
                          TextSpan(
                            text: ' / ${_money(_goalTarget, decimals: 0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: _C.inkMuted,
                            ),
                          ),
                      ],
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: Stack(
                  children: [
                    Container(height: 8, color: const Color(0xFFE4E0D3)),
                    FractionallySizedBox(
                      widthFactor: (_goalSaved / _goalTarget) * goalT,
                      child: Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2E9A66), _C.growth],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Change pill (turns red if the range is negative) ─────────────────────────
class _DeltaPill extends StatelessWidget {
  const _DeltaPill({required this.pct});
  final double pct;

  @override
  Widget build(BuildContext context) {
    final up = pct >= 0;
    final fg = up ? _C.growth : const Color(0xFFB3412E);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: up ? _C.mintTint : const Color(0xFFF7DDD6),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            '${up ? '+' : '−'}${pct.abs().toStringAsFixed(1)}%',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Segmented range selector ─────────────────────────────────────────────────
class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9DB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment(-1 + 2 * index / (labels.length - 1), 0),
            child: FractionallySizedBox(
              widthFactor: 1 / labels.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == index,
                    label: labels[i],
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(i),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight:
                            i == index ? FontWeight.w700 : FontWeight.w600,
                            color: i == index ? _C.ink : _C.inkMuted,
                          ),
                          child: Text(labels[i]),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sparkline ────────────────────────────────────────────────────────────────
// Draws in on intro, morphs between ranges, shows a pulsing live dot at rest,
// and a guide line + dot while the user scrubs.
class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.from,
    required this.to,
    required this.morph,
    required this.intro,
    required this.pulse,
    required this.scrub,
  }) : super(repaint: Listenable.merge([morph, intro, pulse]));

  final List<double> from;
  final List<double> to;
  final Animation<double> morph;
  final Animation<double> intro;
  final Animation<double> pulse;
  final int? scrub;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = intro.value;
    if (progress <= 0) return;

    final vals = _lerpList(from, to, Curves.easeOutCubic.transform(morph.value));
    var lo = vals.first, hi = vals.first;
    for (final v in vals) {
      if (v < lo) lo = v;
      if (v > hi) hi = v;
    }
    final span = (hi - lo) < 1 ? 1.0 : hi - lo;

    const padTop = 10.0, padBottom = 6.0;
    final n = vals.length;
    final pts = <Offset>[
      for (var i = 0; i < n; i++)
        Offset(
          i / (n - 1) * size.width,
          padTop + (1 - (vals[i] - lo) / span) * (size.height - padTop - padBottom),
        ),
    ];

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < n; i++) {
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

    final s = scrub;
    if (s != null && progress >= 1) {
      // Scrubbing: vertical guide + dot snapped to the data point.
      final p = pts[s];
      canvas.drawLine(
        Offset(p.dx, 0),
        Offset(p.dx, size.height),
        Paint()
          ..color = _C.ink.withValues(alpha: 0.12)
          ..strokeWidth = 1.5,
      );
      _dot(canvas, p, halo: 10);
    } else {
      // At rest: gently pulsing "live" dot at the end of the line.
      if (progress >= 1) {
        final t = pulse.value;
        canvas.drawCircle(
          end,
          9 + t * 7,
          Paint()..color = _C.growth.withValues(alpha: 0.22 * (1 - t)),
        );
      }
      _dot(canvas, end, halo: 9);
    }
  }

  void _dot(Canvas canvas, Offset c, {required double halo}) {
    canvas.drawCircle(c, halo, Paint()..color = _C.growth.withValues(alpha: 0.18));
    canvas.drawCircle(c, 5, Paint()..color = _C.ivory);
    canvas.drawCircle(
      c,
      5,
      Paint()
        ..color = _C.growth
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  // morph / intro / pulse repaint through the `repaint` listenable.
  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.from != from || old.to != to || old.scrub != scrub;
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