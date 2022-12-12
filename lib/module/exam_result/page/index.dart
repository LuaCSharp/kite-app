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
import 'package:flutter/rendering.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/result.dart';
import '../init.dart';
import '../using.dart';
import '../util.dart';
import '../user_widget/item.dart';
import '../events.dart';

class ExamResultPage extends StatefulWidget {
  const ExamResultPage({super.key});

  @override
  State<ExamResultPage> createState() => _ExamResultPageState();
}

class _ExamResultPageState extends State<ExamResultPage> {
  /// 四位年份
  late int selectedYear;

  /// 要查询的学期
  late Semester selectedSemester;

  /// 成绩列表
  List<ExamResult>? _allResults;

  // ValueNotifier is used to limit rebuilding when `Lesson Eval` is going up or going down.
  final $showEvaluationBtn = ValueNotifier(true);
  bool isSelecting = false;
  var multiselect = MultiselectController();
  final _multiselectKey = GlobalKey(debugLabel: "Multiselect");

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = (now.month >= 9 ? now.year : now.year - 1);
    selectedSemester = Semester.all;
    onRefresh();
  }

  void onRefresh() {
    if (!mounted) return;
    setState(() {
      _allResults = null;
    });
    ExamResultInit.resultService.getResultList(SchoolYear(selectedYear), selectedSemester).then((value) {
      if (!mounted) return;
      setState(() {
        _allResults = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // If the user has logged in, they can only check the cache.
    if (!Auth.hasLoggedIn) return UnauthorizedTipPage(title: i18n.ftype_examArr.text());
    final allResults = _allResults;
    final selectedExams = isSelecting ? multiselect.getSelectedItems().cast<ExamResult>() : allResults;
    final String title;
    if (selectedExams != null) {
      var gpa = calcGPA(selectedExams);
      if (gpa.isNaN) {
        gpa = 0;
      }
      title = i18n.gpaPointLabel(selectedSemester.localized(), gpa.toStringAsPrecision(2));
    } else {
      title = i18n.ftype_examResult;
    }

    return Scaffold(
      appBar: AppBar(
        title: title.text(),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isSelecting = !isSelecting;
                  if (isSelecting == false) {
                    multiselect.clearSelection();
                  }
                });
              },
              icon: Icon(isSelecting ? Icons.check_box_outlined : Icons.check_box_outline_blank)),
        ],
      ),
      body: [
        _buildHeader(),
        allResults == null
            ? Placeholders.loading()
            : NotificationListener<UserScrollNotification>(
                // TODO: How can I extract this to a more general component?
                onNotification: (notification) {
                  final ScrollDirection direction = notification.direction;
                  if (direction == ScrollDirection.reverse) {
                    $showEvaluationBtn.value = false;
                  } else if (direction == ScrollDirection.forward) {
                    $showEvaluationBtn.value = true;
                  }
                  return true;
                },
                child: Expanded(child: allResults.isNotEmpty ? _buildExamResultList(allResults) : _buildNoResult())),
      ].column(),
      floatingActionButton: buildEvaluationBtn(context),
    );
  }

  Widget? buildEvaluationBtn(BuildContext ctx) {
    // If the user is currently offline, don't let them see the evaluation button.
    if (Auth.oaCredential == null) return null;
    return $showEvaluationBtn <<
        (ctx, showBtn, _) {
          return AnimatedSlideDown(
              upWhen: showBtn,
              child: FloatingActionButton.extended(
                icon: const Icon(Icons.assessment_outlined),
                onPressed: () async {
                  await Navigator.of(context).pushNamed(RouteTable.examResultEvaluation);
                  if (!mounted) return;
                  eventBus.fire(LessonEvaluatedEvent());
                  await Future.delayed(const Duration(milliseconds: 1000));
                  onRefresh();
                },
                label: i18n.lessonEvaluationBtn.text(),
              ));
        };
  }

  Widget _buildHeader() {
    return [
      Container(
        margin: const EdgeInsets.only(left: 15),
        child: SemesterSelector(
          onNewYearSelect: (year) {
            setState(() => selectedYear = year);
            onRefresh();
          },
          onNewSemesterSelect: (semester) {
            setState(() => selectedSemester = semester);
            onRefresh();
          },
          initialYear: selectedYear,
          initialSemester: selectedSemester,
        ),
      ),
    ].column();
  }

  Widget _buildExamResultList(List<ExamResult> all) {
    return MultiselectScope<ExamResult>(
      key: _multiselectKey,
      controller: multiselect,
      dataSource: all,
      // Set this to true if you want automatically
      // clear selection when user tap back button
      clearSelectionOnPop: true,
      // When you update [dataSource] then selected indexes will update
      // so that the same elements in new [dataSource] are selected
      keepSelectedItemsBetweenUpdates: true,
      initialSelectedIndexes: null,
      // Callback that call on selection changing
      onSelectionChanged: (indexes, items) {
        setState(() {});
      },
      child: GridView.builder(
        itemCount: all.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 750,
          mainAxisExtent: 60,
        ),
        itemBuilder: (ctx, index) => ScoreItem(all[index], index: index, isSelectingMode: isSelecting),
      ),
    );
  }

  Widget _buildNoResult() {
    return LeavingBlank.svgAssets(
      assetName: "assets/common/not-found.svg",
      desc: i18n.examResultNoResult,
      width: 240,
      height: 240,
    );
  }

  @override
  void dispose() {
    super.dispose();
    multiselect.dispose();
  }
}
