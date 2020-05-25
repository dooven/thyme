import 'package:boopplant/models/models.dart';
import 'package:boopplant/widgets/schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScheduleList extends StatefulWidget {
  const ScheduleList({
    Key key,
    @required List<Schedule> schedule,
    @required
        Function(int id,
                {List<int> byweekday, String name, TimeOfDay timeOfDay})
            updateSchedule,
  })  : _schedule = schedule,
        _updateSchedule = updateSchedule,
        super(key: key);

  final List<Schedule> _schedule;
  final Function(int id,
      {List<int> byweekday, String name, TimeOfDay timeOfDay}) _updateSchedule;

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
                          individualScheduleFuture[schedule.id] =
                              widget._updateSchedule(schedule.id,
                                  name: textController.text);
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
            final e = widget._schedule[index];
            return FutureBuilder(
                key: Key(e.id.toString()),
                future: individualScheduleFuture[e.id],
                builder: (context, snapshot) {
                  return ScheduleCard(
                    schedule: e,
                    onTapScheduleNameEdit: () {
                      _modifyScheduleName(e);
                    },
                    onTapScheduleTimeEdit: () async {
                      final response = await showTimePicker(
                          context: context, initialTime: e.timeOfDay);
                      if (response == null) return;
                      setState(() {
                        individualScheduleFuture[e.id] =
                            widget._updateSchedule(e.id, timeOfDay: response);
                      });
                    },
                    saveByWeekDayCallback: (byweekDay) {
                      setState(() {
                        individualScheduleFuture[e.id] =
                            widget._updateSchedule(e.id, byweekday: byweekDay);
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
