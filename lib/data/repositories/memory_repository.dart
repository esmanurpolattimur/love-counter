import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/memory_entry.dart';

class MemoryRepository {
  static const _storageKey = 'memories_v1';

  Future<List<MemoryEntry>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final entries = (jsonDecode(raw) as List<dynamic>)
        .map((value) => MemoryEntry.fromJson(value as Map<String, dynamic>))
        .toList();
    entries.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return entries;
  }

  Future<void> save(List<MemoryEntry> entries) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(entries.map((entry) => entry.toJson()).toList()));
  }
}
