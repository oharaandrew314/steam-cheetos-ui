import 'dart:io';

import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logger/logger.dart';

class AuthManager {
  final Uri host;
  final log = Logger();

  AuthManager(this.host);

  static AuthManager getDefault() => AuthManager(Uri.https("api.steamcheetos.com", ""));

  Future<Uri> getLoginUri(Uri callbackUri) async {
    final resp = await http.get(host.resolve("/v1/auth/login?redirect_uri=$callbackUri"));
    
    switch(resp.statusCode) {
      case 200: return Uri.parse(resp.body);
      default: throw HttpException(resp.toString());
    }
  }

  Future<String> doLogin() async {
    final redirectUri = kIsWeb ? Uri.base.resolve("auth.html") : Uri.parse("steamcheetos://auth");
    final loginUri = await getLoginUri(redirectUri);
    // final loginUri = Uri.https(
    //     "steamcommunity.com",
    //     "/openid/login",
    //     {
    //       "openid.ns": "http://specs.openid.net/auth/2.0",
    //       "openid.claimed_id": "http://specs.openid.net/auth/2.0/identifier_select",
    //       "openid.identity": "http://specs.openid.net/auth/2.0/identifier_select",
    //       "openid.return_to": redirectUri.toString(),
    //       "openid.realm": redirectUri.toString(),
    //       "openid.mode": "checkid_setup"
    //     }
    // );
    log.d('login uri: $loginUri');

    final result = await FlutterWebAuth.authenticate(url: loginUri.toString(), callbackUrlScheme: redirectUri.scheme);
    final token = Uri.parse(result).queryParameters["token"]!;
    log.d('token: $token');
    return token;
  }
}