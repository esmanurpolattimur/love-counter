import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/date_math.dart';
import 'features/onboarding/onboarding_screen.dart';

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
  String? names, first, second; DateTime? date; int tab = 0; Timer? timer;
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
  @override Widget build(BuildContext context) {
    if (date == null) return OnboardingScreen(onSave: save);
    final pages = [Dashboard(names: names!, date: date!, first: first!, second: second!, onSettings: () => setState(() => tab = 3)), const Memories(), SpecialDays(date: date!), Settings(names: names!, date: date!, first: first!, second: second!, onEdit: () => setState(() => date = null))];
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

class Memories extends StatelessWidget { const Memories({super.key}); @override Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Anılar', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), const SizedBox(height: 20), Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.photo_library_outlined, size: 64, color: rose), const SizedBox(height: 12), const Text('Henüz anı eklenmedi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 6), const Text('Birlikte çektiğiniz fotoğrafları burada saklayın.', textAlign: TextAlign.center, style: TextStyle(color: textSecondary)), const SizedBox(height: 20), FilledButton.icon(onPressed: null, icon: Icon(Icons.add), label: Text('Yeni Anı Ekle'))])))])));
}

class SpecialDays extends StatelessWidget { const SpecialDays({super.key, required this.date}); final DateTime date; @override Widget build(BuildContext context) { final list = [('🌹', 'Sevgililer Günü', '14 Şubat'), ('🎄', 'Yılbaşı', '1 Ocak'), ('💐', 'Kadınlar Günü', '8 Mart'), ('💞', 'İlişki Yıldönümümüz', formatted(date))]; final countdowns = [daysUntil(nextDate(2, 14)), daysUntil(nextDate(1, 1)), daysUntil(nextDate(3, 8)), daysUntil(nextDate(date.month, date.day))]; return SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Özel Günlerimiz 🗓️', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), const SizedBox(height: 20), Expanded(child: ListView.separated(itemCount: list.length, separatorBuilder: (_, _) => const SizedBox(height: 12), itemBuilder: (_, i) => card(Row(children: [Text(list[i].$1, style: const TextStyle(fontSize: 29)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(list[i].$2, style: const TextStyle(fontWeight: FontWeight.bold)), Text('${list[i].$3} · ${countdowns[i]} Gün Kaldı'), const SizedBox(height: 8), LinearProgressIndicator(value: .58, color: pink)]))])))), FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yeni özel gün ekleme ekranı açıldı.'))), icon: const Icon(Icons.add), label: const Text('Yeni Özel Gün Ekle'), style: FilledButton.styleFrom(backgroundColor: pink, padding: const EdgeInsets.all(16)))]))); }
}

class Settings extends StatelessWidget { const Settings({super.key, required this.names, required this.date, required this.first, required this.second, required this.onEdit}); final String names, first, second; final DateTime date; final VoidCallback onEdit; @override Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Ayarlar ⚙️', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), const SizedBox(height: 20), tile(Icons.person_outline, 'İsimleri & Tarihi Düzenle', '$names\n${formatted(date)}', onEdit), tile(Icons.pets_outlined, 'Karakterleri Değiştir', '$first & $second', onEdit), tile(Icons.notifications_none, 'Bildirim Ayarları', 'Yıldönümü ve doğum günü hatırlatıcıları'), tile(Icons.image_outlined, 'Arka Planı Kişiselleştir', 'Görsel seç'), tile(Icons.inventory_2_outlined, 'Verileri Yedekle', 'Veriler cihazınızda saklanır'), const Spacer(), FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ayarlar kaydedildi.'))), style: FilledButton.styleFrom(backgroundColor: pink, padding: const EdgeInsets.all(16)), child: const Text('Kaydet ve Kapat'))])));
  Widget tile(IconData icon, String title, String detail, [VoidCallback? onTap]) => Padding(padding: const EdgeInsets.only(bottom: 12), child: card(ListTile(onTap: onTap, leading: Icon(icon), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(detail))));
}

Widget card(Widget child) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 10, offset: Offset(0, 5))]), child: child);
String formatted(DateTime x) => '${x.day.toString().padLeft(2, '0')}.${x.month.toString().padLeft(2, '0')}.${x.year}';
DateTime nextDate(int month, int day) { var value = DateTime(DateTime.now().year, month, day); if (!value.isAfter(DateTime.now())) value = DateTime(DateTime.now().year + 1, month, day); return value; }
int daysUntil(DateTime date) => math.max(0, date.difference(DateTime.now()).inDays + 1);
