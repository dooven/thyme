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
  writeNotNull('name', instance.name);
  writeNotNull('time_of_day', Schedule.timeOfDayToJSON(instance.timeOfDay));
  writeNotNull('byweekday', Schedule.byweekdayToJSON(instance.byweekday));
  return val;
}
