import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/date_math.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_dashboard.dart';
import 'features/characters/character_growth_screen.dart';
import 'features/characters/level_celebration_dialog.dart';
import 'features/reminders/reminder_settings_screen.dart';
import 'features/settings/settings_tools_screen.dart';
import 'features/memories/photo_memories_screen.dart';

// Central design tokens from the product specification.
const background = Color(0xfffff8f5);
const blush = Color(0xfffbe5de);
const peach = Color(0xfff5cfc3);
const rose = Color(0xffb85d68);
const burgundy = Color(0xff762d39);
const textPrimary = Color(0xff35252b);
const textSecondary = Color(0xff806a70);
const surface = Color(0xfffffcfa);
const pink = rose;
const palePink = blush;
const cream = background;

class GrowthStage {
  const GrowthStage(this.level, this.name, this.minimumDay, this.maximumDay, this.description);
  final int level, minimumDay, maximumDay;
  final String name, description;
  static const stages = [
    GrowthStage(1, 'Yenidoğan', 0, 30, 'Minik başlangıçlar'),
    GrowthStage(2, 'Çocukluk', 31, 180, 'Oyun ve keşif zamanı'),
    GrowthStage(3, 'Gençlik', 181, 365, 'Uyum içinde büyüyorsunuz'),
    GrowthStage(4, 'Yetişkin', 366, 999999, 'Yıldönümü ruhu'),
  ];
  static GrowthStage forDays(int days) => stages.lastWhere((stage) => days >= stage.minimumDay);
  static String charactersFor(int days, String first, String second) {
    if (days <= 30) return '$first🍼  $second🍼';
    if (days <= 180) return '$first🎈  $second🍦';
    if (days <= 365) return '$first🧣  $second🎩';
    final extra = days >= 1000 ? '👑' : days >= 500 ? '🕶️' : '💐';
    return '$first$extra  $second❤️';
  }
}

void main() => runApp(const LoveApp());

class LoveApp extends StatelessWidget {
  const LoveApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    home: const Home(),
  );
}

class Home extends StatefulWidget { const Home({super.key}); @override State<Home> createState() => _HomeState(); }
class _HomeState extends State<Home> {
  String? names, first, second; DateTime? date; int tab = 0; Timer? timer; bool celebrationChecked = false;
  @override void initState() { super.initState(); load(); }
  @override void dispose() { timer?.cancel(); super.dispose(); }
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final saved = DateTime.tryParse(p.getString('date') ?? '');
    if (saved != null) { names = p.getString('names'); date = saved; first = p.getString('first') ?? '🧸'; second = p.getString('second') ?? '🐰'; timer = Timer.periodic(const Duration(seconds: 1), (_) => mounted ? setState(() {}) : null); }
    if (mounted) setState(() {});
  }
  Future<void> save(String n, DateTime d, String a, String b) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('names', n); await p.setString('date', d.toIso8601String()); await p.setString('first', a); await p.setString('second', b);
    setState(() { names = n; date = d; first = a; second = b; tab = 0; });
    timer ??= Timer.periodic(const Duration(seconds: 1), (_) => mounted ? setState(() {}) : null);
  }
  Future<void> checkCelebration() async { if (date == null) return; final prefs = await SharedPreferences.getInstance(); final current = GrowthStage.forDays(DateMath.calendarDaysBetween(date!, DateTime.now())); final seen = prefs.getInt('seen_growth_stage'); if (seen == null) { await prefs.setInt('seen_growth_stage', current.level); return; } if (current.level > seen && mounted) { await prefs.setInt('seen_growth_stage', current.level); await showLevelCelebration(context, level: current.level, name: current.name, reward: current.level == 4 ? 'Yıldönümü kalbi' : null); } }
  @override Widget build(BuildContext context) {
    if (date == null) return OnboardingScreen(onSave: save);
    if (!celebrationChecked) { celebrationChecked = true; WidgetsBinding.instance.addPostFrameCallback((_) => checkCelebration()); }
    final pages = [HomeDashboard(names: names!, startDate: date!, onSettings: () => setState(() => tab = 3), onGrowth: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CharacterGrowthScreen(startDate: date!)))), const PhotoMemoriesScreen(), SpecialDays(date: date!), Settings(names: names!, date: date!, first: first!, second: second!, onEdit: () => setState(() => date = null), onReminders: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReminderSettingsScreen())), onTools: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsToolsScreen())))];
    return Scaffold(body: pages[tab], bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Ana Sayfa'), NavigationDestination(icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library), label: 'Anılar'), NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Özel Günler'), NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Ayarlar')]));
  }
}

