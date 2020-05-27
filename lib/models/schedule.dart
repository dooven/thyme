import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:boopplant/convert.dart';

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
    name: "created_at",
    toJson: dateTimeToMilli,
    fromJson: milliToDateTime,
  )
  DateTime createdAt;

  Schedule({this.id, this.name, this.timeOfDay, this.createdAt, this.plantId});

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);

  static int timeOfDayToJSON(TimeOfDay timeOfDay) {
    if (timeOfDay == null) return null;

    return timeOfDayToMilli(timeOfDay);
  }

  static TimeOfDay timeOfDayFromJSON(int milli) {
    if (milli == null) return null;

    return milliToTimeOfDay(milli);
  }
}

@JsonSerializable(includeIfNull: false)
class ScheduleNotificationByweekday {
  int id;
  @JsonKey(name: "schedule_id")
  int plantId;

  int day;

  ScheduleNotificationByweekday({
    this.id,
    this.plantId,
    this.day,
  });

  factory ScheduleNotificationByweekday.fromJson(Map<String, dynamic> json) =>
      _$ScheduleNotificationByweekdayFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleNotificationByweekdayToJson(this);
}
