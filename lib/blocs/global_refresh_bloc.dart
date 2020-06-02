import 'package:rxdart/rxdart.dart';

class GlobalRefreshBloc {
  final _refreshController = PublishSubject<bool>();

  Function(bool) get refreshSink => _refreshController.sink.add;
  Stream<bool> get refreshStream => _refreshController.stream;

  void dispose() {
    _refreshController.close();
  }
}
