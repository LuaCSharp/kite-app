import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kite/global/bus.dart';
import 'package:kite/global/storage_pool.dart';
import 'package:kite/service/weather.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:universal_platform/universal_platform.dart';

import '../global/quick_button.dart';
import 'home/background.dart';
import 'home/drawer.dart';
import 'home/greeting.dart';
import 'home/group.dart';
import 'home/item.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _updateWeather() {
    Future.delayed(const Duration(milliseconds: 800), () async {
      final weather = await getCurrentWeather(StoragePool.homeSetting.campus);
      eventBus.emit('onWeatherUpdate', weather);
    });
  }

  void _onHomeRefresh() {
    _refreshController.refreshCompleted(resetFooterState: true);

    eventBus.emit('onHomeRefresh');
  }

  Widget _buildTitleLine(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        child: Center(child: SvgPicture.asset('assets/home/kite.svg', width: 80, height: 80)),
      ),
    );
  }

  List<Widget> buildFunctionWidgets() {
    return [
      const GreetingWidget(),
      const SizedBox(height: 20.0),
      const HomeItemGroup([TimetableItem(), ReportItem()]),
      const SizedBox(height: 20.0),
      const HomeItemGroup([ElectricityItem(), ExpenseItem(), ScoreItem(), LibraryItem(), OfficeItem()]),
      const SizedBox(height: 20.0),
      const HomeItemGroup([
        HomeItem(route: '/game', icon: AssetImage('assets/home/icon_library.png'), title: '小游戏'),
        HomeItem(route: '/wiki', icon: AssetImage('assets/home/icon_library.png'), title: 'Wiki'),
        HomeItem(route: '/market', icon: AssetImage('assets/home/icon_library.png'), title: '二手书广场'),
      ]),
      const SizedBox(height: 40),
    ];
  }

  Widget _buildBody(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    final items = buildFunctionWidgets();

    return Stack(
      children: [
        const HomeBackground(),
        SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          controller: _refreshController,
          child: CustomScrollView(slivers: [
            SliverAppBar(
              // AppBar
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(title: _buildTitleLine(context)),
              expandedHeight: windowSize.height * 0.6,
              backgroundColor: Colors.transparent,
              centerTitle: false,
              elevation: 0,
              pinned: false,
            ),
            SliverList(
              // Functions
              delegate: SliverChildBuilderDelegate(
                (_, index) => Padding(padding: const EdgeInsets.only(left: 10, right: 10), child: items[index]),
                childCount: items.length,
              ),
            ),
          ]),
          onRefresh: _onHomeRefresh,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      QuickButton.init(context);
    }
    _updateWeather();

    return Scaffold(
      key: _scaffoldKey,
      body: _buildBody(context),
      drawer: const KiteDrawer(),
    );
  }
}