class Setup extends StatefulWidget { const Setup({super.key, required this.onSave}); final Future<void> Function(String, DateTime, String, String) onSave; @override State<Setup> createState() => _SetupState(); }
class _SetupState extends State<Setup> {
  final form = GlobalKey<FormState>(), input = TextEditingController(); DateTime? date; String a = '🧸', b = '🐰'; final animals = const ['🧸', '🐰', '🐱', '🐶'];
  @override void dispose() { input.dispose(); super.dispose(); }
  Future<void> pick() async { final x = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime.now()); if (x != null) setState(() => date = x); }
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(25), child: Form(key: form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Aramıza Hoş Geldiniz!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26)), const Text('❤️', textAlign: TextAlign.center, style: TextStyle(fontSize: 25)), const SizedBox(height: 30), const Text('İsimleriniz', style: TextStyle(fontWeight: FontWeight.bold)), TextFormField(controller: input, decoration: const InputDecoration(hintText: 'Merve & Yiğit'), validator: (x) => x == null || x.trim().isEmpty ? 'İsimleri yazın.' : null), const SizedBox(height: 16), const Text('İlişki Başlangıç Tarihi', style: TextStyle(fontWeight: FontWeight.bold)), OutlinedButton.icon(onPressed: pick, icon: const Icon(Icons.calendar_month), label: Text(date == null ? 'Takvim seçici' : formatted(date!))), const SizedBox(height: 25), const Text('Karakterlerinizi Seçin', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), const SizedBox(height: 12), chooser(a, (x) => setState(() => a = x)), const SizedBox(height: 12), chooser(b, (x) => setState(() => b = x)), const SizedBox(height: 30), FilledButton(onPressed: () { if (form.currentState!.validate() && date != null) widget.onSave(input.text.trim(), date!, a, b); }, style: FilledButton.styleFrom(backgroundColor: pink, padding: const EdgeInsets.all(16)), child: const Text('Başlat ❤️'))])))));
  Widget chooser(String selected, ValueChanged<String> change) => Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: animals.map((x) => InkWell(onTap: () => change(x), child: Container(width: 58, height: 58, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: x == selected ? palePink : Colors.white, border: Border.all(color: x == selected ? pink : Colors.transparent, width: 2)), child: Text(x, style: const TextStyle(fontSize: 31)))).toList());
}

