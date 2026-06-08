import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

class StatsCard extends StatefulWidget {
  final String label;
  final String value;
  final double change;
  final String period;
  final IconData icon;
  final Color accentColor;
  final Color accentLight;
  final int animationDelay;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.change,
    required this.period,
    required this.icon,
    required this.accentColor,
    required this.accentLight,
    this.animationDelay = 0,
  });

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;
  late Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0,3),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _scaleAnim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isPositive => widget.change >= 0;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: _buildCard(),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColor.cardShadow,
        border: Border.all(
          color: widget.accentColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.accentLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: widget.accentColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _isPositive
                      ? AppColor.successLight
                      : AppColor.errorLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 12,
                      color: _isPositive
                          ? AppColor.successDark
                          : AppColor.errorDark,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${_isPositive ? '+' : ''}${widget.change.abs().toStringAsFixed(1)}%',
                      style: AppTextStyle.statChange.copyWith(
                        color: _isPositive
                            ? AppColor.successDark
                            : AppColor.errorDark,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            widget.label,
            style: AppTextStyle.statLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              widget.value,
              style: AppTextStyle.statNumber.copyWith(
                color: widget.accentColor,
              ),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            widget.period,
            style: AppTextStyle.labelSmall.copyWith(
              fontSize: 11,
              color: AppColor.greyLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
