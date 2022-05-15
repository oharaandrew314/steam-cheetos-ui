import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/state/game_state.dart';
import 'package:steamcheetos_flutter/views/screens/achievements_screen.dart';
import 'package:steamcheetos_flutter/views/screens/game_search_screen.dart';
import 'package:steamcheetos_flutter/views/widgets/game_list.dart';
import 'package:steamcheetos_flutter/views/widgets/user.dart';

class GamesScreen extends StatefulWidget {

  final UserDto user;

  const GamesScreen({required this.user, Key? key}) : super(key: key);

  @override
  State<GamesScreen> createState() => _GamesScreenState();

  static Route createRoute(UserDto user) => PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GamesScreen(
      user: user,
    ),
  );
}

class _GamesScreenState extends State<GamesScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      context.read<GameState>().refresh();
    });
  }

  void _handlePressGame(BuildContext context, GameDto game) {
    Navigator.push(context, AchievementsScreen.createRoute(widget.user, game.id));
  }

  void _handlePressSearch(BuildContext context) {
    final route = PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => GameSearchScreen(
            handlePressGame: (game) => Navigator.pushReplacement(context, AchievementsScreen.createRoute(widget.user, game.id))
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
              onPressed: () => context.read<GameState>().refresh(hard: true)
            ),
            UserMenu(user: widget.user)
          ],
        bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.incomplete_circle)),
              Tab(icon: Icon(Icons.emoji_events)),
              Tab(icon: Icon(Icons.favorite)),
              Tab(icon: Icon(Icons.download)),
            ]
        )
      ),
      body: Center(
        child: Consumer<GameState>(
          builder: (context, games, child) => TabBarView(
            children: [
              DeclarativeRefreshIndicator(
                child: GameList(games: games.notCompleted, handlePressGame: handlePress),
                refreshing: games.loading,
                onRefresh: () => games.refresh(hard: true)
              ),
              DeclarativeRefreshIndicator(
                child: GameList(games: games.completed, handlePressGame: handlePress),
                  refreshing: games.loading,
                  onRefresh: () => games.refresh(hard: true)
              ),
              DeclarativeRefreshIndicator(
                  child: GameList(games: games.favourites, handlePressGame: handlePress),
                  refreshing: games.loading,
                  onRefresh: () => games.refresh(hard: true)
              ),
              DeclarativeRefreshIndicator(
                  child: GameList(games: games.unSynced, handlePressGame: handlePress),
                  refreshing: games.loading,
                  onRefresh: () => games.refresh(hard: true)
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

