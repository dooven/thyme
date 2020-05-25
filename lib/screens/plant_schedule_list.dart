import 'package:boopplant/models/models.dart';
import 'package:boopplant/widgets/schedule_card.dart';
import 'package:flutter/widgets.dart';

class ScheduleList extends StatefulWidget {
  const ScheduleList({
    Key key,
    @required List<Schedule> schedule,
    @required Function(int id, {List<int> byweekday}) updateScheduleByWeekly,
  })  : _schedule = schedule,
        _updateScheduleByWeekly = updateScheduleByWeekly,
        super(key: key);

  final List<Schedule> _schedule;
  final Function(int id, {List<int> byweekday}) _updateScheduleByWeekly;

  @override
  _ScheduleListState createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  Map<int, Future> individualScheduleFuture = {};

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
                    saveByWeekDayCallback: (byweekDay) {
                      setState(() {
                        individualScheduleFuture[e.id] =
                            widget._updateScheduleByWeekly(e.id,
                                byweekday: byweekDay);
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
