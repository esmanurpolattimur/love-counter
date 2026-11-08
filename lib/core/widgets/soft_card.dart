import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(14)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.blush),
          boxShadow: const [BoxShadow(color: Color(0x1A762D39), blurRadius: 12, offset: Offset(0, 5))],
        ),
        child: child,
      );
}
