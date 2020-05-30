import 'package:boopplant/models/models.dart';
import 'package:boopplant/widgets/schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScheduleList extends StatefulWidget {
  const ScheduleList({
    Key key,
    @required List<Schedule> schedule,
    @required Function(TimeOfDay timeOfDay, Schedule schedule) updateTime,
    @required Function(int weekdayIdx, Schedule schedule) updateByweekday,
  })  : _schedule = schedule,
        _updateTime = updateTime,
        _updateByweekday = updateByweekday,
        super(key: key);

  final List<Schedule> _schedule;
  final Function(TimeOfDay timeOfDay, Schedule schedule) _updateTime;
  final Function(int weekdayIdx, Schedule schedule) _updateByweekday;

  @override
  _ScheduleListState createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  Map<int, Future> individualScheduleFuture = {};

  Future<void> _modifyScheduleName(Schedule schedule) {
    final textController = TextEditingController(text: schedule.name);

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: TextFormField(controller: textController),
            actions: <Widget>[
              RaisedButton(
                onPressed: textController.text.isNotEmpty
                    ? () {
                        setState(() {
                          // individualScheduleFuture[schedule.id] =
                          //     widget._updateSchedule(schedule.id,
                          //         name: textController.text);
                        });
                        Navigator.of(context).pop();
                      }
                    : null,
                child: const Text('Save'),
              ),
              OutlineButton(
                onPressed: Navigator.of(context).pop,
                child: const Text('Cancel'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final schedule = widget._schedule[index];
            return FutureBuilder(
                key: Key(schedule.id.toString()),
                future: individualScheduleFuture[schedule.id],
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text("ERROR")));
                  }

                  return ScheduleCard(
                    schedule: schedule,
                    onTapScheduleNameEdit: () {
                      _modifyScheduleName(schedule);
                    },
                    onTapScheduleTimeEdit: () async {
                      final response = await showTimePicker(
                          context: context, initialTime: schedule.timeOfDay);
                      if (response == null) return;
                      setState(() {
                        individualScheduleFuture[schedule.id] =
                            widget._updateTime(response, schedule);
                      });
                    },
                    saveByWeekDayCallback: (weekdayIdx) {
                      setState(() {
                        individualScheduleFuture[schedule.id] =
                            widget._updateByweekday(weekdayIdx, schedule);
                      });
                    },
                  );
                });
          },
          childCount: widget._schedule.length,
        ),
      ),
    );
  }
}
