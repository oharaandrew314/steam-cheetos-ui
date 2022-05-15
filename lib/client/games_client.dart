import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';

class GamesClient {
  final Uri host;
  final String accessToken;

  GamesClient(this.host, this.accessToken);
  final log = Logger();

  static GamesClient create(String accessToken) => GamesClient(Uri.https("api.steamcheetos.com", ""), accessToken);

  Future<UserDto> getUser() async {
    final resp = await http.get(
        host.resolve('/v1/user'),
        headers: { 'Authorization': 'Bearer $accessToken'}
    );
    
    if (resp.statusCode != 200) throw HttpException("${resp.statusCode}: ${resp.body}");

    final json = jsonDecode(resp.body);
    return _parseUser(json);
  }

  Future<List<GameDto>> listGames() async {
    final resp = await http.get(
        host.resolve("/v1/games"),
        headers: { 'Authorization': 'Bearer $accessToken'}
    );

    if (resp.statusCode != 200) throw HttpException("${resp.statusCode}: ${resp.body}");

    return (jsonDecode(resp.body) as List)
        .map((i) => _parseGame(i))
        .toList();
  }

  Future<List<GameDto>> refreshGames() async {
    log.i("Refresh Games");
    final resp = await http.post(
        host.resolve("/v1/games"),
        headers: { 'Authorization': 'Bearer $accessToken'}
    );

    if (resp.statusCode != 200) throw HttpException("${resp.statusCode}: ${resp.body}");

    return (jsonDecode(resp.body) as List)
        .map((i) => _parseGame(i))
        .toList();
  }

  Future<List<AchievementDtoV1>> listAchievements(String gameId) async {
    log.i("Get Achievements for game $gameId");
    final resp = await http.get(
        host.resolve("/v1/games/$gameId/achievements"),
        headers: { 'Authorization': 'Bearer $accessToken'}
    );

    if (resp.statusCode != 200) throw HttpException("${resp.statusCode}: ${resp.body}");

    return (jsonDecode(resp.body) as List)
        .map((i) => _parseAchievement(i))
        .toList();
  }

  Future<List<AchievementDtoV1>> refreshAchievements(String gameId) async {
    log.i("Refresh Achievements for game $gameId");
    final resp = await http.post(
        host.resolve("/v1/games/$gameId/achievements"),
        headers: { 'Authorization': 'Bearer $accessToken'}
    );

    if (resp.statusCode != 200) throw HttpException("${resp.statusCode}: ${resp.body}");

    return (jsonDecode(resp.body) as List)
        .map((i) => _parseAchievement(i))
        .toList();
  }

  Future<List<UserDto>> listFriends() async {
    final resp = await http.get(
        host.resolve("/v1/friends"),
        headers: { 'Authorization': 'Bearer $accessToken'}
    );

    if (resp.statusCode != 200) throw HttpException("${resp.statusCode}: ${resp.body}");

    return (jsonDecode(resp.body) as List)
        .map((i) => _parseUser(i))
        .toList();
  }

  Future<List<AchievementStatusDto>> getFriendAchievements(String gameId, String friendId) async {
      final resp = await http.get(
          host.resolve("/v1/games/$gameId/friends/$friendId/achievements"),
          headers: { 'Authorization': 'Bearer $accessToken'}
      );

      if (resp.statusCode != 200) throw HttpException("${resp.statusCode}: ${resp.body}");

      return (jsonDecode(resp.body) as List)
          .map((i) => _parseAchievementStatus(i))
          .toList();
  }

  Future<GameDto?> updateGame(String gameId, bool favourite) async {
      final resp = await http.put(
          host.resolve("/v1/games/$gameId"),
          body: jsonEncode({ 'favourite': favourite }),
          headers: { 'Authorization': 'Bearer $accessToken'}
      );

      if (resp.statusCode == 404) return null;
      if (resp.statusCode != 200) throw HttpException("${resp.statusCode}: ${resp.body}");

      return _parseGame(jsonDecode(resp.body));
  }

  Future<AchievementDtoV1?> updateAchievement(String gameId, String achievementId, bool favourite) async {
    final resp = await http.put(
        host.resolve("/v1/games/$gameId/achievements/$achievementId"),
        body: jsonEncode({ 'favourite': favourite }),
        headers: { 'Authorization': 'Bearer $accessToken'}
    );

    if (resp.statusCode == 404) return null;
    if (resp.statusCode != 200) throw HttpException("${resp.statusCode}: ${resp.body}");

    return _parseAchievement(jsonDecode(resp.body));
  }
}

// dto mapping

UserDto _parseUser(Map<String, dynamic> json) {
  final avatar = json['avatar'];
  return UserDto(
      id: json['id'],
      name: json['name'],
      avatar: avatar == null ? null : Uri.parse(avatar)
  );
}

AchievementDtoV1 _parseAchievement(Map<String, dynamic> json) {
  final unlockedOn = json['unlockedOn'] as String?;

  return AchievementDtoV1(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      hidden: json['hidden'],
      iconLocked: Uri.parse(json['iconLocked']),
      iconUnlocked: Uri.parse(json['iconUnlocked']),
      unlockedOn: unlockedOn == null ? null : DateTime.parse(unlockedOn),
      unlocked: json['unlocked']
  );
}

GameDto _parseGame(Map<String, dynamic> json) {
  return GameDto(
    id: json['id'],
    name: json['name'],
    achievementsTotal: json['achievementsTotal'],
    achievementsCurrent: json['achievementsCurrent'],
    displayImage: Uri.parse(json['displayImage']),
    achievementsExpire: DateTime.parse(json['achievementsExpire']),
    favourite: json['favourite']
  );
}

AchievementStatusDto _parseAchievementStatus(Map<String, dynamic> json) {
  final unlockedOn = json['unlockedOn'] as String?;

  return AchievementStatusDto(
      id: json['id'],
      unlockedOn: unlockedOn == null ? null : DateTime.parse(unlockedOn),
      unlocked: json['unlocked']
  );
}