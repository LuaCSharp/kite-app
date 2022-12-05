import 'package:check_vpn_connection/check_vpn_connection.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import '../service/network.dart';
import '../using.dart';

class ConnectedBlock extends StatefulWidget {
  const ConnectedBlock({super.key});

  @override
  State<ConnectedBlock> createState() => _ConnectedBlockState();
}

class _ConnectedBlockState extends State<ConnectedBlock> {
  @override
  Widget build(BuildContext context) {
    return buildBody(context).column(maa: MainAxisAlignment.center,caa: CrossAxisAlignment.center);
  }

  List<Widget> buildBody(BuildContext context) {
    final style = context.textTheme.bodyText1;

    late Widget buildConnectedByProxy = Text(
        '${i18n.connectivityConnectedByVpn}\n'
        '${i18n.address}：${Kv.network.proxy}',
        textAlign: TextAlign.center,
        style: style);

    Widget buildConnectedByVpnBlock() =>
        Text(i18n.connectivityConnectedByVpn, textAlign: TextAlign.center, style: style);
    Widget buildConnectedByWlanBlock() {
      return FutureBuilder(
        future: Network.checkStatus(),
        builder: (context, snapshot) {
          String ip = i18n.fetching;
          String studentId = i18n.fetching;
          if (snapshot.connectionState == ConnectionState.done) {
            final data = snapshot.data;
            if (data is CheckStatusResult) {
              ip = data.ip;
              studentId = data.uid ?? i18n.notLoggedIn;
            } else {
              ip = i18n.unknown;
              studentId = i18n.unknown;
            }
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(i18n.connectivityConnectedByWlan, style: style),
              const SizedBox(height: 10),
              Text('${i18n.studentID}: $studentId'),
              Text('${i18n.address}: $ip'),
            ],
          );
        },
      );
    }

    if (Kv.network.useProxy) {
      return [buildConnectedByProxy];
    }
    return [
      FutureBuilder(
        future: CheckVpnConnection.isVpnActive(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final isVpnActive = snapshot.data!;
            if (false == isVpnActive) {
              return buildConnectedByWlanBlock();
            }
          }
          return buildConnectedByVpnBlock();
        },
      )
    ];
  }
}
