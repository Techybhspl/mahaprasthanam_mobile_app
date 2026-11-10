import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/beneficiary_trip_model.dart';

class DatabaseHelper {
  static const _databaseName = 'mahaprastanam_ops.db';
  static const _databaseVersion = 1;
  static const tableDrafts = 'beneficiary_drafts';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableDrafts (
            local_id TEXT PRIMARY KEY,
            server_id INTEGER,
            trip_date TEXT NOT NULL,
            region_id INTEGER NOT NULL,
            start_district_id INTEGER NOT NULL,
            dest_district_id INTEGER NOT NULL,
            hospital_name TEXT NOT NULL,
            vehicle_id INTEGER NOT NULL,
            vehicle_number TEXT NOT NULL,
            driver_name TEXT NOT NULL,
            attendant_name TEXT NOT NULL,
            attendant_phone TEXT NOT NULL,
            odo_start INTEGER NOT NULL,
            odo_reach INTEGER,
            odo_end INTEGER,
            mandal_name TEXT NOT NULL,
            village TEXT NOT NULL,
            destination TEXT NOT NULL,
            special_case TEXT,
            recommended_by TEXT,
            trip_request_time TEXT,
            trip_start_time TEXT,
            trip_reach_time TEXT,
            trip_end_time TEXT,
            remarks TEXT,
            status TEXT NOT NULL,
            bodies_json TEXT NOT NULL,
            odo_start_image_path TEXT,
            odo_end_image_path TEXT,
            created_at TEXT NOT NULL,
            is_synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> saveOrUpdateDraft(BeneficiaryTripModel trip) async {
    final db = await database;
    await db.insert(
      tableDrafts,
      trip.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BeneficiaryTripModel>> getDrafts() async {
    final db = await database;
    final maps = await db.query(
      tableDrafts,
      where: 'status = ?',
      whereArgs: ['DRAFT'],
      orderBy: 'created_at DESC',
    );

    return maps.map((m) => BeneficiaryTripModel.fromJson(m)).toList();
  }

  Future<List<BeneficiaryTripModel>> getHistory() async {
    final db = await database;
    final maps = await db.query(
      tableDrafts,
      where: 'status = ?',
      whereArgs: ['SUBMITTED'],
      orderBy: 'created_at DESC',
    );

    return maps.map((m) => BeneficiaryTripModel.fromJson(m)).toList();
  }

  Future<BeneficiaryTripModel?> getDraftByLocalId(String localId) async {
    final db = await database;
    final maps = await db.query(
      tableDrafts,
      where: 'local_id = ?',
      whereArgs: [localId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return BeneficiaryTripModel.fromJson(maps.first);
  }

  Future<void> deleteDraft(String localId) async {
    final db = await database;
    await db.delete(
      tableDrafts,
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> markAsSynced(String localId, int serverId) async {
    final db = await database;
    await db.update(
      tableDrafts,
      {
        'server_id': serverId,
        'status': 'SUBMITTED',
        'is_synced': 1,
      },
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }
}