class Dashboard extends StatelessWidget { const Dashboard({super.key, required this.names, required this.date, required this.first, required this.second, required this.onSettings}); final String names, first, second; final DateTime date; final VoidCallback onSettings;
  @override Widget build(BuildContext context) { final d = DateTime.now().difference(date); final stage = GrowthStage.forDays(d.inDays); final span = stage.maximumDay - stage.minimumDay + 1; final progress = stage.level == 4 ? 1.0 : ((d.inDays - stage.minimumDay + 1) / span).clamp(0.0, 1.0).toDouble(); final remaining = stage.maximumDay - d.inDays + 1; final figure = Image.asset('assets/images/growth_stage_${stage.level}.png', height: 175, fit: BoxFit.contain); return SafeArea(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [palePink, cream])), child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [Row(children: [Expanded(child: Text(names, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900))), IconButton(onPressed: onSettings, icon: const Icon(Icons.settings_outlined))]), const Spacer(), figure, const SizedBox(height: 8), card(Column(children: [Text('🌱 Büyüme Seviyesi: Lv. ${stage.level} · ${stage.name}', style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), LinearProgressIndicator(value: progress, color: pink, minHeight: 8, borderRadius: BorderRadius.circular(10), backgroundColor: palePink), const SizedBox(height: 7), Text(stage.level == 4 ? 'Yıldönümü evresindesiniz! ${stage.description}' : 'Sonraki evreye: $remaining Gün Kaldı', style: const TextStyle(fontSize: 12))])), const SizedBox(height: 18), Text('${d.inDays} GÜN', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 40)), const Text('Birlikte Geçen Zaman'), const SizedBox(height: 18), card(Column(children: [Text('${d.inDays ~/ 365} YIL, ${(d.inDays % 365) ~/ 30} AY, ${(d.inDays % 365) % 30} GÜN', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), const SizedBox(height: 12), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [cell(d.inHours % 24, 'SAAT'), cell(d.inMinutes % 60, 'DAKİKA'), cell(d.inSeconds % 60, 'SANİYE')])])), const SizedBox(height: 18), card(const Column(children: [Text('🎂  Doğum Gününe: Bilgi eklenmedi'), SizedBox(height: 6), Text('💞  Yıldönümüne: Yakında')])) , const Spacer()] )))); }
  Widget cell(int v, String t) => Column(children: [Text('$v'.padLeft(2, '0'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(t, style: const TextStyle(fontSize: 10))]);
}

class Memories extends StatefulWidget { const Memories({super.key}); @override State<Memories> createState() => _MemoriesState(); }
class _MemoriesState extends State<Memories> {
  final memories = <(String, DateTime)>[];
  Future<void> addMemory() async { final title = TextEditingController(); DateTime date = DateTime.now(); await showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Yeni Anı'), content: StatefulBuilder(builder: (context, update) => Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, decoration: const InputDecoration(labelText: 'Anı başlığı')), ListTile(leading: const Icon(Icons.calendar_today), title: Text(format(date)), onTap: () async { final selected = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(1950), lastDate: DateTime.now()); if (selected != null) update(() => date = selected); })])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')), FilledButton(onPressed: () { if (title.text.trim().isNotEmpty) { setState(() => memories.add((title.text.trim(), date))); Navigator.pop(context); } }, child: const Text('Kaydet'))])); title.dispose(); }
  @override Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Row(children: [const Expanded(child: Text('Anılar', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900))), IconButton(onPressed: addMemory, icon: const Icon(Icons.add_circle, color: rose, size: 30))]), const SizedBox(height: 12), Expanded(child: memories.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.photo_library_outlined, size: 64, color: rose), const SizedBox(height: 12), const Text('Henüz anı eklenmedi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 18), FilledButton.icon(onPressed: addMemory, icon: const Icon(Icons.add), label: const Text('Yeni Anı Ekle'))])) : ListView.separated(itemCount: memories.length, separatorBuilder: (_, _) => const SizedBox(height: 12), itemBuilder: (_, index) { final item = memories[memories.length - index - 1]; return card(ListTile(leading: const CircleAvatar(backgroundColor: blush, child: Icon(Icons.favorite, color: rose)), title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(format(item.$2)), trailing: IconButton(onPressed: () => setState(() => memories.remove(item)), icon: const Icon(Icons.delete_outline)))); })), ])));
}

