import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/views/screens/achievements_screen.dart';
import 'package:steamcheetos_flutter/views/screens/game_search_screen.dart';
import 'package:steamcheetos_flutter/views/widgets/game_list.dart';
import 'package:steamcheetos_flutter/views/widgets/user.dart';

class GamesScreen extends StatefulWidget {

  final GamesClient client;
  final UserDto user;

  const GamesScreen({required this.client, required this.user, Key? key}) : super(key: key);

  @override
  State<GamesScreen> createState() => _GamesScreenState();

  static Route createRoute(UserDto user, GamesClient client) => PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GamesScreen(
      user: user,
      client: client,
    ),
  );
}

class _GamesScreenState extends State<GamesScreen> {
  List<GameDto> _games = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future _loadGames({bool hard = false}) async {
    setState(() {
      _loading = true;
    });

    final games = await (hard ? widget.client.refreshGames() : widget.client.listGames());
    setState(() {
      _games = games;
      _loading = false;
    });
  }

  void _handlePressGame(BuildContext context, GameDto game) {
    Navigator.push(context, AchievementsScreen.createRoute(widget.client, widget.user, game));
  }

  void _handlePressSearch(BuildContext context) {
    final route = PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => GameSearchScreen(
            handlePressGame: (game) => Navigator.pushReplacement(context, AchievementsScreen.createRoute(widget.client, widget.user, game)),
            games: _games
        )
    );
    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    final completed = _games.where((game) => game.isCompleted()).toList();
    completed.sort(compareGameName());

    final notCompleted = _games.where((game) => !game.isCompleted()).toList();
    notCompleted.sort(compareGameCompletionDesc());

    final scaffold =  Scaffold(
      appBar: AppBar(
          title: const Text("Steam Cheetos"),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _handlePressSearch(context)
            ),
            UserMenu(user: widget.user)
          ],
        bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.clear)),
              Tab(icon: Icon(Icons.check))
            ]
        )
      ),
      body: Center(
        child: TabBarView(
          children: [
            DeclarativeRefreshIndicator(
              child: GameList(games: notCompleted, handlePressGame: (game) => _handlePressGame(context, game)),
              refreshing: _loading,
              onRefresh: () => _loadGames(hard: true)
            ),
            DeclarativeRefreshIndicator(
              child: GameList(games: completed, handlePressGame: (game) => _handlePressGame(context, game)),
              refreshing: _loading,
              onRefresh: () => _loadGames(hard: true)
            ),
          ]
        )
      )
    );

    return DefaultTabController(
        length: 2,
        child: scaffold
    );
  }
}

