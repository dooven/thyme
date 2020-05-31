import 'package:boopplant/models/models.dart';
import 'package:boopplant/repository/schedule.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class DayScheduleList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dayScheduleBloc = context.watch<DayScheduleListBloc>();
    return StreamBuilder(
      stream: dayScheduleBloc.plantListFetcher,
      builder: (context, snapshot) {
       if(snapshot.connectionState == ConnectionState.waiting) {
         return CircularProgressIndicator();
       }

       print(snapshot.data);
       return Container();
      },
    );
  }
}

class DayScheduleListBloc {
  final _scheduleController = BehaviorSubject<List<Schedule>>();
  final _scheduleFetch = BehaviorSubject<bool>.seeded(true);

  final ScheduleRepository _scheduleRepository;

  Sink<bool> get scheduleFetchSink => _scheduleFetch.sink;
  Stream<bool> get scheduleFetchStream => _scheduleFetch.stream;
  Stream<List<Schedule>> get scheduleStream => _scheduleController.stream;

  Stream<void> get plantListFetcher => scheduleFetchStream
      .asyncMap((event) => this._scheduleRepository.getByDay(DateTime.now().weekday))
      .doOnData(_scheduleController.add);

  DayScheduleListBloc(this._scheduleRepository);

  void dispose() {
    _scheduleController.close();
    _scheduleFetch.close();
  }
}
