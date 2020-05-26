import 'package:boopplant/database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseBloc {
  final _databaseController = BehaviorSubject<Database>();

  Stream<Database> get databaseStream => _databaseController.stream;

  Database get database => _databaseController.value;


  void bootStrapDatabase() {
    LocalDatabase().setupDb().then((value) {
      _databaseController.add(value);
    });
  }

  void dispose() {
    _databaseController.close();
  }
}
