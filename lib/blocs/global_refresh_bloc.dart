import 'package:rxdart/rxdart.dart';

class GlobalRefreshBloc {
  final _refreshController = BehaviorSubject<bool>();

  Function(bool) get refreshSink => _refreshController.sink.add;
  Stream<bool> get refreshStream => _refreshController.stream.startWith(true);

  void dispose() {
    _refreshController.close();
  }
}
