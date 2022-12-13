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
import 'package:auto_animated/auto_animated.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/application.dart';
import '../init.dart';
import '../user_widget/application.dart';
import '../using.dart';

// 本科生常用功能列表
const Set<String> _commonUsed = <String>{
  '121',
  '011',
  '047',
  '123',
  '124',
  '024',
  '125',
  '165',
  '075',
  '202',
  '023',
  '067',
  '059'
};

class ApplicationList extends StatefulWidget {
  final ValueNotifier<bool> $enableFilter;

  const ApplicationList({super.key, required this.$enableFilter});

  @override
  State<ApplicationList> createState() => _ApplicationListState();
}

class _ApplicationListState extends State<ApplicationList> with AdaptivePageProtocol {
  final service = ApplicationInit.applicationService;

  // in descending order
  List<ApplicationMeta> _allDescending = [];
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _fetchMetaList().then((value) {
      if (value != null) {
        if (!mounted) return;
        value.sortBy<num>((e) => -e.count); // descending
        setState(() {
          _allDescending = value;
          _lastError = null;
        });
      }
    }).onError((error, stackTrace) {
      if (!mounted) return;
      setState(() {
        _lastError = error.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (context.isPortrait) {
      return buildPortrait(context);
    } else {
      return buildLandscape(context);
    }
  }

  Widget buildPortrait(BuildContext context) {
    final lastError = _lastError;
    if (lastError != null) {
      return lastError.text().center();
    } else if (_allDescending.isNotEmpty) {
      return buildListPortrait(_allDescending);
    } else {
      return Placeholders.loading();
    }
  }

  Widget buildBodyPortrait() {
    final lastError = _lastError;
    if (lastError != null) {
      return lastError.text().center();
    } else if (_allDescending.isNotEmpty) {
      return buildListPortrait(_allDescending);
    } else {
      return Placeholders.loading();
    }
  }

  List<Widget> buildApplications(List<ApplicationMeta> all, bool enableFilter) {
    return all
        .where((element) => !enableFilter || _commonUsed.contains(element.id))
        .mapIndexed((i, e) => ApplicationTile(meta: e, isHot: i < 3))
        .toList();
  }

  Widget buildListPortrait(List<ApplicationMeta> list) {
    return widget.$enableFilter <<
        (ctx, v, _) {
          final items = buildApplications(list, v);
          return LiveList(
            showItemInterval: const Duration(milliseconds: 40),
            itemCount: items.length,
            itemBuilder: (ctx, index, animation) => items[index].aliveWith(animation),
          );
        };
  }

  Widget buildLandscape(BuildContext context) {
    final lastError = _lastError;
    if (lastError != null) {
      return lastError.text().center();
    } else if (_allDescending.isNotEmpty) {
      return AdaptiveNavigation(child: buildListLandscape(_allDescending));
    } else {
      return Placeholders.loading();
    }
  }

  Widget buildListLandscape(List<ApplicationMeta> list) {
    return widget.$enableFilter <<
        (ctx, v, _) {
          final items = buildApplications(list, v);
          return LiveGrid.options(
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              mainAxisExtent: 70,
            ),
            options: kiteLiveOptions,
            itemBuilder: (ctx, index, animation) => items[index].aliveWith(animation),
          );
        };
  }

  Future<List<ApplicationMeta>?> _fetchMetaList() async {
    final oaCredential = Auth.oaCredential;
    if (oaCredential == null) return null;
    if (!ApplicationInit.session.isLogin) {
      await ApplicationInit.session.login(
        username: oaCredential.account,
        password: oaCredential.password,
      );
    }
    return await service.getApplicationMetas();
  }
}
