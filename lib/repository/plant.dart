import 'package:boopplant/database.dart';
import 'package:boopplant/models/plant.dart';
import 'package:sqflite/sqflite.dart';

class PlantRepository {
  final Database database;

  PlantRepository({ this.database });

  Future<Plant> insert(Plant plant) async {
    plant.id = await database.insert(
      LocalDatabase.plantTableName,
      plant.toJson(),
    );

    return plant;
  }

  Future<List<Plant>> list() async {
    final result = await database.query(LocalDatabase.plantTableName);

    return result.map((e) => Plant.fromJson(e));
  }
}
