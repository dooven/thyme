import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  Database db;
  String path;

  static final databaseName = 'database.sqlite';
  static final plantTableName = 'plant';

  Future<Database> setupDb() async {
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, databaseName);
    await openCloseV1();

    return await openDatabase(path, version: 1, onConfigure: onConfigure);
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
  byweekday TEXT DEFAULT '[]',
  time_of_day NUMERIC,
  created_at NUMERIC NOT NULL);''');
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
