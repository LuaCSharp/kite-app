import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kite/global/hive_type_id_pool.dart';

part 'timetable.g.dart';

@HiveType(typeId: HiveTypeIdPool.courseItem)
@JsonSerializable()
class Course extends HiveObject {
  static RegExp weekRegex = RegExp(r"(\d{1,2})(:?-(\d{1,2}))?");

  @JsonKey(name: 'kcmc')
  @HiveField(0)
  // 课程名称
  String? courseName;
  @JsonKey(name: 'xqjmc', fromJson: _dayToInt)
  @HiveField(1)
  // 星期
  int? day;
  @JsonKey(name: 'jcs', fromJson: _indexTimeToInt)
  @HiveField(2)
  // 节次
  int? timeIndex;
  @JsonKey(name: 'zcd', fromJson: _weeksToInt)
  @HiveField(3)
  // 周次
  int? week;
  @JsonKey(name: 'cdmc')
  @HiveField(4)
  // 教室
  String? place;
  @JsonKey(name: 'xm', fromJson: _stringToVec, defaultValue: ['空'])
  @HiveField(5)
  // 教师
  List<String>? teacher;
  @JsonKey(name: 'xqmc')
  @HiveField(6)
  // 校区
  String? campus;
  @JsonKey(name: 'xf', fromJson: _stringToDouble)
  @HiveField(7)
  // 学分
  double credit = 0.0;
  @JsonKey(name: 'zxs', fromJson: _stringToInt)
  @HiveField(8)
  // 学时
  int hour = 0;
  @JsonKey(name: 'jxbmc', fromJson: _trimString)
  @HiveField(9)
  // 教学班
  String? dynClassId;
  @JsonKey(name: 'kch')
  @HiveField(10)
  // 课程代码
  String? courseId;

  Course();

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);

  Map<String, dynamic> toJson() => _$CourseToJson(this);

  @override
  String toString() {
    return 'Course{courseName: $courseName, day: $day, timeIndex: $timeIndex, week: $week, place: $place, teacher: $teacher, campus: $campus, credit: $credit, hour: $hour, dynClassId: $dynClassId, courseId: $courseId}';
  }

  static int _transWeek(String weekDay) {
    Map<String, int> weeks = {'星期一': 1, '星期二': 2, '星期三': 3, '星期四': 4, '星期五': 5, '星期六': 6, '星期日': 7};
    return weeks[weekDay] ?? 0;
  }

  static List<int> _expandWeeks(String week) {
    int checkWeekIndex(String? x) {
      if (x == null) {
        return 0;
      } else {
        return int.tryParse(x) ?? 0;
      }
    }

    List<int> weeks = [];
    week.split(',').forEach((week) {
      if (week.contains('-')) {
        var step = 1;
        if (week.endsWith("(单)") || week.endsWith("(双)")) {
          step = 2;
        }
        var range = weekRegex.firstMatch(week)!;
        var weekList = range[0]!.split('-');
        var min = checkWeekIndex(weekList[0]);
        var max = checkWeekIndex(weekList[1]);
        while (min < max + 1) {
          weeks.add(min);
          min += step;
        }
      } else {
        weeks.add(checkWeekIndex(week.replaceAll("周", "")));
      }
    });
    return weeks;
  }

  static List<int> _expandTime(String time) {
    int checkTimeIndex(String? x) {
      if (x == null) {
        return 0;
      } else {
        var result = int.tryParse(x);
        if (result == null) {
          return 0;
        } else {
          return result;
        }
      }
    }

    List<int> indices = [];
    if (time.contains('-')) {
      var result = time.split("-");
      var min = checkTimeIndex(result.first);
      var max = checkTimeIndex(result.last) + 1;
      for (var i = min; i < max; i++) {
        indices.add(i);
      }
    } else {
      indices.add(checkTimeIndex(time));
    }
    return indices;
  }

  static List<String> _splitToList(String s) => s.split(',');

  static int _listToInt(List<int> s) {
    var binaryNumber = 0;
    for (var number in s) {
      binaryNumber |= 1 << number;
    }
    return binaryNumber;
  }

  static int _weeksToInt(String weeks) => _listToInt(_expandWeeks(weeks));

  static int _dayToInt(String days) => _transWeek(days);

  static int _indexTimeToInt(String indexTime) => _listToInt(_expandTime(indexTime));

  static List<String> _stringToVec(String s) => _splitToList(s);

  static double _stringToDouble(String s) => double.tryParse(s) ?? double.nan;

  static int _stringToInt(String s) => int.tryParse(s) ?? 0;

  static String _trimString(String s) => s.trim();
}
