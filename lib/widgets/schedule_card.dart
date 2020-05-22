import 'package:boopplant/app_colors.dart';
import 'package:boopplant/days.dart';
import 'package:boopplant/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;

  const ScheduleCard({Key key, this.schedule}) : super(key: key);

  Widget dayList() {
    return Builder(
      builder: (context) => Row(
          children: List.generate(
        7,
        (index) {
          final byweekday = schedule.byweekday;
          final isScheduledForCurrentDay = byweekday.contains(index);
          var dayTextStyle = Theme.of(context).textTheme.bodyText1;

          if (!isScheduledForCurrentDay) {
            dayTextStyle = dayTextStyle.copyWith(color: AppColors.disabledText);
          }

          return Container(
            margin: EdgeInsets.only(right: 8, top: 16),
            child: ClipOval(
              child: Material(
                color: isScheduledForCurrentDay
                    ? Theme.of(context).primaryColor
                    : AppColors.disabledBackground,
                child: InkWell(
                  onTap: () {},
                  splashColor: Colors.white,
                  child: Container(
                    height: 35,
                    width: 35,
                    child: Center(
                      child: Text(
                        Days.dayNumberToLetter(index),
                        style: dayTextStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        margin: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(schedule.name),
                SizedBox(width: 8.0),
                ClipOval(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      splashColor: Colors.white,
                      child: Container(
                        height: 35,
                        width: 35,
                        child: Center(
                          child: Icon(Icons.edit, size: 20),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  schedule.timeOfDay.format(context),
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: Colors.black),
                ),
                IconButton(
                  color: Theme.of(context).accentColor,
                  icon: Icon(Icons.access_time),
                  onPressed: () {},
                )
              ],
            ),
            dayList(),
          ],
        ),
      ),
    );
  }
}
