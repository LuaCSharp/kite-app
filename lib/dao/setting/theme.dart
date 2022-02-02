import 'dart:ui';

abstract class ThemeSettingDao {
  Color get color;

  set color(Color value);

  bool get isDarkMode;

  set isDarkMode(bool value);
}
