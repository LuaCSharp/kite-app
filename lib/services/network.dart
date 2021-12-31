import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'network.g.dart';

@JsonSerializable()
class CheckStatusResult {
  final int result;
  final int time;

  const CheckStatusResult(this.result, this.time);
  factory CheckStatusResult.fromJson(Map<String, dynamic> json) =>
      _$CheckStatusResultFromJson(json);
  Map<String, dynamic> toJson() => _$CheckStatusResultToJson(this);
}

@JsonSerializable()
class LogoutResult {
  factory LogoutResult.fromJson(Map<String, dynamic> json) =>
      _$LogoutResultFromJson(json);
  Map<String, dynamic> toJson() => _$LogoutResultToJson(this);
}

@JsonSerializable()
class LoginResult {
  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResultToJson(this);
}

class Network {
  static const _indexUrl = 'http://172.16.8.70';
  static const _drcomUrl = _indexUrl + '/drcom';
  static const _loginUrl = _drcomUrl + '/login';
  static const _checkStatusUrl = _drcomUrl + '/chkstatus';
  static const _logoutUrl = _drcomUrl + '/logout';

  static Future<Map<String, dynamic>> _get(String url,
      {Map<String, dynamic>? queryParameters}) async {
    var response = await Dio().get(
      url,
      queryParameters: queryParameters,
      options: Options(
        responseType: ResponseType.plain,
      ),
    );
    var jsonp = response.data.toString();
    return jsonDecode(jsonp.substring(7, jsonp.length - 1));
  }

  static Future<LoginResult> login(String username, String password) async {
    return LoginResult.fromJson(await _get(
      _loginUrl,
      queryParameters: {
        'callback': 'dr1003',
        'DDDDD': username,
        'upass': password,
        '0MKKey': '123456',
        "R1'": '0',
        'R2': '',
        'R3': '0',
        'R6': '0',
        'para': '00',
        'terminal_type': '1',
        'lang': 'zh-cn',
        'jsVersion': '4.1',
      },
    ));
  }

  static Future<CheckStatusResult> checkStatus() async {
    return CheckStatusResult.fromJson(await _get(
      _checkStatusUrl,
      queryParameters: {
        'callback': 'dr1002',
        'jsVersion': '4.X',
        'lang': 'zh',
      },
    ));
  }

  static Future<LogoutResult> logout() async {
    return LogoutResult.fromJson(await _get(
      _logoutUrl,
      queryParameters: {
        'callback': 'dr1002',
        'jsVersion': '4.1.3',
        'lang': 'zh',
      },
    ));
  }
}
