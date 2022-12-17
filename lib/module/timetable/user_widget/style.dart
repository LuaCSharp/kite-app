import 'package:flutter/widgets.dart';

import '../events.dart';
import '../init.dart';
import '../using.dart';

class TimetableStyleData {
  final List<ColorPair> colors;
  final bool useNewUI;

  const TimetableStyleData(this.colors, this.useNewUI);

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return other is TimetableStyleData &&
        runtimeType == other.runtimeType &&
        colors == other.colors &&
        useNewUI == other.useNewUI;
  }
}

class TimetableStyle extends InheritedWidget {
  final TimetableStyleData data;

  const TimetableStyle({
    super.key,
    required this.data,
    required super.child,
  });

  static TimetableStyleData of(BuildContext context) {
    final TimetableStyle? result = context.dependOnInheritedWidgetOfExactType<TimetableStyle>();
    assert(result != null, 'No TimetablePalette found in context');
    return result!.data;
  }

  @override
  bool updateShouldNotify(TimetableStyle oldWidget) {
    return data != oldWidget.data;
  }
}

class TimetableStyleProv extends StatefulWidget {
  final Widget child;

  const TimetableStyleProv({super.key, required this.child});

  @override
  TimetableStyleProvState createState() => TimetableStyleProvState();
}

class TimetableStyleProvState extends State<TimetableStyleProv> {
  final storage = TimetableInit.timetableStorage;

  @override
  void initState() {
    super.initState();
    eventBus.on<TimetableStyleChangeEvent>().listen((event) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return TimetableStyle(
      data: TimetableStyleData(
        storage.useOldSchoolColors == true ? CourseColor.oldSchool : CourseColor.v1_5,
        storage.useNewUI ?? false,
      ),
      child: widget.child,
    );
  }
}
