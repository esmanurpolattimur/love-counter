import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_math.dart';
import '../../core/widgets/soft_card.dart';

class CharacterGrowthScreen extends StatelessWidget {
  const CharacterGrowthScreen({super.key, required this.startDate});
  final DateTime startDate;

  @override
  Widget build(BuildContext context) {
    final days = DateMath.calendarDaysBetween(startDate, DateTime.now());
    final stage = _GrowthStage.forDay(days);
    final stages = _GrowthStage.values;
    return Scaffold(appBar: AppBar(title: const Text('Karakter Büyümesi'), backgroundColor: Colors.transparent), body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
      Center(child: Image.asset('assets/images/growth_stage_${stage.level}.png', height: 230)),
      SoftCard(child: Column(children: [Text('Lv. ${stage.level} – ${stage.name}', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), Text('$days. gün', style: const TextStyle(color: AppColors.textSecondary)), const SizedBox(height: 12), LinearProgressIndicator(value: stage.progress(days), minHeight: 8, borderRadius: BorderRadius.circular(9), color: AppColors.rose, backgroundColor: AppColors.peach)])),
      const SizedBox(height: 18), const Text('Gelişim Evreleri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 10),
      ...stages.map((item) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SoftCard(child: ListTile(leading: Icon(item.level <= stage.level ? Icons.lock_open_rounded : Icons.lock_outline_rounded, color: item.level <= stage.level ? AppColors.rose : AppColors.textSecondary), title: Text('Lv. ${item.level} – ${item.name}', style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(item.range), trailing: item.level == stage.level ? const Text('Aktif', style: TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold)) : null)))),
      const SizedBox(height: 8), const Text('Ödül Kilometre Taşları', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 10),
      SoftCard(child: Column(children: [_reward(days, 500, '🕶️', '500. gün gözlüğü'), const Divider(), _reward(days, 1000, '👑', '1000. gün tacı')])),
    ])));
  }
  Widget _reward(int days, int target, String icon, String title) => ListTile(leading: Text(icon, style: const TextStyle(fontSize: 28)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(days >= target ? 'Açıldı' : '${target - days} gün kaldı'), trailing: Icon(days >= target ? Icons.check_circle : Icons.lock_outline, color: days >= target ? AppColors.rose : AppColors.textSecondary));
}

class _GrowthStage { const _GrowthStage(this.level, this.name, this.minimum, this.maximum); final int level, minimum; final int? maximum; final String name; String get range => maximum == null ? '$minimum+ gün' : '$minimum–$maximum gün'; double progress(int days) => maximum == null ? 1 : ((days - minimum + 1) / (maximum! - minimum + 1)).clamp(0.0, 1.0).toDouble(); static const values = [_GrowthStage(1, 'Yenidoğan', 0, 30), _GrowthStage(2, 'Çocukluk', 31, 180), _GrowthStage(3, 'Gençlik', 181, 365), _GrowthStage(4, 'Yetişkin', 366, null)]; static _GrowthStage forDay(int day) => values.lastWhere((item) => day >= item.minimum); }
