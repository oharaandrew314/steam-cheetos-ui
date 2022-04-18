import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:steamcheetos_flutter/client/dto_utils.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';

class GameState extends ChangeNotifier {

  final Map<String, GameDto> _games = {};

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

  void updateAll(List<GameDto> games) {
    _games.clear();
    for (final game in games) {
      _games[game.id] = game;
    }
    notifyListeners();
  }

  void update(GameDto game) {
    _games[game.id] = game;
    notifyListeners();
  }
}