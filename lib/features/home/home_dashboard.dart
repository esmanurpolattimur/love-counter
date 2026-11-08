import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_math.dart';
import '../../core/widgets/soft_card.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key, required this.names, required this.startDate, required this.onSettings, required this.onGrowth});
  final String names;
  final DateTime startDate;
  final VoidCallback onSettings;
  final VoidCallback onGrowth;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totalDays = DateMath.calendarDaysBetween(startDate, now);
    final period = DateMath.calendarPeriod(startDate, now);
    final anniversary = DateMath.nextYearlyOccurrence(startDate, now);
    final anniversaryDays = DateMath.daysUntil(anniversary, now: now);
    final stage = _Stage.forDay(totalDays);
    final stageProgress = stage.maximum == null ? 1.0 : ((totalDays - stage.minimum + 1) / (stage.maximum! - stage.minimum + 1)).clamp(0.0, 1.0).toDouble();
    final remaining = stage.maximum == null ? null : stage.maximum! - totalDays + 1;
    final elapsed = now.difference(startDate);

    return SafeArea(child: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.blush, AppColors.background])),
      child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), child: Column(children: [
        Row(children: [Expanded(child: Text(names, style: Theme.of(context).textTheme.titleLarge)), IconButton(onPressed: onSettings, icon: const Icon(Icons.settings_outlined, color: AppColors.burgundy))]),
        const SizedBox(height: 8),
        Image.asset('assets/images/growth_stage_${stage.level}.png', height: 190, fit: BoxFit.contain),
        const SizedBox(height: 8),
        InkWell(onTap: onGrowth, borderRadius: BorderRadius.circular(18), child: SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('🌱 Büyüme Seviyesi: Lv. ${stage.level} · ${stage.name}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.burgundy)),
          const SizedBox(height: 9),
          LinearProgressIndicator(value: stageProgress, minHeight: 8, borderRadius: BorderRadius.circular(9), color: AppColors.rose, backgroundColor: AppColors.peach),
          const SizedBox(height: 7),
          Text(remaining == null ? 'Yıldönümü evresindesiniz.' : 'Sonraki evreye: $remaining gün kaldı', style: const TextStyle(color: AppColors.textSecondary)),
        ]))),
        const SizedBox(height: 20),
        const Text('BİRLİKTE GEÇEN SÜRE', style: TextStyle(letterSpacing: 1.3, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        Text('$totalDays Gün', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 14),
        SoftCard(child: Column(children: [
          Text('${period.years} YIL, ${period.months} AY, ${period.days} GÜN', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_unit(elapsed.inHours % 24, 'SAAT'), _unit(elapsed.inMinutes % 60, 'DAKİKA'), _unit(elapsed.inSeconds % 60, 'SANİYE')]),
        ])),
        const SizedBox(height: 14),
        Row(children: [Expanded(child: _countdown('🎂', 'Doğum günü', 'Bilgi eklenmedi')), const SizedBox(width: 12), Expanded(child: _countdown('💞', 'Yıldönümü', '$anniversaryDays gün'))]),
      ])),
    ));
  }

  Widget _unit(int value, String label) => Column(children: [Text('$value'.padLeft(2, '0'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)), Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary))]);
  Widget _countdown(String icon, String label, String detail) => SoftCard(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(icon), Text(label, style: const TextStyle(fontWeight: FontWeight.w800)), Text(detail, style: const TextStyle(color: AppColors.textSecondary))]));
}

class _Stage { const _Stage(this.level, this.name, this.minimum, this.maximum); final int level, minimum; final int? maximum; final String name;
  static const values = [_Stage(1, 'Yenidoğan', 0, 30), _Stage(2, 'Çocukluk', 31, 180), _Stage(3, 'Gençlik', 181, 365), _Stage(4, 'Yetişkin', 366, null)];
  static _Stage forDay(int day) => values.lastWhere((stage) => day >= stage.minimum);
}
