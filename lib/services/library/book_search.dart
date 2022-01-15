import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:kite/entity/library/book_search.dart';
import 'package:kite/services/abstract_service.dart';
import 'package:kite/services/abstract_session.dart';
import 'package:kite/services/library/constants.dart';

class BookSearchService extends AService {
  BookSearchService(ASession session) : super(session);

  static String _searchWayToString(SearchWay sw) {
    return {
      SearchWay.any: '',
      SearchWay.title: 'title',
      SearchWay.titleProper: 'title200a',
      SearchWay.isbn: 'isbn',
      SearchWay.author: 'author',
      SearchWay.subjectWord: 'subject',
      SearchWay.classNo: 'class',
      SearchWay.ctrlNo: 'ctrlno',
      SearchWay.orderNo: 'orderno',
      SearchWay.publisher: 'publisher',
      SearchWay.callNo: 'callno',
    }[sw]!;
  }

  static String _sortWayToString(SortWay sw) {
    return {
      SortWay.matchScore: 'score',
      SortWay.publishDate: 'pubdate_sort',
      SortWay.subject: 'subject_sort',
      SortWay.title: 'title_sort',
      SortWay.author: 'author_sort',
      SortWay.callNo: 'callno_sort',
      SortWay.pinyin: 'pinyin_sort',
      SortWay.loanCount: 'loannum_sort',
      SortWay.renewCount: 'renew_sort',
      SortWay.titleWeight: 'title200Weight',
      SortWay.titleProperWeight: 'title200aWeight',
      SortWay.volume: 'title200h',
    }[sw]!;
  }

  static String _sortOrderToString(SortOrder sw) {
    return {
      SortOrder.asc: 'asc',
      SortOrder.desc: 'desc',
    }[sw]!;
  }

  static Book _parseBook(Bs4Element e) {
    // 获得图书信息
    String getBookInfo(String name, String selector) {
      return e.find(name, selector: selector)!.text.trim();
    }

    var bookCoverImage = e.find('img', class_: 'bookcover_img')!;
    var author = getBookInfo('a', '.author-link');
    var bookId = bookCoverImage.attributes['bookrecno']!;
    var isbn = bookCoverImage.attributes['isbn']!;
    var callNo = getBookInfo('span', '.callnosSpan');
    var publishDate =
        getBookInfo('div', 'div').split('出版日期:')[1].split('\n')[0].trim();

    var publisher = getBookInfo('a', '.publisher-link');
    var title = getBookInfo('a', '.title-link');
    return Book(bookId, isbn, title, author, publisher, publishDate, callNo);
  }

  Future<BookSearchResult> search({
    String keyword = '',
    int rows = 10,
    int page = 1,
    SearchWay searchWay = SearchWay.title,
    SortWay sortWay = SortWay.matchScore,
    SortOrder sortOrder = SortOrder.desc,
  }) async {
    var response = await session.get(
      Constants.searchUrl,
      queryParameters: {
        'q': keyword,
        'searchType': 'standard',
        'isFacet': 'true',
        'view': 'standard',
        'searchWay': _searchWayToString(searchWay),
        'rows': rows.toString(),
        'sortWay': _sortWayToString(sortWay),
        'sortOrder': _sortOrderToString(sortOrder),
        'hasholding': '1',
        'searchWay0': 'marc',
        'logical0': 'AND',
        'page': page.toString(),
      },
    );

    var htmlElement = BeautifulSoup(response.data);

    var currentPage =
        htmlElement.find('b', selector: '.meneame > b')!.text.trim();
    var resultNumAndTime = htmlElement
        .find(
          'div',
          selector: '#search_meta > div:nth-child(1)',
        )!
        .text;
    var resultCount = int.parse(RegExp(r'检索到: (\S*) 条结果')
        .allMatches(resultNumAndTime)
        .first
        .group(1)!
        .replaceAll(',', ''));
    var useTime = double.parse(
        RegExp(r'检索时间: (\S*) 秒').allMatches(resultNumAndTime).first.group(1)!);
    var totalPages = htmlElement
        .find('div', class_: 'meneame')!
        .find('span', class_: 'disabled')!
        .text
        .trim();

    return BookSearchResult(
        resultCount,
        useTime,
        int.parse(currentPage),
        int.parse(totalPages
            .substring(1, totalPages.length - 1)
            .trim()
            .replaceAll(',', '')),
        htmlElement
            .find('table', class_: 'resultTable')!
            .findAll('tr')
            .map((e) => _parseBook(e))
            .toList());
  }
}
