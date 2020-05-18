import 'package:boopplant/convert.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'plant.g.dart';

@JsonSerializable(includeIfNull: false)
class Plant {
  int id;
  String name;

  @JsonKey(name: "image_url")
  String imageUrl;

  @JsonKey(
      name: "created_at", toJson: dateTimeToMilli, fromJson: milliToDateTime)
  DateTime createdAt;

  @JsonKey(
      name: "time_of_day", toJson: timeOfDayToMilli, fromJson: timeOfDayFromJSON)
  TimeOfDay timeOfDay;

  @JsonKey(
      name: "byweekday", toJson: byweekdayToJSON, fromJson: byweekdayFromJSON)
  List<String> byweekday;

  Plant({this.id, this.name, this.imageUrl, this.createdAt, this.timeOfDay});

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);

  Map<String, dynamic> toJson() => _$PlantToJson(this);

  Plant copyWith({int id, String name, String imageUrl, DateTime createdAt}) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  static TimeOfDay timeOfDayFromJSON(int milli) {
    if(milli == null) return null;
    
    return milliToTimeOfDay(milli);
  }

  static String byweekdayToJSON(List<String> value) {
    return value.join(",");
  }

  static List<String> byweekdayFromJSON(String value) {
    if (value == null) return [];
    return value.split(",");
  }
}
