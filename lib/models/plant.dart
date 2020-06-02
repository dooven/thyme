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
    name: "created_at",
    toJson: dateTimeToMilli,
    fromJson: milliToDateTime,
  )
  DateTime createdAt;

  @JsonKey(
    name: "time_of_day",
    toJson: timeOfDayToJSON,
    fromJson: timeOfDayFromJSON,
  )
  TimeOfDay timeOfDay;

  Plant({this.id, this.name, this.imageUrl, this.createdAt, this.timeOfDay});

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);

  Map<String, dynamic> toJson() => _$PlantToJson(this);

  static int timeOfDayToJSON(TimeOfDay timeOfDay) {
    if (timeOfDay == null) return null;

    return timeOfDayToMilli(timeOfDay);
  }

  static TimeOfDay timeOfDayFromJSON(int milli) {
    if (milli == null) return null;

    return milliToTimeOfDay(milli);
  }
}
