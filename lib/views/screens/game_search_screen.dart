import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/views/widgets/game_list.dart';
import 'package:steamcheetos_flutter/views/widgets/search_bar.dart';

class GameSearchScreen extends StatefulWidget {
  final Function(GameDto) handlePressGame;
  final List<GameDto> games;

  const GameSearchScreen({required this.handlePressGame, required this.games, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GameSearchScreenState();
}

class _GameSearchScreenState extends State<GameSearchScreen> {
  final _searchController = TextEditingController();
  var _searchTerm = "";

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = extractAllSorted<GameDto>(
        query:  _searchTerm,
        choices: widget.games,
        getter: (game) => game.name,
        cutoff: 85
    ).map((e) => e.choice).toList();

    return Scaffold(
        appBar: AppBar(
            title: SearchBar(
                placeholder: 'Search Games...',
                controller: _searchController,
                autofocus: true
            ),
        ),
        body: Center(
          child: GameList(
              games: results,
              handlePressGame: widget.handlePressGame
          )
        )
    );
  }
}