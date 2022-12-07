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

import '../page/util.dart';
import 'score.dart';
import '../using.dart';

part 'list.g.dart';

/// No I18n for unambiguity among all languages
class ActivityName {
  static const lectureReport = "讲座报告";
  static const thematicReport = "主题报告";
  static const creation = "三创";
  static const practice = "社会实践";
  static const safetyCiviEdu = "校园安全文明";
  static const cyberSafetyEdu = "安全教育网络教学";
  static const schoolCulture = "校园文化";
  static const thematicEdu = "主题教育";
  static const unknown = "未知";
  static const voluntary = "志愿公益";
  static const blackList = ["补录"];
}
@HiveType(typeId: HiveTypeId.activityType)
enum ActivityType {
  @HiveField(0)
  lecture(ActivityName.lectureReport), // 讲座报告
  @HiveField(1)
  thematicEdu(ActivityName.thematicEdu), // 主题教育
  @HiveField(2)
  creation(ActivityName.creation), // 三创
  @HiveField(3)
  schoolCulture(ActivityName.schoolCulture), // 校园文化
  @HiveField(4)
  practice(ActivityName.practice), // 社会实践
  @HiveField(5)
  voluntary(ActivityName.voluntary), // 志愿公益
  @HiveField(6)
  cyberSafetyEdu(ActivityName.cyberSafetyEdu), // 安全教育网络教学
  @HiveField(7)
  unknown(ActivityName.unknown); // 未知

  final String name;

  const ActivityType(this.name);
}

enum ActivityScoreType {
  thematicReport(ActivityName.thematicReport), // 讲座报告
  creation(ActivityName.creation), // 三创
  schoolCulture(ActivityName.schoolCulture), // 校园文化
  practice(ActivityName.practice), // 社会实践
  voluntary(ActivityName.voluntary), // 志愿公益
  safetyCiviEdu(ActivityName.safetyCiviEdu); // 校园安全文明

  final String name;

  const ActivityScoreType(this.name);
}

/// Don't Change this.
/// Strings from school API
const Map<String, ActivityScoreType> stringToActivityScoreType = {
  '主题报告': ActivityScoreType.thematicReport,
  '社会实践': ActivityScoreType.practice,
  '创新创业创意': ActivityScoreType.creation, // 三创
  '校园文化': ActivityScoreType.schoolCulture,
  '公益志愿': ActivityScoreType.voluntary,
  '校园安全文明': ActivityScoreType.safetyCiviEdu,
};

/// Don't Change this.
/// Strings from school API
const Map<String, ActivityType> stringToActivityType = {
  '讲座报告': ActivityType.lecture,
  '主题教育': ActivityType.thematicEdu,
  '校园文化活动': ActivityType.schoolCulture,
  '创新创业创意': ActivityType.creation, // 三创
  '社会实践': ActivityType.practice,
  '志愿公益': ActivityType.voluntary,
  '安全教育网络教学': ActivityType.cyberSafetyEdu,
  '校园文明': ActivityType.schoolCulture,
};

@HiveType(typeId: HiveTypeId.activity)
class Activity {
  /// Activity id
  @HiveField(0)
  final int id;

  /// Activity category
  @HiveField(1)
  final ActivityType category;

  /// Title
  @HiveField(2)
  final String title;

  @HiveField(3)
  final String realTitle;
  @HiveField(4)
  final List<String> tags;

  /// Date
  @HiveField(5)
  final DateTime ts;

  const Activity(this.id, this.category, this.title, this.ts, this.realTitle, this.tags);

  const Activity.named(
      {required this.id,
      required this.category,
      required this.title,
      required this.ts,
      required this.realTitle,
      required this.tags});

  @override
  String toString() {
    return 'Activity{id: $id, category: $category}';
  }
}

extension ActivityParser on Activity {
  static Activity parse(ScJoinedActivity activity) {
    final titleAndTags = splitTitleAndTags(activity.title);
    return Activity.named(
        id: activity.activityId,
        category: ActivityType.unknown,
        title: activity.title,
        ts: activity.time,
        realTitle: titleAndTags.item1,
        tags: titleAndTags.item2);
  }
}
