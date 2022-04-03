import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:steamcheetos_flutter/client/dtos.dart';

class CheetosClient {

  final Uri host;

  CheetosClient(this.host);

  Future<Uri> getLoginUri(Uri callbackUri) async {
    final resp = await http.get(host.resolve("/v1/auth/login?redirect_uri=$callbackUri"));
    
    switch(resp.statusCode) {
      case 200: return Uri.parse(resp.body);
      default: throw HttpException(resp.toString());
    }
  }

  Future<UserDto> getUser(String token) async {
    final resp = await http.get(
        host.resolve('/v1/user'),
        headers: { 'Authorization': 'Bearer $token'}
    );
    
    if (resp.statusCode != 200) throw HttpException(resp.toString());

    final json = jsonDecode(resp.body);
    return UserDto(
        name: json['name'],
        avatar: Uri.parse(json['avatar'])
    );
  }
}