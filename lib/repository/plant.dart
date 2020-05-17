import 'package:boopplant/database.dart';
import 'package:boopplant/models/plant.dart';
import 'package:sqflite/sqflite.dart';

class PlantRepository {
  final Database database;

  PlantRepository({this.database});

  Future<Plant> insert(Plant plant) async {
    plant.id = await database.insert(
      LocalDatabase.plantTableName,
      plant.toJson(),
    );

    return plant;
  }

  Future<int> update(int id, {String name, String imageUrl}) {
    return database.update(
        LocalDatabase.plantTableName, {'name': name, 'image_url': imageUrl},
        where: 'id = $id');
  }

  Future<Plant> getById(int id) {
    return database.query(LocalDatabase.plantTableName, where: 'id = $id').then(
      (value) {
        if (value.isEmpty) {
          return null;
        }

        return Plant.fromJson(value.first);
      },
    );
  }

  Future<List<Plant>> list() async {
    try {
      final result = await database.query(LocalDatabase.plantTableName,
          columns: null, where: null);

      return result.map((e) => Plant.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
