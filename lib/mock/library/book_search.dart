import 'dart:math';

import 'package:kite/dao/library/book_search.dart';
import 'package:kite/entity/library/book_search.dart';

class BookSearchMock implements BookSearchDao {
  @override
  Future<BookSearchResult> search({
    String keyword = '',
    int rows = 10,
    int page = 1,
    SearchWay searchWay = SearchWay.title,
    SortWay sortWay = SortWay.matchScore,
    SortOrder sortOrder = SortOrder.desc,
  }) async {
    await Future.delayed(const Duration(microseconds: 300));
    var length = 100;
    return BookSearchResult(
        length,
        Random.secure().nextDouble(),
        page,
        length ~/ rows,
        List.generate(
          length,
          (index) {
            var i = index;
            return Book('id$i', 'isbn$i', 'title$i', 'author$i', 'publisher$i', 'pubDate$i', 'callNo$i');
          },
        ));
  }
}
