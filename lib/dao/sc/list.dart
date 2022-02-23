import 'package:kite/entity/sc/list.dart';

abstract class ScActivityListDao {
  Future<List<Activity>> getActivityList(ActivityType type, int page);

  Future<List<Activity>> query(String queryString);
}
