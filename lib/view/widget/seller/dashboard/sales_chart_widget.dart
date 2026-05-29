import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/dashboard_models.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class SalesChartWidget extends StatefulWidget {
  final SalesChartModel data;
  final int totalRevenue;

  const SalesChartWidget({
    super.key,
    required this.data,
    required this.totalRevenue,
  });

  @override
  State<SalesChartWidget> createState() => _SalesChartWidgetState();
}

class _SalesChartWidgetState extends State<SalesChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatRevenue(int val) {
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}م';
    if (val >= 1000)    return '${(val / 1000).toStringAsFixed(0)}k';
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColor.cardShadow,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('weekly_sales'.tr, style: AppTextStyle.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    'SP ${_formatRevenue(widget.totalRevenue)}',
                    style: AppTextStyle.heading2.copyWith(
                      color: AppColor.primaryColor,
                      fontFamily: 'PlayfairDisplay',
                    ),
                  ),
                ],
              ),
              // Legend
              Row(
                children: [
                  _LegendDot(color: AppColor.primaryColor, label: 'إيرادات'),
                  const SizedBox(width: 10),
                  _LegendDot(color: AppColor.statOrders, label: 'طلبات'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 130,
            child: AnimatedBuilder(
              animation: _progress,
              builder: (context, _) {
                return GestureDetector(
                  onTapDown: (details) => _onTap(details, context),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _LineChartPainter(
                      revenue:      widget.data.revenue,
                      orders:       widget.data.orders,
                      maxRevenue:   widget.data.maxRevenue,
                      progress:     _progress.value,
                      hoveredIndex: _hoveredIndex,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widget.data.labels.map((l) {
              return SizedBox(
                width: 32,
                child: Text(
                  l,
                  style: AppTextStyle.labelSmall.copyWith(fontSize: 9),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _onTap(TapDownDetails details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = details.localPosition;
    final w = box.size.width;
    final count = widget.data.revenue.length;
    final idx = (local.dx / (w / count)).floor().clamp(0, count - 1);
    setState(() => _hoveredIndex = _hoveredIndex == idx ? null : idx);
  }
}

class _LineChartPainter extends CustomPainter {
  final List<int> revenue;
  final List<int> orders;
  final int maxRevenue;
  final double progress;
  final int? hoveredIndex;

  _LineChartPainter({
    required this.revenue,
    required this.orders,
    required this.maxRevenue,
    required this.progress,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (revenue.isEmpty) return;

    final count   = revenue.length;
    final stepX   = size.width / (count - 1);
    final padTop  = 12.0;
    final padBot  = 8.0;
    final chartH  = size.height - padTop - padBot;

    double getY(int val) =>
        padTop + chartH * (1 - (val / (maxRevenue * 1.15)).clamp(0.0, 1.0));

    final gridPaint = Paint()
      ..color = const Color(0xffF0F0F0)
      ..strokeWidth = 0.8;
    for (int i = 0; i < 4; i++) {
      final y = padTop + (chartH / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final fillPath = Path();
    final pts = <Offset>[];
    for (int i = 0; i < count; i++) {
      final x = i * stepX;
      final y = getY(revenue[i]);
      pts.add(Offset(x, y));
    }
    fillPath.moveTo(pts.first.dx, size.height);
    fillPath.lineTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
      fillPath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i + 1].dx, pts[i + 1].dy);
    }
    fillPath.lineTo(pts.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColor.primaryColor.withOpacity(0.18 * progress),
          AppColor.primaryColor.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppColor.primaryColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    final drawCount = (count * progress).ceil().clamp(1, count);
    linePath.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < drawCount - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
      linePath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i + 1].dx, pts[i + 1].dy);
    }
    canvas.drawPath(linePath, linePaint);

    for (int i = 0; i < drawCount; i++) {
      final isHovered = hoveredIndex == i;
      final dotPaint = Paint()
        ..color = isHovered ? AppColor.primaryColor : Colors.white
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = AppColor.primaryColor
        ..strokeWidth = isHovered ? 2.5 : 2
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(pts[i], isHovered ? 6.5 : 4.5, dotPaint);
      canvas.drawCircle(pts[i], isHovered ? 6.5 : 4.5, borderPaint);

      if (isHovered) {
        _drawTooltip(canvas, pts[i], revenue[i], size);
      }
    }
  }

  void _drawTooltip(Canvas canvas, Offset pt, int value, Size size) {
    const padding = 8.0;
    final text = 'SP ${value ~/ 1000}k';
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'PlayfairDisplay',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final rectW = tp.width + padding * 2;
    final rectH = tp.height + padding;
    double left = pt.dx - rectW / 2;
    left = left.clamp(0, size.width - rectW);
    final top = pt.dy - rectH - 10;

    final rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, rectW, rectH),
      const Radius.circular(8),
    );
    canvas.drawRRect(rRect, Paint()..color = AppColor.primaryDark);
    tp.paint(canvas, Offset(left + padding, top + padding / 2));
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.progress != progress || old.hoveredIndex != hoveredIndex;
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyle.labelSmall.copyWith(fontSize: 10)),
      ],
    );
  }
}
