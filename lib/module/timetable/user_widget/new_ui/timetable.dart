import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kite/module/timetable/events.dart';
import 'package:rettulf/rettulf.dart';

import '../../entity/course.dart';
import '../../entity/entity.dart';
import '../../using.dart';
import '../../utils.dart';
import '../interface.dart';
import 'daily.dart';
import 'header.dart';
import 'weekly.dart';

export 'daily.dart';

class TimetableViewer extends StatefulWidget {
  final SitTimetable timetable;

  final ValueNotifier<DisplayMode> $displayMode;

  final ValueNotifier<TimetablePosition> $currentPos;

  const TimetableViewer({
    required this.timetable,
    required this.$displayMode,
    required this.$currentPos,
    super.key,
  });

  @override
  State<TimetableViewer> createState() => _TimetableViewerState();
}

class _TimetableViewerState extends State<TimetableViewer> {
  /// 最大周数
  /// TODO 还没用上
  // static const int maxWeekCount = 20;
  SitTimetable get timetable => widget.timetable;

  @override
  void initState() {
    Log.info('TimetableViewer init');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return [
      buildTimetableBody(context).safeArea(),
      buildTableHeader(context),
    ].stack();
  }

  Widget buildTimetableBody(BuildContext ctx) {
    return widget.$displayMode <<
        (ctx, mode, _) => (mode == DisplayMode.daily
                    ? DailyTimetable(
                        $currentPos: widget.$currentPos,
                        timetable: timetable,
                      )
                    : WeeklyTimetable(
                        $currentPos: widget.$currentPos,
                        timetable: timetable,
                      ))
                .animatedSwitched(
              d: const Duration(milliseconds: 300),
            );
  }

  Widget buildTableHeader(BuildContext ctx) {
    final weekdayAbbr = makeWeekdaysShortText();
    return widget.$currentPos <<
        (ctx, cur, _) => TimetableHeader(
            weekdayAbbr: weekdayAbbr,
            currentWeek: cur.week,
            selectedDay: cur.day,
            startDate: timetable.startDate,
            onDayTap: (selectedDay) {
              if (widget.$displayMode.value == DisplayMode.daily) {
                eventBus.fire(JumpToPosEvent(TimetablePosition(week: cur.week, day: selectedDay)));
              } else {
                widget.$currentPos.value = TimetablePosition(week: cur.week, day: selectedDay);
              }
            });
  }
}
