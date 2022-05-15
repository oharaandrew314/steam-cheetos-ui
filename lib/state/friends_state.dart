import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:steamcheetos_flutter/app_state.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';

class FriendsState extends ChangeNotifier {

  final _log = Logger();
  List<UserDto> _friends = [];
  bool _loading = false;

  bool get loading => _loading;
  UnmodifiableListView<UserDto> get friends {
    final friends = _friends.toList();
    friends.sort((f1, f2) => f1.name.compareTo(f2.name));
    return UnmodifiableListView(friends);
  }

  Future<GamesClient?> _getClient() async {
    final state = await AppState.getInstance();
    final token = state.getAccessToken();

    return token == null ? null : GamesClient.create(token);
  }

  void refresh() async {
    _loading = true;
    notifyListeners();
    _log.i("Loading friends...");

    final client = await _getClient();
    if (client != null) {
      _friends = await client.listFriends();
    }
    _loading = false;
    notifyListeners();
    _log.i("Loaded ${_friends.length} friends");
  }
}