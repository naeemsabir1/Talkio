
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memo_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the storage service
final memoStorageServiceProvider = Provider<MemoStorageService>((ref) {
  throw UnimplementedError('Initialize with overrides');
});

class MemoStorageService {
  final SharedPreferences _prefs;
  static const String _storageKey = 'saved_memos_v1';

  MemoStorageService(this._prefs);

  /// Load all memos from storage
  List<Memo> getMemos() {
    final jsonList = _prefs.getStringList(_storageKey) ?? [];
    return jsonList
        .map((jsonStr) => Memo.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  /// Save a new memo or update existing
  Future<void> saveMemo(Memo memo) async {
    final memos = getMemos();
    
    // Check if exists and update, or add new
    final index = memos.indexWhere((m) => m.id == memo.id);
    if (index >= 0) {
      memos[index] = memo;
    } else {
      memos.insert(0, memo); // Add to top
    }

    await _saveMemosList(memos);
  }

  /// Delete a memo by ID
  Future<void> deleteMemo(String id) async {
    final memos = getMemos();
    memos.removeWhere((m) => m.id == id);
    await _saveMemosList(memos);
  }

  /// Delete all memos
  Future<void> clearAll() async {
    await _prefs.remove(_storageKey);
  }

  /// Helper to commit list to storage
  Future<void> _saveMemosList(List<Memo> memos) async {
    final jsonList = memos.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs.setStringList(_storageKey, jsonList);
  }
}
