import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onSave});
  final Future<void> Function(String, DateTime, String, String, DateTime?) onSave;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final names = TextEditingController();
  int step = 0;
  DateTime? relationshipDate;
  DateTime? birthday;
  String character1 = '🧸';
  String character2 = '🐰';
  final characters = const ['🧸', '🐰', '🐱', '🐶'];

  @override
  void dispose() { names.dispose(); super.dispose(); }

  Future<void> pickDate({required bool birthdayDate}) async {
    final chosen = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      initialDate: birthdayDate ? (birthday ?? DateTime(2000)) : (relationshipDate ?? DateTime.now()),
    );
    if (chosen != null) setState(() => birthdayDate ? birthday = chosen : relationshipDate = chosen);
  }

  void next() {
    if (step == 0 && names.text.trim().isEmpty) return _message('İsimleri yazın.');
    if (step == 1 && relationshipDate == null) return _message('İlişki başlangıç tarihini seçin.');
    if (step < 3) setState(() => step++);
    else if (relationshipDate != null) widget.onSave(names.text.trim(), relationshipDate!, character1, character2, birthday);
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [if (step > 0) IconButton(onPressed: () => setState(() => step--), icon: const Icon(Icons.arrow_back)), const Spacer(), Text('${step + 1}/4', style: const TextStyle(color: AppColors.textSecondary))]),
          const SizedBox(height: 16),
          Text('Başlangıç Bilgileri', style: Theme.of(context).textTheme.headlineSmall),
          const Text('Sizi tanıyalım ♡', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 28),
          Expanded(child: _content()),
          FilledButton(onPressed: next, child: Text(step == 3 ? 'Başla ❤️' : 'Devam Et')),
        ])),
      );

  Widget _content() {
    if (step == 0) return Column(children: [TextField(controller: names, decoration: const InputDecoration(labelText: 'İsimleriniz', hintText: 'Merve & Yiğit'))]);
    if (step == 1) return Column(children: [ListTile(onTap: () => pickDate(birthdayDate: false), leading: const Icon(Icons.favorite_outline), title: const Text('İlişki Başlangıç Tarihi'), subtitle: Text(relationshipDate == null ? 'Tarih seçin' : format(relationshipDate!)))]);
    if (step == 2) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Karakterlerinizi seçin'), const SizedBox(height: 15), _picker(character1, (v) => setState(() => character1 = v)), const SizedBox(height: 20), _picker(character2, (v) => setState(() => character2 = v))]);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text('Özet', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 12), Text(names.text), Text('Başlangıç: ${relationshipDate == null ? '-' : format(relationshipDate!)}'), ListTile(onTap: () => pickDate(birthdayDate: true), leading: const Icon(Icons.cake_outlined), title: const Text('Doğum günü'), subtitle: Text(birthday == null ? 'İsteğe bağlı' : format(birthday!)))]);
  }

  Widget _picker(String selected, ValueChanged<String> onChanged) => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: characters.map((x) => InkWell(onTap: () => onChanged(x), child: Container(width: 58, height: 58, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: selected == x ? AppColors.blush : Colors.white, border: Border.all(color: selected == x ? AppColors.rose : Colors.transparent, width: 2)), child: Text(x, style: const TextStyle(fontSize: 30))))).toList());
}

String format(DateTime value) => '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
