import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:steamcheetos_flutter/client/dtos.dart';

class GamesClient {
  final Uri host;
  final String accessToken;

  GamesClient(this.host, this.accessToken);

  static GamesClient create(String accessToken) => GamesClient(Uri.https("api.steamcheetos.com", ""), accessToken);

  Future<UserDto> getUser() async {
    final resp = await http.get(
        host.resolve('/v1/user'),
        headers: { 'Authorization': 'Bearer $accessToken'}
    );
    
    if (resp.statusCode != 200) throw HttpException(resp.toString());

    final json = jsonDecode(resp.body);
    final avatar = json['avatar'];
    return UserDto(
        name: json['name'],
        avatar: avatar == null ? null : Uri.parse(avatar)
    );
  }

  Future<List<GameDto>> listGames() async {
    final resp = await http.get(
        host.resolve("/v1/games"),
        headers: { 'Authorization': 'Bearer $accessToken'}
    );

    if (resp.statusCode != 200) throw HttpException(resp.toString());

    return (jsonDecode(resp.body) as List)
        .map((i) => _parseGame(i))
        .toList();
  }

  GameDto _parseGame(Map<String, dynamic> json) {
    final displayImage = json['displayImage'];
    final lastUpdated = json['lastUpdated'];

    return GameDto(
      id: json['id'],
      name: json['name'],
      achievementsTotal: json['achievementsTotal'],
      achievementsCurrent: json['achievementsCurrent'],
      displayImage: displayImage == null ? null : Uri.parse(displayImage),
      lastUpdated: lastUpdated == null ? null : DateTime.parse(lastUpdated)
    );
  }
}