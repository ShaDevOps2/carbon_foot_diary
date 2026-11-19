import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Animated circular gauge with a gradient stroke.
class CarbonRing extends StatelessWidget {
  const CarbonRing({
    super.key,
    required this.progress,
    required this.child,
    this.size = 170,
    this.stroke = 16,
    this.trackColor,
    this.colors = const [AppColors.mint, Color(0xFFB8F5D9)],
  });

  final double progress;
  final Widget child;
  final double size;
  final double stroke;
  final Color? trackColor;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0, 1.0)),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) => CustomPaint(
        size: Size.square(size),
        painter: _RingPainter(v, stroke, trackColor ?? Colors.white.withValues(alpha: 0.15), colors),
        child: SizedBox.square(dimension: size, child: Center(child: c)),
      ),
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.stroke, this.track, this.colors);
  final double value;
  final double stroke;
  final Color track;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    canvas.drawArc(r, 0, math.pi * 2, false,
        Paint()
          ..color = track
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke);
    if (value <= 0) return;
    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [...colors, colors.first],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(r, -math.pi / 2, math.pi * 2 * value, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.value != value || o.track != track;
}

/// Smooth area line chart.
class TrendLineChart extends StatelessWidget {
  const TrendLineChart({super.key, required this.values, required this.labels, this.color = AppColors.forest, this.height = 180, this.target});
  final List<double> values;
  final List<String> labels;
  final Color color;
  final double height;
  final double? target;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (_, t, _) => SizedBox(
        height: height,
        child: CustomPaint(
          size: Size.infinite,
          painter: _LinePainter(values, labels, color, scheme.onSurfaceVariant, scheme.outlineVariant, t, target),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.values, this.labels, this.color, this.labelColor, this.grid, this.t, this.target);
  final List<double> values;
  final List<String> labels;
  final Color color;
  final Color labelColor;
  final Color grid;
  final double t;
  final double? target;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const bottom = 26.0;
    const topPadding = 16.0;
    final h = size.height - bottom;
    final maxV = math.max(values.reduce(math.max), target ?? 0) * 1.25;
    final m = maxV == 0 ? 1 : maxV;
    final dx = values.length == 1 ? 0.0 : size.width / (values.length - 1);

    // Subtle horizontal grid lines & axis values
    final gridPaint = Paint()
      ..color = grid.withValues(alpha: 0.35)
      ..strokeWidth = 1.0;
    for (var i = 0; i <= 3; i++) {
      final y = topPadding + (h - topPadding) * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final pts = [
      for (var i = 0; i < values.length; i++)
        Offset(i * dx, topPadding + (h - topPadding) - (values[i] / m) * (h - topPadding) * t),
    ];

    // Smooth natural bezier curve
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final p0 = pts[i - 1], p1 = pts[i];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    // Lush nature-inspired gradient fill
    final area = Path.from(path)
      ..lineTo(pts.last.dx, h)
      ..lineTo(pts.first.dx, h)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF3DDC97).withValues(alpha: 0.45),
            const Color(0xFF1E6B4E).withValues(alpha: 0.18),
            const Color(0xFF1E6B4E).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, topPadding, size.width, h - topPadding)),
    );

    // Subtle glow under the line
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF3DDC97).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );

    // Vibrant forest-green stroke line
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1E6B4E), Color(0xFF3DDC97)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, h))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Budget dashed line
    if (target != null) {
      final y = topPadding + (h - topPadding) - (target! / m) * (h - topPadding);
      final dash = Paint()
        ..color = AppColors.coral.withValues(alpha: 0.8)
        ..strokeWidth = 1.6;
      for (double x = 0; x < size.width; x += 12) {
        canvas.drawLine(Offset(x, y), Offset(math.min(x + 6, size.width), y), dash);
      }
    }

    // Glowing data point dots
    for (var i = 0; i < pts.length; i++) {
      final pt = pts[i];
      final isLast = i == pts.length - 1;
      final dotRadius = isLast ? 5.5 : 3.5;

      // Outer glow
      canvas.drawCircle(
        pt,
        dotRadius + 3,
        Paint()..color = const Color(0xFF3DDC97).withValues(alpha: isLast ? 0.35 : 0.15),
      );
      // Inner solid point
      canvas.drawCircle(
        pt,
        dotRadius,
        Paint()..color = isLast ? const Color(0xFF1E6B4E) : Colors.white,
      );
      // Border ring
      canvas.drawCircle(
        pt,
        dotRadius,
        Paint()
          ..color = const Color(0xFF3DDC97)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    // X-axis day labels
    final step = (labels.length / 7).ceil().clamp(1, 100);
    for (var i = 0; i < labels.length; i += step) {
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(color: labelColor, fontSize: 11, fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = (i * dx - tp.width / 2).clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(x, size.height - tp.height));
    }
  }

  @override
  bool shouldRepaint(_LinePainter o) => o.t != t || o.values != values;
}

class BarDatum {
  const BarDatum(this.label, this.value, this.color, {this.icon});
  final String label;
  final double value;
  final Color color;
  final IconData? icon;
}

/// Vertical rounded bar chart.
class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({super.key, required this.data, this.height = 190, this.highlightIndex});
  final List<BarDatum> data;
  final double height;
  final int? highlightIndex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxV = data.isEmpty ? 1.0 : math.max(data.map((d) => d.value).reduce(math.max), 0.001);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < data.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(data[i].value.toStringAsFixed(data[i].value >= 100 ? 0 : 1),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: data[i].value / maxV),
                      duration: Duration(milliseconds: 700 + i * 70),
                      curve: Curves.easeOutBack,
                      builder: (_, v, _) => Container(
                        height: math.max(6, (height - 48) * v.clamp(0.0, 1.0)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: highlightIndex == null || highlightIndex == i
                                ? [data[i].color, data[i].color.withValues(alpha: 0.55)]
                                : [data[i].color.withValues(alpha: 0.35), data[i].color.withValues(alpha: 0.18)],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    data[i].icon != null
                        ? Icon(data[i].icon, size: 16, color: data[i].color, semanticLabel: data[i].label)
                        : Text(data[i].label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Animated donut chart with a centre label.
class DonutChart extends StatelessWidget {
  const DonutChart({super.key, required this.data, required this.center, this.size = 170});
  final List<BarDatum> data;
  final Widget center;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (_, t, c) => CustomPaint(
        size: Size.square(size),
        painter: _DonutPainter(data, t, Theme.of(context).colorScheme.surfaceContainerLowest),
        child: SizedBox.square(dimension: size, child: Center(child: c)),
      ),
      child: center,
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.data, this.t, this.gap);
  final List<BarDatum> data;
  final double t;
  final Color gap;

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold<double>(0, (s, d) => s + d.value);
    if (total <= 0) return;
    const stroke = 22.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    var start = -math.pi / 2;
    for (final d in data) {
      final sweep = (d.value / total) * math.pi * 2 * t;
      canvas.drawArc(
        rect,
        start + 0.025,
        math.max(0, sweep - 0.05),
        false,
        Paint()
          ..color = d.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter o) => o.t != t || o.data != data;
}

/// Horizontal progress bar with rounded ends and animation.
class SoftProgressBar extends StatelessWidget {
  const SoftProgressBar({super.key, required this.value, required this.color, this.height = 10});
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final track = Theme.of(context).colorScheme.surfaceContainerHigh;
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Container(color: track),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.clamp(0, 1.0)),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => FractionallySizedBox(
                widthFactor: v,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: LinearGradient(colors: [color.withValues(alpha: 0.7), color]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
