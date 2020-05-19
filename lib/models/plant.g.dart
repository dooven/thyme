// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plant _$PlantFromJson(Map<String, dynamic> json) {
  return Plant(
    id: json['id'] as int,
    name: json['name'] as String,
    imageUrl: json['image_url'] as String,
    createdAt: milliToDateTime(json['created_at'] as int),
    timeOfDay: Plant.timeOfDayFromJSON(json['time_of_day'] as int),
  )..byweekday = Plant.byweekdayFromJSON(json['byweekday'] as String);
}

Map<String, dynamic> _$PlantToJson(Plant instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('image_url', instance.imageUrl);
  writeNotNull('created_at', dateTimeToMilli(instance.createdAt));
  writeNotNull('time_of_day', Plant.timeOfDayToJSON(instance.timeOfDay));
  writeNotNull('byweekday', Plant.byweekdayToJSON(instance.byweekday));
  return val;
}
