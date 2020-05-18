import 'package:flutter/material.dart';

int timeOfDayToMilli(TimeOfDay timeOfDay) {
  return DateTime.fromMillisecondsSinceEpoch(0)
      .add(Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute))
      .millisecondsSinceEpoch;
}

int dateTimeToMilli(DateTime dateTime) {
  return dateTime.millisecondsSinceEpoch;
}

DateTime milliToDateTime(int milli) {
  return DateTime.fromMillisecondsSinceEpoch(milli);
}

TimeOfDay milliToTimeOfDay(int milli) {
  return TimeOfDay.fromDateTime(milliToDateTime(milli));
}
