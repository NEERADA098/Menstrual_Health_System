import 'package:flutter/foundation.dart';
import '../../core/database/database_helper.dart';
import '../../core/network/api_client.dart';

class SyncService {
  final DatabaseHelper _dbHelper;
  final ApiClient _apiClient;

  SyncService({
    DatabaseHelper? dbHelper,
    ApiClient? apiClient,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _apiClient = apiClient ?? ApiClient();

  Future<SyncResult> sync(String userId) async {
    final serverReachable = await _apiClient.isServerReachable();
    if (!serverReachable) {
      return const SyncResult(
        success: false,
        message: 'Server not reachable',
        syncedCycles: 0,
        syncedSymptoms: 0,
      );
    }

    final db = await _dbHelper.database;
    final pendingEntries = await db.query(
      'sync_queue',
      orderBy: 'created_at ASC',
    );

    if (pendingEntries.isEmpty) {
      return const SyncResult(
        success: true,
        message: 'Nothing to sync',
        syncedCycles: 0,
        syncedSymptoms: 0,
      );
    }

    final List<Map<String, dynamic>> cycleLogs = [];
    final List<Map<String, dynamic>> symptomLogs = [];
    final List<String> processedQueueIds = [];

    for (final entry in pendingEntries) {
      final tableName = entry['table_name'] as String;
      final recordId = entry['record_id'] as String;
      final queueId = entry['id'] as String;

      if (tableName == 'cycle_logs') {
        final records = await db.query(
          'cycle_logs',
          where: 'id = ?',
          whereArgs: [recordId],
        );
        if (records.isNotEmpty) {
          final record = Map<String, dynamic>.from(records.first);
          record['user_id'] = userId;
          cycleLogs.add(record);
          processedQueueIds.add(queueId);
        }
      } else if (tableName == 'symptom_logs') {
        final records = await db.query(
          'symptom_logs',
          where: 'id = ?',
          whereArgs: [recordId],
        );
        if (records.isNotEmpty) {
          final record = Map<String, dynamic>.from(records.first);
          record['user_id'] = userId;
          symptomLogs.add(record);
          processedQueueIds.add(queueId);
        }
      }
    }

    try {
      final response = await _apiClient.batchSync(
        userId: userId,
        cycleLogs: cycleLogs,
        symptomLogs: symptomLogs,
      );

      final syncedCycles = response['synced_cycles'] as int? ?? 0;
      final syncedSymptoms = response['synced_symptoms'] as int? ?? 0;

      for (final queueId in processedQueueIds) {
        await db.delete('sync_queue', where: 'id = ?', whereArgs: [queueId]);
      }

      if (cycleLogs.isNotEmpty) {
        await db.rawUpdate(
          'UPDATE cycle_logs SET is_synced = 1 WHERE is_synced = 0 AND user_id = ?',
          [userId],
        );
      }
      if (symptomLogs.isNotEmpty) {
        await db.rawUpdate(
          'UPDATE symptom_logs SET is_synced = 1 WHERE is_synced = 0 AND user_id = ?',
          [userId],
        );
      }

      return SyncResult(
        success: true,
        message: response['message'] as String? ?? 'Sync complete',
        syncedCycles: syncedCycles,
        syncedSymptoms: syncedSymptoms,
      );
    } catch (e) {
      debugPrint('Sync failed: $e');
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
        syncedCycles: 0,
        syncedSymptoms: 0,
      );
    }
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedCycles;
  final int syncedSymptoms;

  const SyncResult({
    required this.success,
    required this.message,
    required this.syncedCycles,
    required this.syncedSymptoms,
  });

  @override
  String toString() =>
      'SyncResult(success: $success, cycles: $syncedCycles, symptoms: $syncedSymptoms)';
}
