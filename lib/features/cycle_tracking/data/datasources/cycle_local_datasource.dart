import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../models/cycle_model.dart';
import '../../domain/entities/cycle_entity.dart';

class CycleLocalDataSource {
  final DatabaseHelper _dbHelper;
  final Uuid _uuid = const Uuid();

  CycleLocalDataSource({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<CycleModel> insertCycle({
    required String userId,
    required DateTime startDate,
    DateTime? endDate,
    int? cycleLength,
    int? periodLength,
    String? flowIntensity,
    String? notes,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();

    final model = CycleModel(
      id: _uuid.v4(),
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      cycleLength: cycleLength,
      periodLength: periodLength,
      flowIntensity: flowIntensity != null ? _parseFlow(flowIntensity) : null,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );

    await db.insert('cycle_logs', model.toMap());

    await db.insert('sync_queue', {
      'id': _uuid.v4(),
      'table_name': 'cycle_logs',
      'record_id': model.id,
      'operation': 'INSERT',
      'payload': '{}',
      'created_at': now.toIso8601String(),
      'retry_count': 0,
    });

    return model;
  }

  Future<List<CycleModel>> getCyclesForUser(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'cycle_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_date DESC',
    );
    return maps.map((map) => CycleModel.fromMap(map)).toList();
  }

  Future<CycleModel?> getMostRecentCycle(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'cycle_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_date DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CycleModel.fromMap(maps.first);
  }

  Future<void> updateCycle(CycleModel cycle) async {
    final db = await _dbHelper.database;
    final updated = cycle.copyWith(updatedAt: DateTime.now());
    await db.update(
      'cycle_logs',
      CycleModel(
        id: updated.id,
        userId: updated.userId,
        startDate: updated.startDate,
        endDate: updated.endDate,
        cycleLength: updated.cycleLength,
        periodLength: updated.periodLength,
        flowIntensity: updated.flowIntensity,
        notes: updated.notes,
        createdAt: updated.createdAt,
        updatedAt: updated.updatedAt,
        isSynced: false,
      ).toMap(),
      where: 'id = ?',
      whereArgs: [updated.id],
    );
  }

  Future<void> deleteCycle(String id) async {
    final db = await _dbHelper.database;
    await db.delete('cycle_logs', where: 'id = ?', whereArgs: [id]);
  }

  FlowIntensity _parseFlow(String value) {
    switch (value) {
      case 'light':
        return FlowIntensity.light;
      case 'heavy':
        return FlowIntensity.heavy;
      default:
        return FlowIntensity.medium;
    }
  }
}
