import 'package:boopplant/convert.dart';
import 'package:boopplant/database.dart';
import 'package:boopplant/models/models.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

typedef Future UpdateScheduleFn(
  int id, {
  TimeOfDay timeOfDay,
  Set<int> byweekday,
  String name,
});

class ScheduleRepository {
  final Database database;

  ScheduleRepository({this.database});

  Future<List<Schedule>> getByPlantId(int plantId) {
    return database
        .query(
          LocalDatabase.scheduleTableName,
          where: 'plant_id = $plantId',
        )
        .then((value) => value.map((e) => Schedule.fromJson(e)).toList());
  }

  Future<Schedule> getById(int id) {
    return database
        .query(
          LocalDatabase.scheduleTableName,
          where: 'id = $id',
        )
        .then((value) => value.map((e) => Schedule.fromJson(e)).first);
  }

  Future<Schedule> insert(Schedule schedule) async {
    schedule.id = await database.insert(
      LocalDatabase.scheduleTableName,
      schedule.toJson(),
    );

    return schedule;
  }

  Future<int> update(
    int id, {
    TimeOfDay timeOfDay,
    Set<int> byweekday,
    String name,
  }) {
    final updateValues = {
      if (timeOfDay != null) 'time_of_day': timeOfDayToMilli(timeOfDay),
      if (byweekday != null) 'byweekday': Schedule.byweekdayToJSON(byweekday),
      if (name != null) 'name': name,
    };

    return database.update(
      LocalDatabase.scheduleTableName,
      updateValues,
      where: 'id = $id',
    );
  }

  Future<List<Schedule>> getByDay(int weekdayIdx) {
    return database.query(LocalDatabase.scheduleTableName).then((value) => value
        .map((e) => Schedule.fromJson(e))
        .where((element) => element.byweekday.contains(weekdayIdx))
        .toList());
  }

  Future<void> delete(int id) {
    return database.delete(LocalDatabase.scheduleTableName, where: '$id = $id');
  }
}
