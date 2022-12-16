/*
 *    上应小风筝(SIT-kite)  便利校园，一步到位
 *    Copyright (C) 2022 上海应用技术大学 上应小风筝团队
 *
 *    This program is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
import 'package:flutter/material.dart';
import 'package:kite/credential/symbol.dart';
import 'package:kite/module/activity/using.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/school.dart';

class SemesterSelector extends StatefulWidget {
  final int? initialYear;
  final Semester? initialSemester;

  /// 是否显示整个学年
  final bool? showEntireYear;
  final bool? showNextYear;
  final Function(int) onNewYearSelect;
  final Function(Semester) onNewSemesterSelect;

  /// Precondition:
  /// [Auth.oaCredential] is not null.
  const SemesterSelector({
    super.key,
    required this.onNewYearSelect,
    required this.onNewSemesterSelect,
    this.initialYear,
    this.initialSemester,
    this.showEntireYear,
    this.showNextYear,
  });

  @override
  State<StatefulWidget> createState() => _SemesterSelectorState();
}

class _SemesterSelectorState extends State<SemesterSelector> {
  late final DateTime now;

  /// 四位年份
  late int selectedYear;

  /// 要查询的学期
  late Semester selectedSemester;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    selectedYear = widget.initialYear ?? (now.month >= 9 ? now.year : now.year - 1);
    if (widget.showEntireYear ?? true) {
      selectedSemester = widget.initialSemester ?? Semester.all;
    } else {
      selectedSemester =
          widget.initialSemester ?? ((now.month >= 3 && now.month <= 7) ? Semester.secondTerm : Semester.firstTerm);
    }
  }

  List<int> _generateYearList(int entranceYear) {
    var endYear = now.month >= 9 ? now.year : now.year - 1;

    endYear += (widget.showNextYear ?? false) ? 1 : 0;
    List<int> yearItems = [];
    for (int year = entranceYear; year <= endYear; ++year) {
      yearItems.add(year);
    }
    return yearItems;
  }

  String buildYearString(int startYear) {
    return '$startYear - ${startYear + 1}';
  }

  /// 构建选择下拉框.
  /// alternatives 是一个字典, key 为实际值, value 为显示值.
  Widget buildSelector<T>(BuildContext ctx, Map<T, String> candidates, T initialValue, void Function(T?) callback) {
    final items = candidates.keys
        .map(
          (k) => DropdownMenuItem<T>(
            value: k,
            child: Text(
              candidates[k]!,
              style: ctx.textTheme.bodyText2,
            ),
          ),
        )
        .toList();

    return DropdownButton<T>(
      value: initialValue,
      enableFeedback: true,
      alignment: Alignment.center,
      icon: const Icon(Icons.keyboard_arrow_down_outlined),
      underline: Container(
        height: 2,
        color: ctx.darkSafeThemeColor,
      ),
      onChanged: callback,
      items: items,
    );
  }

  Widget buildYearSelector(BuildContext ctx) {
    // 得到入学年份
    final oaCredential = Auth.oaCredential;
    final int grade;
    if (oaCredential != null) {
      final fromID = int.tryParse(oaCredential.account.substring(0, 2));
      if (fromID != null) {
        grade = 2000 + fromID;
      } else {
        grade = DateTime.now().year;
      }
    } else {
      grade = DateTime.now().year;
    }
    // 生成经历过的学期并逆序（方便用户选择）
    final List<int> yearList = _generateYearList(grade).reversed.toList();
    final mapping = yearList.map((e) => MapEntry(e, buildYearString(e)));

    // 保证显示上初始选择年份、实际加载的年份、selectedYear 变量一致.
    return buildSelector<int>(ctx, Map.fromEntries(mapping), selectedYear, (int? selected) {
      if (selected != null && selected != selectedYear) {
        setState(() => selectedYear = selected);
        widget.onNewYearSelect(selectedYear);
      }
    });
  }

  Widget buildSemesterSelector(BuildContext ctx) {
    List<Semester> semesters;
    // 不显示学年
    if (!(widget.showEntireYear ?? true)) {
      semesters = [Semester.firstTerm, Semester.secondTerm];
    } else {
      semesters = [Semester.all, Semester.firstTerm, Semester.secondTerm];
    }
    final semesterItems = Map.fromEntries(semesters.map((e) => MapEntry(e, e.localized())));
    // 保证显示上初始选择学期、实际加载的学期、selectedSemester 变量一致.
    return buildSelector<Semester>(ctx, semesterItems, selectedSemester, (Semester? selected) {
      if (selected != null && selected != selectedSemester) {
        setState(() => selectedSemester = selected);
        widget.onNewSemesterSelect(selectedSemester);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      buildYearSelector(context),
      Container(
        margin: const EdgeInsets.only(left: 15),
        child: buildSemesterSelector(context),
      ),
    ]);
  }
}
