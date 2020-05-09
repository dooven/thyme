import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  Database db;
  String path;

  static final databaseName = 'database.sqlite';
  static final plantTableName = 'plant';

  Future setupDb() async {
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, databaseName);
    await openCloseV1();
  }

  Future onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future openCloseV1() async {
    void _createInitialTable(Batch batch) {
      batch.execute('''
  CREATE TABLE IF NOT EXISTS plant (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL ,
  image_url TEXT,
  created_at NUMERIC NOT NULL);''');

      batch.execute('''
  CREATE TABLE IF NOT EXISTS schedule_rule (
  id INTEGER PRIMARY KEY AUTOINCREMENT  
  );''');

      batch.execute('''
  CREATE TABLE IF NOT EXISTS schedule (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  plant_id INTEGER,
  schedule_rule_id INTEGER,
  start_time INTEGER NOT NULL,
  end_time INTEGER NOT NULL,
  FOREIGN KEY(plant_id) REFERENCES plant(id),
  FOREIGN KEY(schedule_rule_id) REFERENCES schedule_rule(id)
  );''');
    }

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        var batch = db.batch();
        _createInitialTable(batch);
        await batch.commit();
      },
      onConfigure: onConfigure,
      onDowngrade: onDatabaseDowngradeDelete,
    );

    await db.close();
    db = null;
  }
}
