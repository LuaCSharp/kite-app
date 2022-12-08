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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rettulf/rettulf.dart';

import '../../module/timetable/init.dart';
import '../../module/timetable/using.dart';

enum ConnectivityStatus {
  none,
  connecting,
  connected,
  disconnected;
}

class ConnectivityChecker extends StatefulWidget {
  final double iconSize;
  final String? initialDesc;
  final VoidCallback onConnected;
  final Future<bool> Function() check;

  const ConnectivityChecker({
    super.key,
    this.iconSize = 120,
    this.initialDesc,
    required this.onConnected,
    required this.check,
  });

  @override
  State<ConnectivityChecker> createState() => _ConnectivityCheckerState();
}

const _type2Icon = {
  ConnectivityResult.bluetooth: Icons.bluetooth,
  ConnectivityResult.wifi: Icons.wifi,
  ConnectivityResult.ethernet: Icons.lan,
  ConnectivityResult.mobile: Icons.signal_cellular_alt,
  ConnectivityResult.none: Icons.signal_wifi_statusbar_null_outlined,
  ConnectivityResult.vpn: Icons.vpn_key,
};

class _ConnectivityCheckerState extends State<ConnectivityChecker> {
  final service = TimetableInit.network;

  ConnectivityStatus status = ConnectivityStatus.none;
  ConnectivityResult? connectionType;
  late Timer networkChecker;

  @override
  void initState() {
    super.initState();
    Future(() => Connectivity().checkConnectivity()).then((type) {
      if (connectionType != type) {
        if (!mounted) return;
        setState(() {
          connectionType = type;
        });
      }
    });
    networkChecker = Timer.periodic(const Duration(milliseconds: 500), (Timer t) async {
      final type = await Connectivity().checkConnectivity();
      if (connectionType != type) {
        if (!mounted) return;
        setState(() {
          connectionType = type;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return [
      buildIndicatorArea(context).animatedSwitched(),
      AnimatedSize(
        duration: const Duration(milliseconds: 500),
        child: buildText(context).animatedSwitched(),
      ),
      buildButton(context),
    ].column(maa: MainAxisAlignment.spaceAround, caa: CrossAxisAlignment.center).center().padAll(20);
  }

  void startCheck() {
    setState(() {
      networkChecker.cancel();
      status = ConnectivityStatus.connecting;
    });
    Future.wait([
      widget.check(),
      Future.delayed(const Duration(milliseconds: 800)),
    ]).then((value) {
      if (!mounted) return;
      final bool connected = value[0];
      setState(() {
        if (connected) {
          status = ConnectivityStatus.connected;
        } else {
          status = ConnectivityStatus.disconnected;
        }
      });
    }).onError((error, stackTrace) {
      setState(() {
        status = ConnectivityStatus.disconnected;
      });
    });
  }

  Widget buildText(BuildContext ctx) {
    final s = ctx.textTheme.titleLarge;
    final String tip;
    switch (status) {
      case ConnectivityStatus.none:
        tip = widget.initialDesc ?? i18n.connectivityCheckerStatusNone;
        break;
      case ConnectivityStatus.connecting:
        tip = i18n.connectivityCheckerStatusConnecting;
        break;
      case ConnectivityStatus.connected:
        tip = i18n.connectivityCheckerStatusConnected;
        break;
      case ConnectivityStatus.disconnected:
        tip = i18n.connectivityCheckerStatusDisconnected;
        break;
    }
    return tip.text(key: ValueKey(tip), style: s);
  }

  Widget buildButton(BuildContext ctx) {
    final String tip;
    VoidCallback? onTap;
    switch (status) {
      case ConnectivityStatus.none:
        tip = i18n.connectivityCheckerNoneBtn;
        onTap = startCheck;
        break;
      case ConnectivityStatus.connecting:
        tip = i18n.connectivityCheckerConnectingBtn;
        break;
      case ConnectivityStatus.connected:
        tip = i18n.connectivityCheckerConnectedBtn;
        onTap = widget.onConnected;
        break;
      case ConnectivityStatus.disconnected:
        tip = i18n.connectivityCheckerDisconnectedBtn;
        onTap = startCheck;
        break;
    }
    return tip.text(key: ValueKey(tip)).cupertinoButton(onPressed: onTap);
  }

  Widget buildIndicatorArea(BuildContext ctx) {
    switch (status) {
      case ConnectivityStatus.none:
        return buildCurrentConnectionType(ctx);
      case ConnectivityStatus.connecting:
        return Placeholders.loading(
            size: widget.iconSize / 2,
            fix: (w) =>
                w.padAll(30).sized(width: widget.iconSize, height: widget.iconSize, key: const ValueKey("Waiting")));
      case ConnectivityStatus.connected:
        return buildIcon(ctx, Icons.check_rounded);
      case ConnectivityStatus.disconnected:
        return buildIcon(ctx, Icons.public_off_rounded);
    }
  }

  Widget buildIcon(BuildContext ctx, IconData icon, [Key? key]) {
    key ??= ValueKey(icon);
    return Icon(icon, size: widget.iconSize, color: ctx.darkSafeThemeColor)
        .sized(width: widget.iconSize, height: widget.iconSize, key: key);
  }

  Widget buildCurrentConnectionType(BuildContext ctx) {
    final type = connectionType;
    return buildIcon(ctx, _type2Icon[type] ?? Icons.signal_wifi_statusbar_null_outlined);
  }

  @override
  void dispose() {
    super.dispose();
    networkChecker.cancel();
  }
}
