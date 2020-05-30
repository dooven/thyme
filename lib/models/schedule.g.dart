// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schedule _$ScheduleFromJson(Map<String, dynamic> json) {
  return Schedule(
    id: json['id'] as int,
    name: json['name'] as String,
    timeOfDay: Schedule.timeOfDayFromJSON(json['time_of_day'] as int),
    byweekday: Schedule.byweekdayFromJSON(json['byweekday'] as String),
    createdAt: milliToDateTime(json['created_at'] as int),
    plantId: json['plant_id'] as int,
  );
}

Map<String, dynamic> _$ScheduleToJson(Schedule instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('plant_id', instance.plantId);
  writeNotNull('name', instance.name);
  writeNotNull('time_of_day', Schedule.timeOfDayToJSON(instance.timeOfDay));
  writeNotNull('byweekday', Schedule.byweekdayToJSON(instance.byweekday));
  writeNotNull('created_at', dateTimeToMilli(instance.createdAt));
  return val;
}
