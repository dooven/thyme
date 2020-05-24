import 'package:boopplant/app_colors.dart';
import 'package:boopplant/days.dart';
import 'package:boopplant/models/models.dart';
import 'package:boopplant/widgets/button_row.dart';
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
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);

    return Card(
      child: Container(
        margin: EdgeInsets.all(16.0),
        child: Theme(
          data: theme,
          child: ExpansionTile(
            tilePadding: EdgeInsets.all(8),
            children: [
              ButtonRow(
                onTap: () {},
                icon: Icon(
                  Icons.mode_edit,
                  color: Theme.of(context).accentColor,
                ),
                text: Text("Change Name"),
              ),
              ButtonRow(
                onTap: () {},
                icon: Icon(
                  Icons.access_time,
                  color: Theme.of(context).accentColor,
                ),
                text: Text("Change Time"),
              ),
              dayList(),
            ],
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(schedule.name),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(schedule.timeOfDay.format(context),
                        style: Theme.of(context)
                            .textTheme
                            .headline4
                            .copyWith(color: Colors.black)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
