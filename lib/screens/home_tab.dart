import 'package:boopplant/screens/day_schedule_list.dart';
import 'package:boopplant/screens/home.dart';
import 'package:boopplant/screens/screens.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    DayScheduleList(),
    PlantList(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _widgetOptions.length,
      child: Scaffold(
        body: TabBarView(
          children: _widgetOptions,
          // index: _selectedIndex,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          heroTag: "add-fab",
          onPressed: () {
            Navigator.of(context).pushNamed(HomeRoutes.plantModify);
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
          elevation: 2.0,
        ),
        bottomNavigationBar: TabBar(
          indicatorSize: TabBarIndicatorSize.label,
          // indicatorPadding: EdgeInsets.all(5.0),
          indicatorColor: Theme.of(context).primaryColor,
          onTap: _onItemTapped,
          tabs: [
            Tab(
              icon: Icon(Icons.schedule),
            ),
            Tab(
              icon: Icon(Icons.list),
            ),
          ],
          // selectedItemColor: Theme.of(context).primaryColorDark,
        ),
      ),
    );
  }
}
