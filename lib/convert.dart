int dateTimeToMilli(DateTime dateTime) {
  return dateTime.millisecondsSinceEpoch;
}

DateTime milliToDateTime(int milli) {
  return DateTime.fromMillisecondsSinceEpoch(milli);
}