class SpecialDays extends StatefulWidget { const SpecialDays({super.key, required this.date}); final DateTime date; @override State<SpecialDays> createState() => _SpecialDaysState(); }
class _SpecialDaysState extends State<SpecialDays> { final customDays = <(String, DateTime)>[]; Future<void> addDay() async { final title = TextEditingController(); DateTime day = DateTime.now(); await showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Özel Gün Ekle'), content: StatefulBuilder(builder: (context, update) => Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, decoration: const InputDecoration(labelText: 'Gün adı')), ListTile(title: Text(format(day)), leading: const Icon(Icons.calendar_month), onTap: () async { final selected = await showDatePicker(context: context, initialDate: day, firstDate: DateTime(1950), lastDate: DateTime(2100)); if (selected != null) update(() => day = selected); })])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')), FilledButton(onPressed: () { if (title.text.trim().isNotEmpty) { setState(() => customDays.add((title.text.trim(), day))); Navigator.pop(context); } }, child: const Text('Ekle'))])); title.dispose(); }
  @override Widget build(BuildContext context) { final list = [('🌹', 'Sevgililer Günü', nextDate(2, 14)), ('🎄', 'Yılbaşı', nextDate(1, 1)), ('💐', 'Kadınlar Günü', nextDate(3, 8)), ('💞', 'İlişki Yıldönümümüz', nextDate(widget.date.month, widget.date.day)), ...customDays.map((x) => ('✨', x.$1, x.$2))]; return SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Özel Günlerimiz 🗓️', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), const SizedBox(height: 20), Expanded(child: ListView.separated(itemCount: list.length, separatorBuilder: (_, _) => const SizedBox(height: 12), itemBuilder: (_, i) { final item = list[i]; final left = daysUntil(item.$3); return card(Row(children: [Text(item.$1, style: const TextStyle(fontSize: 29)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.$2, style: const TextStyle(fontWeight: FontWeight.bold)), Text('${format(item.$3)} · $left Gün Kaldı'), const SizedBox(height: 8), LinearProgressIndicator(value: (1 - left / 365).clamp(.06, 1.0), color: pink)]))])); })), FilledButton.icon(onPressed: addDay, icon: const Icon(Icons.add), label: const Text('Yeni Özel Gün Ekle'), style: FilledButton.styleFrom(backgroundColor: pink, padding: const EdgeInsets.all(16)))]))); }
}

class Settings extends StatelessWidget { const Settings({super.key, required this.names, required this.date, required this.first, required this.second, required this.onEdit, required this.onReminders, required this.onTools}); final String names, first, second; final DateTime date; final VoidCallback onEdit, onReminders, onTools; @override Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Ayarlar ⚙️', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), const SizedBox(height: 20), tile(Icons.person_outline, 'İsimleri & Tarihi Düzenle', '$names\n${formatted(date)}', onEdit), tile(Icons.pets_outlined, 'Karakterleri Değiştir', '$first & $second', onEdit), tile(Icons.notifications_none, 'Bildirim Ayarları', 'Yıldönümü ve doğum günü hatırlatıcıları', onReminders), tile(Icons.image_outlined, 'Arka Planı Kişiselleştir', 'Tema seç ve yedek oluştur', onTools), tile(Icons.inventory_2_outlined, 'Verileri Yedekle', 'JSON yedeğini panoya kopyala', onTools), const Spacer(), FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ayarlar kaydedildi.'))), style: FilledButton.styleFrom(backgroundColor: pink, padding: const EdgeInsets.all(16)), child: const Text('Kaydet ve Kapat'))])));
  Widget tile(IconData icon, String title, String detail, [VoidCallback? onTap]) => Padding(padding: const EdgeInsets.only(bottom: 12), child: card(ListTile(onTap: onTap, leading: Icon(icon), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(detail))));
}

Widget card(Widget child) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 10, offset: Offset(0, 5))]), child: child);
String formatted(DateTime x) => '${x.day.toString().padLeft(2, '0')}.${x.month.toString().padLeft(2, '0')}.${x.year}';
DateTime nextDate(int month, int day) { var value = DateTime(DateTime.now().year, month, day); if (!value.isAfter(DateTime.now())) value = DateTime(DateTime.now().year + 1, month, day); return value; }
int daysUntil(DateTime date) => math.max(0, date.difference(DateTime.now()).inDays + 1);
