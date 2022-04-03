import 'dart:io';

import 'package:http/http.dart' as http;

class AuthClient {
  final Uri host;

  AuthClient(this.host);

  static AuthClient getDefault() => AuthClient(Uri.https("api.steamcheetos.com", ""));

  Future<Uri> getLoginUri(Uri callbackUri) async {
    final resp = await http.get(host.resolve("/v1/auth/login?redirect_uri=$callbackUri"));
    
    switch(resp.statusCode) {
      case 200: return Uri.parse(resp.body);
      default: throw HttpException(resp.toString());
    }
  }
}