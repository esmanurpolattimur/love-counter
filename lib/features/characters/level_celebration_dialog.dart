import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/soft_card.dart';

Future<void> showLevelCelebration(BuildContext context, {required int level, required String name, String? reward}) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (context) => Dialog(
    backgroundColor: AppColors.blush,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Image.asset('assets/images/growth_stage_$level.png', height: 180),
        const SizedBox(height: 8),
        const Text('Tebrikler! 🎉', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.burgundy)),
        const SizedBox(height: 8),
        Text('Karakterleriniz $name evresine büyüdü!', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary)),
        if (reward != null) ...[const SizedBox(height: 16), SoftCard(child: Row(children: [const Text('✨', style: TextStyle(fontSize: 28)), const SizedBox(width: 10), Expanded(child: Text('Yeni erişim: $reward', style: const TextStyle(fontWeight: FontWeight.w800)))]))],
        const SizedBox(height: 20),
        FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Harika! ♡')),
      ]),
    ),
  ),
);
