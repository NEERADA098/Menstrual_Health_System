import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'sync_service.dart';

class SyncManager {
  final SyncService _syncService;
  String? _currentUserId;

  SyncManager({SyncService? syncService})
      : _syncService = syncService ?? SyncService();

  void initialize(String userId) {
    _currentUserId = userId;
    _startListening();
  }

  void _startListening() {
    Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any(
        (result) => result != ConnectivityResult.none,
      );
      if (hasConnection && _currentUserId != null) {
        _triggerSync();
      }
    });
  }

  Future<void> _triggerSync() async {
    final userId = _currentUserId;
    if (userId == null) return;
    final result = await _syncService.sync(userId);
    debugPrint('Auto-sync result: $result');
  }

  Future<SyncResult> manualSync() async {
    final userId = _currentUserId;
    if (userId == null) {
      return const SyncResult(
        success: false,
        message: 'Not logged in',
        syncedCycles: 0,
        syncedSymptoms: 0,
      );
    }
    return _syncService.sync(userId);
  }

  void dispose() {
    _currentUserId = null;
  }
}
