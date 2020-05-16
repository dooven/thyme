import 'package:flutter/widgets.dart';

class SlideRightRoute extends PageRouteBuilder {
  final Widget widget;
  final RouteSettings settings;

  SlideRightRoute({this.widget, this.settings})
      : super(
    settings: settings,
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return widget;
    },
    transitionsBuilder: (BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child) {

      var curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.ease,
      );

      return new SlideTransition(
        position: new Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,

        ).animate(curvedAnimation),
        child: child,
      );
    },
  );
}
