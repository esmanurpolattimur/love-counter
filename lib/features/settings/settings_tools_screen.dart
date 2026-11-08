import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsToolsScreen extends StatefulWidget { const SettingsToolsScreen({super.key}); @override State<SettingsToolsScreen> createState() => _SettingsToolsScreenState(); }
class _SettingsToolsScreenState extends State<SettingsToolsScreen> {
  String theme = 'Pastel';
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { final p = await SharedPreferences.getInstance(); if (mounted) setState(() => theme = p.getString('background_theme') ?? 'Pastel'); }
  Future<void> changeTheme(String value) async { final p = await SharedPreferences.getInstance(); await p.setString('background_theme', value); if (mounted) setState(() => theme = value); }
  Future<void> backup() async { final p = await SharedPreferences.getInstance(); final data = {'names': p.getString('names'), 'relationshipStartDate': p.getString('date'), 'character1': p.getString('first'), 'character2': p.getString('second'), 'backgroundTheme': theme}; await Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(data))); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yedek JSON panoya kopyalandı.'))); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Kişiselleştirme')), body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Arka Plan Teması', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)), const SizedBox(height: 12), SegmentedButton<String>(segments: const [ButtonSegment(value: 'Pastel', label: Text('Pastel')), ButtonSegment(value: 'Kalpli', label: Text('Kalpli')), ButtonSegment(value: 'Gece', label: Text('Gece'))], selected: {theme}, onSelectionChanged: (v) => changeTheme(v.first)), const SizedBox(height: 24), const Text('Veri Yedekleme', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)), const SizedBox(height: 8), const Text('Profil bilgilerin JSON biçiminde panoya kopyalanır. Fotoğraflar bu yedeğe dahil değildir.'), const SizedBox(height: 14), FilledButton.icon(onPressed: backup, icon: const Icon(Icons.copy), label: const Text('Yedeği Panoya Kopyala'))])));
}
