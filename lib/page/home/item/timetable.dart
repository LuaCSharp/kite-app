import 'package:flutter/material.dart';
import 'package:kite/global/bus.dart';
import 'package:kite/page/home/item.dart';

class TimetableItem extends StatefulWidget {
  const TimetableItem({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimetableItemState();
}

class _TimetableItemState extends State<TimetableItem> {
  @override
  void initState() {
    eventBus.on('onHomeRefresh', (arg) {});

    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const HomeItem(route: '/timetable', icon: AssetImage('assets/home/icon_daily_report.png'), title: '课程表');
  }
}
