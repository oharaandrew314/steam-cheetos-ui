
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:steamcheetos_flutter/app_state.dart';
import 'package:steamcheetos_flutter/client/dto_utils.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';

class AchievementState extends ChangeNotifier {

  final Map<String, List<AchievementDtoV1>> _achievements = {};
  final Map<String, List<AchievementStatusDto>> _friends = {};
  final List<String> _loading = [];

  Future<GamesClient?> _getClient() async {
    final state = await AppState.getInstance();
    final token = state.getAccessToken();

    return token == null ? null : GamesClient.create(token);
  }

  UnmodifiableListView<AchievementDtoV1> achievements(String gameId, { String? term, bool? unlocked}) {
    var achievements = _achievements[gameId] ?? [];

    if (unlocked != null) {
      achievements = achievements.where((e) => e.unlocked == unlocked).toList();
      achievements.sort(compareAchievementUnlockedOn());
    }

    if (term != null && term.isNotEmpty) {
      achievements = extractAllSorted<AchievementDtoV1>(
          query: term,
          choices: achievements,
          getter: (a) => '${a.name} ${a.description}',
          cutoff: 60
      ).map((e) => e.choice).toList();
    }

    return UnmodifiableListView(achievements);
  }

  UnmodifiableListView<AchievementComparisonDto> compareWithFriend(String gameId, String friendId) {
    final achievements = _achievements[gameId] ?? [];
    achievements.sort(compareAchievementUnlockedOn());

    final friendStatuses = _friends["$friendId-$gameId"] ?? [];
    final friendStatusByAchievementId = { for (var e in (friendStatuses)) e.id : e };

    final results = achievements.reversed.map((achievement) {
      final friendStatus = friendStatusByAchievementId[achievement.id] ?? AchievementStatusDto(
          id: achievement.id,
          unlocked: false,
          unlockedOn: null
      );
      return AchievementComparisonDto(achievement, friendStatus);
    });

    return UnmodifiableListView(results);
  }

  void loadFriend(String friendId, String gameId) async {
    final uid = "$friendId-$gameId";
    // _loading.add(gameId);
    notifyListeners();

    final client = await _getClient();
    if (client != null) {
      _friends[uid] = await client.getFriendAchievements(gameId, friendId);
    }

    // _loading.remove(gameId);
    notifyListeners();
  }

  void load(String gameId, { bool hard = false}) async {
    _loading.add(gameId);
    notifyListeners();

    final client = await _getClient();
    if (client != null) {
      _achievements[gameId] = await (hard ? client.refreshAchievements(gameId) : client.listAchievements(gameId));
    }
    _loading.remove(gameId);
    notifyListeners();
  }

  bool isLoading(String gameId) => _loading.contains(gameId);
}

class AchievementComparisonDto {
  final AchievementDtoV1 achievement;
  final AchievementStatusDto friendStatus;

  const AchievementComparisonDto(this.achievement, this.friendStatus);
}