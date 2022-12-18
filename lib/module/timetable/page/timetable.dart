/*
 * 上应小风筝  便利校园，一步到位
 * Copyright (C) 2022 上海应用技术大学 上应小风筝团队
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter/material.dart';
import 'package:kite/module/timetable/events.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/course.dart';
import '../entity/entity.dart';
import '../init.dart';
import '../user_widget/style.dart';
import '../user_widget/interface.dart';
import '../using.dart';
import '../utils.dart';
import '../user_widget/new_ui/timetable.dart' as new_ui;
import '../user_widget/classic_ui/timetable.dart' as classic_ui;

const DisplayMode defaultMode = DisplayMode.weekly;

class TimetablePage extends StatefulWidget {
  final SitTimetable timetable;

  const TimetablePage({super.key, required this.timetable});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  /// 最大周数
  /// TODO 还没用上
  // static const int maxWeekCount = 20;
  final storage = TimetableInit.timetableStorage;

  // 模式：周课表 日课表
  late ValueNotifier<DisplayMode> $displayMode;

  // 课表元数据
  late final ValueNotifier<TimetablePosition> $currentPos;

  SitTimetable get timetable => widget.timetable;

  @override
  void initState() {
    super.initState();
    Log.info('Timetable init');
    final initialMode = storage.lastDisplayMode ?? DisplayMode.weekly;
    $displayMode = ValueNotifier(initialMode);
    $displayMode.addListener(() {
      storage.lastDisplayMode = $displayMode.value;
    });
    storage.lastDisplayMode = initialMode;
    $currentPos = ValueNotifier(TimetablePosition.locate(timetable.startDate, DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Timetable build');
    return Scaffold(
      appBar: AppBar(
        title: $currentPos <<
            (ctx, pos, _) =>
                $displayMode <<
                (ctx, mode, _) => mode == DisplayMode.weekly
                    ? i18n.timetableWeekOrderedName(pos.week).text()
                    : "${i18n.timetableWeekOrderedName(pos.week)} ${makeWeekdaysText()[(pos.day - 1) % 7]}".text(),
        actions: [
          buildSwitchViewButton(context),
          buildMyTimetablesButton(context),
        ],
      ),
      floatingActionButton: InkWell(
          onLongPress: () {
            final today = TimetablePosition.locate(timetable.startDate, DateTime.now());
            if ($currentPos.value != today) {
              if (TimetableStyle.of(context).useNewUI) {
                eventBus.fire(JumpToPosEvent(today));
              } else {
                $currentPos.value = today;
              }
            }
          },
          child: FloatingActionButton(
            child: const Icon(Icons.undo_rounded),
            onPressed: () async {
              if ($displayMode.value == DisplayMode.weekly) {
                await selectWeeklyTimetablePageToJump(context);
              } else {
                await selectDailyTimetablePageToJump(context);
              }
            },
          )),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext ctx) {
    if (TimetableStyle.of(ctx).useNewUI) {
      return new_ui.TimetableViewer(
        timetable: timetable,
        $currentPos: $currentPos,
        $displayMode: $displayMode,
      );
    } else {
      return classic_ui.TimetableViewer(
        timetable: timetable,
        $currentPos: $currentPos,
        $displayMode: $displayMode,
      );
    }
  }

  Widget buildSwitchViewButton(BuildContext ctx) {
    return IconButton(
      icon: const Icon(Icons.swap_horiz_rounded),
      onPressed: () {
        $displayMode.value = $displayMode.value.toggle();
      },
    );
  }

  Widget buildMyTimetablesButton(BuildContext ctx) {
    return IconButton(
        icon: const Icon(Icons.person_rounded),
        onPressed: () async {
          await Navigator.of(ctx).pushNamed(RouteTable.timetableMine);
        });
  }

  Future<void> selectWeeklyTimetablePageToJump(BuildContext ctx) async {
    final currentWeek = $currentPos.value.week;
    final initialIndex = currentWeek - 1;
    final controller = FixedExtentScrollController(initialItem: initialIndex);
    final todayPos = TimetablePosition.locate(timetable.startDate, DateTime.now());
    final todayIndex = todayPos.week - 1;
    final index2Go = await ctx.showPicker(
        count: 20,
        controller: controller,
        ok: i18n.timetableJumpBtn,
        okEnabled: (curSelected) => curSelected != initialIndex,
        actions: [
          (ctx, curSelected) => i18n.timetableJumpFindTodayBtn.text().cupertinoButton(
              onPressed: (curSelected == todayIndex)
                  ? null
                  : () {
                      controller.animateToItem(todayIndex,
                          duration: const Duration(milliseconds: 500), curve: Curves.fastLinearToSlowEaseIn);
                    })
        ],
        make: (ctx, i) {
          return Text(i18n.timetableWeekOrderedName(i + 1));
        });
    controller.dispose();
    if (index2Go != null && index2Go != initialIndex) {
      if (!mounted) return;
      if (TimetableStyle.of(ctx).useNewUI) {
        eventBus.fire(JumpToPosEvent($currentPos.value.copyWith(week: index2Go + 1)));
      } else {
        $currentPos.value = $currentPos.value.copyWith(week: index2Go + 1);
      }
    }
  }

  Future<void> selectDailyTimetablePageToJump(BuildContext ctx) async {
    final currentPos = $currentPos.value;
    final initialWeekIndex = currentPos.week - 1;
    final initialDayIndex = currentPos.day - 1;
    final $week = FixedExtentScrollController(initialItem: initialWeekIndex);
    final $day = FixedExtentScrollController(initialItem: initialDayIndex);
    final todayPos = TimetablePosition.locate(timetable.startDate, DateTime.now());
    final todayWeekIndex = todayPos.week - 1;
    final todayDayIndex = todayPos.day - 1;
    final weekdayNames = makeWeekdaysText();
    final indices2Go = await ctx.showDualPicker(
        countA: 20,
        countB: 7,
        controllerA: $week,
        controllerB: $day,
        ok: i18n.timetableJumpBtn,
        okEnabled: (weekSelected, daySelected) => weekSelected != initialWeekIndex || daySelected != initialDayIndex,
        actions: [
          (ctx, week, day) => i18n.timetableJumpFindTodayBtn.text().cupertinoButton(
              onPressed: (week == todayWeekIndex && day == todayDayIndex)
                  ? null
                  : () {
                      $week.animateToItem(todayWeekIndex,
                          duration: const Duration(milliseconds: 500), curve: Curves.fastLinearToSlowEaseIn);

                      $day.animateToItem(todayDayIndex,
                          duration: const Duration(milliseconds: 500), curve: Curves.fastLinearToSlowEaseIn);
                    })
        ],
        makeA: (ctx, i) => i18n.timetableWeekOrderedName(i + 1).text(),
        makeB: (ctx, i) => weekdayNames[i].text());
    $week.dispose();
    $day.dispose();
    final week2Go = indices2Go?.item1;
    final day2Go = indices2Go?.item2;
    if (week2Go != null && day2Go != null && (week2Go != initialWeekIndex || day2Go != initialDayIndex)) {
      if (!mounted) return;
      if (TimetableStyle.of(ctx).useNewUI) {
        eventBus.fire(JumpToPosEvent(TimetablePosition(week: week2Go + 1, day: day2Go + 1)));
      } else {
        $currentPos.value = TimetablePosition(week: week2Go + 1, day: day2Go + 1);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    $displayMode.dispose();
  }
}
