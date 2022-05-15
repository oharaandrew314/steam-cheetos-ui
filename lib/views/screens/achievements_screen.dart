import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/state/achievement_state.dart';
import 'package:steamcheetos_flutter/state/friends_state.dart';
import 'package:steamcheetos_flutter/state/game_state.dart';
import 'package:steamcheetos_flutter/views/screens/achievement_search_screen.dart';
import 'package:steamcheetos_flutter/views/screens/achievements_compare_screen.dart';
import 'package:steamcheetos_flutter/views/widgets/achievement_list.dart';
import 'package:steamcheetos_flutter/views/widgets/user.dart';
import 'package:steamcheetos_flutter/views/widgets/user_list.dart';

class AchievementsScreen extends StatefulWidget {

  final UserDto user;
  final String gameId;

  const AchievementsScreen({required this.user, required this.gameId, Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();

  static Route createRoute(UserDto user, String gameId) => PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AchievementsScreen(user: user, gameId: gameId)
  );
}

class _AchievementsScreenState extends State<AchievementsScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      context.read<FriendsState>().refresh();

      final game = context.read<GameState>().game(widget.gameId);
      context.read<AchievementState>().load(
          widget.gameId,
          hard: game?.shouldLoadAchievements() ?? true
      );
    });
  }

  void _handlePressSearch(GameDto game) {
    final route = PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AchievementSearchScreen(user: widget.user, game: game)
    );
    Navigator.of(context).push(route);
  }

  void _handleGoToFriend(BuildContext context, UserDto friend, GameDto game) {
    final route = AchievementsCompareScreen.createRoute(friend, game);
    Navigator.of(context).push(route);
  }

  Widget _buildAchievementDetails(GameDto game) {
    final scaffold =  Scaffold(
      appBar: AppBar(
        title: Text(game.name),
        actions: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _handlePressSearch(game)
          ),
          IconButton(
            icon: Icon(game.favourite ? Icons.favorite : Icons.favorite_border),
            onPressed: () => context.read<GameState>().setFavourite(widget.gameId, !game.favourite)
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AchievementState>().load(game.id, hard: true)
          ),
          UserMenu(user: widget.user)
        ],
        bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.clear)),
              Tab(icon: Icon(Icons.check)),
              Tab(icon: Icon(Icons.people))
            ]
        ),
      ),
      body: Center(
          child: TabBarView(
            children: [
              Consumer<AchievementState>(
                builder: (context, value, child) => DeclarativeRefreshIndicator(
                    child: AchievementList(
                        placeholder: const UnlockedPlaceholder(),
                        game: game,
                        achievements: value.achievements(game.id, unlocked: false)
                    ),
                    refreshing: value.isLoading(game.id),
                    onRefresh: () => value.load(game.id, hard: true)
                ),
              ),
              Consumer<AchievementState>(
                builder: (context, value, child) => DeclarativeRefreshIndicator(
                    child: AchievementList(
                        placeholder: const LockedPlaceholder(),
                        game: game,
                        achievements: value.achievements(game.id, unlocked: true)
                    ),
                    refreshing: value.isLoading(game.id),
                    onRefresh: () => value.load(game.id, hard: true)
                ),
              ),
              Consumer<FriendsState>(
                builder: (context, value, child) => DeclarativeRefreshIndicator(
                    child: UserList(users: value.friends, handlePressed: (user) => _handleGoToFriend(context, user, game)),
                    refreshing: value.loading,
                    onRefresh: () => value.refresh()
                )
              )
            ],
          )
      ),
    );

    return DefaultTabController(
        length: 3,
        child: scaffold
    );
  }

  Widget _buildNoAchievements(GameDto game) {
    return Scaffold(
      appBar: AppBar(
        title: Text(game.name),
      ),
      body:  Consumer<FriendsState>(
          builder: (context, value, child) => DeclarativeRefreshIndicator(
              child:const Center(
                child: NoAchievementsPlaceholder(),
              ),
              refreshing: value.loading,
              onRefresh: () => value.refresh()
          )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
        builder: (context, value, child) {
          final game = value.game(widget.gameId);
          if (game == null) {
            value.refresh();
            return Container();
          }
          if (!game.hasAchievements()) {
            return _buildNoAchievements(game);
          }

          return _buildAchievementDetails(game);
        },
    );
  }
}