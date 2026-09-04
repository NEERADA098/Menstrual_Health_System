import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../models/symptom_model.dart';
import '../../domain/entities/symptom_entity.dart';

class SymptomLocalDataSource {
  final DatabaseHelper _dbHelper;
  final Uuid _uuid = const Uuid();

  SymptomLocalDataSource({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<SymptomModel> insertSymptom({
    required String userId,
    required DateTime logDate,
    required SymptomType symptomType,
    required SymptomSeverity severity,
    String? notes,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();

    final model = SymptomModel(
      id: _uuid.v4(),
      userId: userId,
      logDate: logDate,
      symptomType: symptomType,
      severity: severity,
      notes: notes,
      createdAt: now,
      isSynced: false,
    );

    await db.insert('symptom_logs', model.toMap());

    // Add to sync_queue for offline-first sync

    await db.insert('sync_queue', {

      'id': _uuid.v4(),

      'table_name': 'symptom_logs',

      'record_id': model.id,

      'operation': 'INSERT',

      'payload': '{}',

      'created_at': now.toIso8601String(),

      'retry_count': 0,

    });

    return model;
  }

  Future<List<SymptomModel>> getSymptomsForUser(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'symptom_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'log_date DESC',
    );
    return maps.map((m) => SymptomModel.fromMap(m)).toList();
  }

  Future<List<SymptomModel>> getSymptomsForDate(
    String userId,
    DateTime date,
  ) async {
    final db = await _dbHelper.database;
    final dateStr = DateTime(date.year, date.month, date.day)
        .toIso8601String()
        .substring(0, 10);

    final maps = await db.query(
      'symptom_logs',
      where: 'user_id = ? AND log_date LIKE ?',
      whereArgs: [userId, '$dateStr%'],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => SymptomModel.fromMap(m)).toList();
  }

  Future<void> deleteSymptom(String id) async {
    final db = await _dbHelper.database;
    await db.delete('symptom_logs', where: 'id = ?', whereArgs: [id]);
  }
}
