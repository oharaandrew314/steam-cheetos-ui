import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:steamcheetos_flutter/app_state.dart';
import 'package:steamcheetos_flutter/client/dto_utils.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';

class GameState extends ChangeNotifier {

  final Map<String, GameDto> _games = {};
  bool _loading = false;

  Future<GamesClient?> _getClient() async {
    final state = await AppState.getInstance();
    final token = state.getAccessToken();

    return token == null ? null : GamesClient.create(token);
  }

  bool get loading => _loading;

  UnmodifiableListView<GameDto> get all => UnmodifiableListView(_games.values);

  UnmodifiableListView<GameDto> get completed {
    final results = _games.values.where((game) => game.isCompleted()).toList();
    results.sort(compareGameName());
    return UnmodifiableListView(results);
  }

  UnmodifiableListView<GameDto> get notCompleted {
    final results = _games.values.where((game) => game.isInProgress()).toList();
    results.sort(compareGameCompletionDesc());
    return UnmodifiableListView(results);
  }

  UnmodifiableListView<GameDto> get unSynced => UnmodifiableListView(_games.values.where((game) => !game.hasLoadedAchievements()));

  UnmodifiableListView<GameDto> get favourites {
    final results = _games.values.where((game) => game.favourite).toList();
    results.sort(compareGameName());
    return UnmodifiableListView(results);
  }

  GameDto? game(String id) => _games[id];

  void refresh({ bool hard = false}) async {
    _loading = true;
    notifyListeners();

    final client = await _getClient();
    if (client != null) {
      final games = await (hard ? client.refreshGames() : client.listGames());
      _games.clear();
      for (final game in games) {
        _games[game.id] = game;
      }
    }

    _loading = false;
    notifyListeners();
  }

  void setFavourite(String gameId, bool favourite) async {
    final client = await _getClient();
    if (client == null) return;

    final updated = await client.updateGame(gameId, favourite);
    if (updated == null) return;

    _games[gameId] = updated;
    notifyListeners();
  }
}