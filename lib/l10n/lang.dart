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
import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:kite/storage/init.dart';

Locale buildLocaleFromJson(Map<String, dynamic> json) {
  return Locale.fromSubtags(
    languageCode: json['languageCode'],
    scriptCode: json['scriptCode'],
    countryCode: json['countryCode'],
  );
}

extension LocaleToJson on Locale {
  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'scriptCode': scriptCode,
      'countryCode': countryCode,
    };
  }
}

abstract class _RegionalFormatter {
  DateFormat get dateT;

  DateFormat get ymT;

  DateFormat get dateN;

  DateFormat get fullN;
}

///
/// `Lang` provides a list of all languages Kite supports as well as a da
class Lang {
  Lang._();

  static const zh = "zh";
  static const zhTw = "zh_TW";
  static const tw = "TW";
  static const en = "en";

  static const zhLocale = Locale.fromSubtags(languageCode: "zh");
  static const zhTwLocale = Locale.fromSubtags(languageCode: "zh", scriptCode: "Hant", countryCode: "TW");
  static const enLocale = Locale.fromSubtags(languageCode: "en");
  static final zhFormatter = _ZhFormatter();
  static final zhTwFormatter = _ZhTwFormatter();
  static final enFormatter = _EnFormatter();
  static const zhCode = 1;
  static const zhTwCode = 2;
  static const enCode = 3;

  static final timef = DateFormat("H:mm:ss");

  static int? toCode(String lang) {
    switch (lang) {
      case zh:
        return zhCode;
      case zhTw:
        return zhTwCode;
      case en:
        return enCode;
    }
    return null;
  }

  static _RegionalFormatter _getFormatterFrom(String lang, String? country) {
    if (lang == zh) {
      if (country == null) {
        return zhFormatter;
      } else if (country == tw) {
        return zhTwFormatter;
      }
    } else if (lang == en) {
      return enFormatter;
    }
    return zhFormatter;
  }

  static DateFormat dateT(String lang, String? country) => _getFormatterFrom(lang, country).dateT;

  static DateFormat dateN(String lang, String? country) => _getFormatterFrom(lang, country).dateN;

  static DateFormat ymT(String lang, String? country) => _getFormatterFrom(lang, country).ymT;

  static DateFormat fullN(String lang, String? country) => _getFormatterFrom(lang, country).fullN;

  static const supports = [
    enLocale, // generic English 'en'
    zhLocale, // generic Chinese 'zh'
    zhTwLocale, // generic traditional Chinese 'zh_Hant'
  ];

  static Locale redirectLocale(Locale old) {
    if (supports.contains(old)) {
      return old;
    }
    if (old.languageCode == zh) {
      if (old.countryCode == tw || old.scriptCode == "Hant") {
        return zhTwLocale;
      } else {
        return zhLocale;
      }
    } else {
      return enLocale;
    }
  }

  static setCurrentLocale(Locale cur) {
    Kv.pref.locale = redirectLocale(cur);
  }

  static Locale getOrSetCurrentLocale(Locale fallback) {
    var cur = Kv.pref.locale;
    if (cur == null) {
      var redirected = redirectLocale(fallback);
      Kv.pref.locale = redirected;
      return redirected;
    } else {
      return cur;
    }
  }

  static setCurrentLocaleIfAbsent(Locale cur) {
    Kv.pref.locale ??= redirectLocale(cur);
  }
}

class _ZhFormatter implements _RegionalFormatter {
  @override
  final dateT = DateFormat("yyyy年M月d日 EEEE", "zh_CN");
  @override
  final ymT = DateFormat("yyyy年M月", "zh_CN");
  @override
  final dateN = DateFormat("yyyy-M-d", "zh_CN");
  @override
  final fullN = DateFormat("yyyy-MM-dd H:mm:ss", "zh_CN");
}

class _ZhTwFormatter implements _RegionalFormatter {
  @override
  final dateT = DateFormat("yyyy年M月d日 EEEE", "zh_TW");
  @override
  final ymT = DateFormat("yyyy年M月", "zh_TW");
  @override
  final dateN = DateFormat("yyyy-M-d", "zh_TW");
  @override
  final fullN = DateFormat("yyyy-MM-dd H:mm:ss", "zh_TW");
}

class _EnFormatter implements _RegionalFormatter {
  @override
  final dateT = DateFormat("EEEE, MMMM d, yyyy", "en_US");
  @override
  final ymT = DateFormat("MMMM, yyyy", "en_US");
  @override
  final dateN = DateFormat("M-d-yyyy", "en_US");
  @override
  final fullN = DateFormat("MM-dd-yyyy H:mm:ss", "en_US");
}
