import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/state/games.dart';
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
    Provider.of<GameState>(context, listen: false).updateAll(games);
    
    setState(() {
      _loading = false;
    });
  }

  void _handlePressGame(BuildContext context, GameDto game) {
    Navigator.push(context, AchievementsScreen.createRoute(widget.client, widget.user, game));
  }

  void _handlePressSearch(BuildContext context) {
    final route = PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => GameSearchScreen(
            handlePressGame: (game) => Navigator.pushReplacement(context, AchievementsScreen.createRoute(widget.client, widget.user, game))
        )
    );
    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    void handlePress(GameDto game) => _handlePressGame(context, game);

    final scaffold =  Scaffold(
      appBar: AppBar(
          title: const Text("Steam Cheetos"),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _handlePressSearch(context)
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _loadGames(hard: true),
            ),
            UserMenu(user: widget.user)
          ],
        bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.incomplete_circle)),
              Tab(icon: Icon(Icons.emoji_events)),
              Tab(icon: Icon(Icons.favorite)),
              Tab(icon: Icon(Icons.pending)),
            ]
        )
      ),
      body: Center(
        child: Consumer<GameState>(
          builder: (context, games, child) => TabBarView(
            children: [
              DeclarativeRefreshIndicator(
                child: GameList(games: games.notCompleted, handlePressGame: handlePress),
                refreshing: _loading,
                onRefresh: () => _loadGames(hard: true)
              ),
              DeclarativeRefreshIndicator(
                child: GameList(games: games.completed, handlePressGame: handlePress),
                refreshing: _loading,
                onRefresh: () => _loadGames(hard: true)
              ),
              DeclarativeRefreshIndicator(
                  child: GameList(games: games.favourites, handlePressGame: handlePress),
                  refreshing: _loading,
                  onRefresh: () => _loadGames(hard: true)
              ),
              DeclarativeRefreshIndicator(
                  child: GameList(games: games.unSynced, handlePressGame: handlePress),
                  refreshing: _loading,
                  onRefresh: () => _loadGames(hard: true)
              ),
            ]
          )
        )
      )
    );

    return DefaultTabController(
        length: 4,
        child: scaffold
    );
  }
}

