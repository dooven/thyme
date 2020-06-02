import 'dart:convert';

import 'package:boopplant/convert.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedule.g.dart';

@JsonSerializable(includeIfNull: false)
class Schedule {
  int id;

  @JsonKey(name: "plant_id")
  int plantId;
  String name;

  @JsonKey(
    name: "time_of_day",
    toJson: timeOfDayToJSON,
    fromJson: timeOfDayFromJSON,
  )
  TimeOfDay timeOfDay;

  @JsonKey(
    name: "byweekday",
    toJson: byweekdayToJSON,
    fromJson: byweekdayFromJSON,
  )
  Set<int> byweekday;

  @JsonKey(
    name: "created_at",
    toJson: dateTimeToMilli,
    fromJson: milliToDateTime,
  )
  DateTime createdAt;

  Schedule(
      {this.id,
      this.name,
      this.timeOfDay,
      this.byweekday,
      this.createdAt,
      this.plantId});

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);

  static String byweekdayToJSON(Set<int> value) {
    if (value == null) return null;

    return jsonEncode(value.toList());
  }

  static Set<int> byweekdayFromJSON(String value) {
    if (value == null) return {};
    final List<dynamic> test = jsonDecode(value);
    List<int> intList = test.cast<int>();
    return intList.toSet();
  }

  static int timeOfDayToJSON(TimeOfDay timeOfDay) {
    if (timeOfDay == null) return null;

    return timeOfDayToMilli(timeOfDay);
  }

  static TimeOfDay timeOfDayFromJSON(int milli) {
    if (milli == null) return null;

    return milliToTimeOfDay(milli);
  }
}
