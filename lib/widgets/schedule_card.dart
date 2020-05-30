import 'package:boopplant/app_colors.dart';
import 'package:boopplant/days.dart';
import 'package:boopplant/models/models.dart';
import 'package:boopplant/widgets/button_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final Function(int weekday) saveByWeekDayCallback;
  final Function() onTapScheduleNameEdit;
  final Function() onTapScheduleTimeEdit;

  const ScheduleCard({
    Key key,
    @required this.schedule,
    @required this.saveByWeekDayCallback,
    @required this.onTapScheduleNameEdit,
    @required this.onTapScheduleTimeEdit,
  }) : super(key: key);

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
                  onTap: saveByWeekDayCallback != null
                      ? () => saveByWeekDayCallback(index)
                      : null,
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
            key: PageStorageKey(schedule.id.toString()),
            tilePadding: EdgeInsets.all(8),
            children: [
              Builder(
                builder: (context) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ButtonRow(
                          onTap: onTapScheduleNameEdit,
                          icon: Icon(
                            Icons.mode_edit,
                            color: Theme.of(context).accentColor,
                          ),
                          text: Text("Change Name"),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ButtonRow(
                          onTap: onTapScheduleNameEdit,
                          icon: Icon(
                            Icons.remove_circle,
                            color: Theme.of(context).accentColor,
                          ),
                          text: Text("Remove Schedule"),
                        ),
                      )
                    ],
                  );
                },
              ),
              ButtonRow(
                onTap: onTapScheduleTimeEdit,
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
