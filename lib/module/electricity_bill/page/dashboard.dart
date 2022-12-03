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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/account.dart';
import '../init.dart';
import '../user_widget/card.dart';
import '../user_widget/chart.dart';
import '../user_widget/rank.dart';
import '../using.dart';

class Dashboard extends StatefulWidget {
  final String selectedRoom;

  const Dashboard({super.key, required this.selectedRoom});

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final service = ElectricityBillInit.electricityService;
  final updateTimeFormatter = DateFormat('MM/dd HH:mm');
  Balance? _balance;
  final _rankViewKey = GlobalKey();
  final _chartKey = GlobalKey();

  final _scrollController = ScrollController();
  final _portraitRefreshController = RefreshController();
  final _landscapeRefreshController = RefreshController();

  RefreshController getCurrentRefreshController(BuildContext ctx) =>
      ctx.isPortrait ? _portraitRefreshController : _landscapeRefreshController;

  Future<List> getRoomList() async {
    String jsonData = await rootBundle.loadString("assets/roomlist.json");
    List list = await jsonDecode(jsonData);
    return list;
  }

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _portraitRefreshController.dispose();
    _landscapeRefreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return context.isPortrait ? buildPortrait(context) : buildLandscape(context);
  }

  Widget buildPortrait(BuildContext context) {
    return SmartRefresher(
      controller: _portraitRefreshController,
      scrollDirection: Axis.vertical,
      onRefresh: _onRefresh,
      header: const ClassicHeader(),
      scrollController: _scrollController,
      child: buildBodyPortrait(context),
    );
  }

  Widget buildLandscape(BuildContext context) {
    return SmartRefresher(
      controller: _landscapeRefreshController,
      scrollDirection: Axis.vertical,
      onRefresh: _onRefresh,
      header: const ClassicHeader(),
      scrollController: _scrollController,
      child: buildBodyLandscape(context),
    ).padAll(20);
  }

  void setRankViewState(void Function(RankViewState state) setter) {
    final state = _rankViewKey.currentState;
    if (state is RankViewState) {
      state.setState(() {
        setter(state);
      });
    }
  }

  void setChartState(void Function(ElectricityChartState state) setter) {
    final state = _chartKey.currentState;
    if (state is ElectricityChartState) {
      state.setState(() {
        setter(state);
      });
    }
  }

  ElectricityChartState? getChartState() {
    final state = _chartKey.currentState;
    if (state is ElectricityChartState) {
      return state;
    }
    return null;
  }

  Future<void> _onRefresh() async {
    final selectedRoom = widget.selectedRoom;
    setState(() {
      _balance = null;
    });
    setChartState((state) {
      state.dailyBill = null;
      state.hourlyBill = null;
    });
    setRankViewState((state) {
      state.curRank = null;
    });
    await Future.wait([
      Future(() async {
        final newBalance = await service.getBalance(selectedRoom);
        setState(() {
          _balance = newBalance;
        });
      }),
      Future(() async {
        final newRank = await service.getRank(selectedRoom);
        setRankViewState((state) {
          state.curRank = newRank;
        });
      }),
      Future(() async {
        final chartState = getChartState();
        if (chartState != null) {
          if (chartState.mode == ElectricityChartMode.daily) {
            final newDailyBill = await service.getDailyBill(selectedRoom);
            setChartState((state) {
              state.dailyBill = newDailyBill;
            });
          } else {
            final newHourlyBill = await service.getHourlyBill(selectedRoom);
            setChartState((state) {
              state.hourlyBill = newHourlyBill;
            });
          }
        }
      })
    ]);
    if (!mounted) return;
    getCurrentRefreshController(context).refreshCompleted();
  }

  Widget buildBodyPortrait(BuildContext ctx) {
    final balance = _balance;
    return [
      const SizedBox(height: 5),
      buildBalanceCard(ctx),
      const SizedBox(height: 5),
      RankView(key: _rankViewKey),
      const SizedBox(height: 25),
      ElectricityChart(key: _chartKey, room: widget.selectedRoom),
      buildUpdateTime(context, balance?.ts).align(at: Alignment.bottomCenter),
    ].column().scrolled().padSymmetric(v: 8, h: 20);
  }

  Widget buildBodyLandscape(BuildContext ctx) {
    final balance = _balance;
    return [
      [
        i18n.elecBillTitle(widget.selectedRoom).text(style: ctx.textTheme.headline1).padFromLTRB(10,0,10,40),
        const SizedBox(height: 5),
        buildUpdateTime(context, balance?.ts).align(at: Alignment.bottomCenter),
        const SizedBox(height: 5),
        buildBalanceCard(ctx),
        const SizedBox(height: 5),
        RankView(key: _rankViewKey)
      ].column().align(at: Alignment.topCenter).expanded(),
      SizedBox(width: 10.w),
      ElectricityChart(key: _chartKey, room: widget.selectedRoom).padV(12.h).expanded(),
      //if (balance == null) Container() else buildUpdateTime(context, balance.ts).align(at: Alignment.bottomCenter)
    ].row(maa: MainAxisAlignment.spaceEvenly).scrolled();
  }

  Widget buildBalanceCard(BuildContext ctx) {
    return buildCard(i18n.elecBillBalance, _buildBalanceCardContent(ctx));
  }

  Widget _buildBalanceCardContent(BuildContext ctx) {
    final balance = _balance;

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            if (balance == null)
              _buildBalanceInfoRowWithPlaceholder(
                  Icons.offline_bolt, i18n.elecBillRemainingPower, const Center(child: CircularProgressIndicator()))
            else
              _buildBalanceInfoRow(
                  Icons.offline_bolt, i18n.elecBillRemainingPower, i18n.powerKwh(balance.power.toStringAsFixed(2))),
            if (balance == null)
              _buildBalanceInfoRowWithPlaceholder(
                  Icons.savings, i18n.elecBillBalance, const Center(child: CircularProgressIndicator()))
            else
              _buildBalanceInfoRow(Icons.savings, i18n.elecBillBalance, '¥${balance.balance.toStringAsFixed(2)}',
                  color: balance.balance < 10 ? Colors.red : null),
          ],
        ));
  }

  Widget _buildBalanceInfoRow(IconData icon, String title, String content, {Color? color}) {
    final style = TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(
            icon,
            color: context.fgColor,
          ),
          const SizedBox(width: 10),
          Text(title, style: style),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(content, style: style),
        ]),
      ],
    );
  }

  Widget _buildBalanceInfoRowWithPlaceholder(IconData icon, String title, Widget placeholder) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(
            icon,
            color: context.fgColor,
          ),
          const SizedBox(width: 10),
          Text(title, style: style),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          LimitedBox(maxWidth: 10, maxHeight: 10, child: placeholder),
        ]),
      ],
    );
  }

  Widget buildUpdateTime(BuildContext ctx, DateTime? time) {
    final outOfDateColor = time != null && time.difference(DateTime.now()).inDays > 1 ? Colors.redAccent : null;
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(Icons.update),
              const SizedBox(width: 10),
              Text(i18n.elecBillUpdateTime, style: TextStyle(color: outOfDateColor)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(time != null ? updateTimeFormatter.format(time.toLocal()) : "..."),
            ]),
          ],
        )).center();
  }
}
