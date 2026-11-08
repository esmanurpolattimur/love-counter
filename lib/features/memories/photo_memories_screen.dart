import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/services/photo_storage_service.dart';
import '../../data/models/memory_entry.dart';
import '../../data/repositories/memory_repository.dart';

class PhotoMemoriesScreen extends StatefulWidget { const PhotoMemoriesScreen({super.key}); @override State<PhotoMemoriesScreen> createState() => _PhotoMemoriesScreenState(); }
class _PhotoMemoriesScreenState extends State<PhotoMemoriesScreen> {
  final repo = MemoryRepository(), photos = PhotoStorageService(); List<MemoryEntry> items = []; bool loading = true;
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { items = await repo.load(); if (mounted) setState(() => loading = false); }
  Future<void> add() async {
    final title = TextEditingController();
    final selected = await photos.pickAndStoreImages();
    if (!mounted) return;
    await showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Yeni Anı'), content: TextField(controller: title, decoration: const InputDecoration(labelText: 'Anı başlığı')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')), FilledButton(onPressed: () async { if (title.text.trim().isEmpty) return; final entry = MemoryEntry(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title.text.trim(), occurredAt: DateTime.now(), photoPaths: selected); items = [entry, ...items]; await repo.save(items); if (mounted) { setState(() {}); Navigator.pop(context); } }, child: const Text('Kaydet'))]));
    title.dispose();
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Anılar')), floatingActionButton: FloatingActionButton(onPressed: add, child: const Icon(Icons.add)), body: loading ? const Center(child: CircularProgressIndicator()) : items.isEmpty ? const Center(child: Text('Henüz anı eklenmedi.')) : ListView.builder(itemCount: items.length, itemBuilder: (_, i) { final item = items[i]; return Card(child: ListTile(title: Text(item.title), subtitle: Text('${item.occurredAt.day}.${item.occurredAt.month}.${item.occurredAt.year}'), leading: item.photoPaths.isEmpty ? const Icon(Icons.favorite) : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(item.photoPaths.first), width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)))); }));
}
