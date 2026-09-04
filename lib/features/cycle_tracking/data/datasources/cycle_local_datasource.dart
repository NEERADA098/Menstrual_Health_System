import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/cycle_entity.dart';
import '../models/cycle_model.dart';

/// CycleLocalDataSource - The ONLY place that writes raw SQL queries.
class CycleLocalDataSource {
  final DatabaseHelper _dbHelper;
  final Uuid _uuid = const Uuid();

  CycleLocalDataSource({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Inserts a new cycle log. Generates a unique ID automatically.
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
      id: _uuid.v4(), // Generates something like "a3f5c8e1-..."
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      cycleLength: cycleLength,
      periodLength: periodLength,
      flowIntensity: flowIntensity != null
          ? _parseFlow(flowIntensity)
          : null,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      isSynced: false, // New local data hasn't reached the server yet
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

  /// Fetches all cycle logs for a user, most recent first.
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

  /// Fetches only the SINGLE most recent cycle - useful for
  /// quickly showing "current cycle day" on the home screen.
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

  /// Updates an existing cycle log (e.g., user adds end_date later
  /// once their period finishes).
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
        isSynced: false, // Any local edit means it needs re-syncing
      ).toMap(),
      where: 'id = ?',
      whereArgs: [updated.id],
    );
  }

  /// Deletes a cycle log by ID.
  Future<void> deleteCycle(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'cycle_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
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