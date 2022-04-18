import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:steamcheetos_flutter/client/dto_utils.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/state/games.dart';
import 'package:steamcheetos_flutter/views/screens/achievement_search_screen.dart';
import 'package:steamcheetos_flutter/views/widgets/achievement_list.dart';
import 'package:steamcheetos_flutter/views/widgets/user.dart';

class AchievementsScreen extends StatefulWidget {

  final GamesClient client;
  final UserDto user;
  final GameDto game;

  const AchievementsScreen({required this.client, required this.user, required this.game, Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();

  static Route createRoute(GamesClient client, UserDto user, GameDto game) => PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AchievementsScreen(
        client: client,
        user: user,
        game: game,
      )
  );
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  bool _favourite = false;
  List<AchievementDtoV1> _achievements = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _favourite = widget.game.favourite;
    _loadAchievements(hard: widget.game.shouldLoadAchievements());
  }

  Future _loadAchievements({bool hard = false}) async {
    setState(() {
      _loading = true;
    });
    final achievements = await (hard ? widget.client.refreshAchievements(widget.game.id) : widget.client.listAchievements(widget.game.id));
    Provider.of<GameState>(context, listen: false).update(widget.game.withAchievementCounts(achievements));
    setState(() {
      _achievements = achievements;
      _loading = false;
    });
  }

  void _handlePressSearch(BuildContext context) {
    final route = PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AchievementSearchScreen(
          game: widget.game,
          achievements: _achievements,
        )
    );
    Navigator.of(context).push(route);
  }

  void _handleFavourite(BuildContext context, GameDto game) async {
    final updated = await widget.client.updateGame(game.id, !_favourite);
    if (updated == null) throw Exception("game not found: ${game.id}");
    Logger().i("$updated - ${updated.favourite}");

    Provider.of<GameState>(context, listen: false).update(updated);
    setState(() {
      _favourite = updated.favourite;
    });
  }

  Widget _buildAchievementDetails(BuildContext context) {
    final unlocked = _achievements.where((a) => a.unlocked).toList();
    unlocked.sort(compareAchievementUnlockedOn());

    final locked = _achievements.where((a) => !a.unlocked).toList();


    final scaffold =  Scaffold(
      appBar: AppBar(
        title: Text(widget.game.name),
        actions: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _handlePressSearch(context)
          ),
          IconButton(
            icon: Icon(_favourite ? Icons.favorite : Icons.favorite_border),
            onPressed: () => _handleFavourite(context, widget.game),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadAchievements(hard: true),
          ),
          UserMenu(user: widget.user)
        ],
        bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.clear)),
              Tab(icon: Icon(Icons.check))
            ]
        ),
      ),
      body: Center(
          child: TabBarView(
            children: [
              DeclarativeRefreshIndicator(
                  child: AchievementList(placeholder: const UnlockedPlaceholder(), game: widget.game, achievements: locked),
                  refreshing: _loading,
                  onRefresh: () => _loadAchievements(hard: true)
              ),
              DeclarativeRefreshIndicator(
                  child: AchievementList(placeholder: const LockedPlaceholder(), game: widget.game, achievements: unlocked),
                  refreshing: _loading,
                  onRefresh: () => _loadAchievements(hard: true)
              )
            ],
          )
      ),
    );

    return DefaultTabController(
        length: 2,
        child: scaffold
    );
  }

  Widget _buildNoAchievements(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.name),
      ),
      body: DeclarativeRefreshIndicator(
          child: const Center(
            child: NoAchievementsPlaceholder(),
          ),
          refreshing: _loading,
          onRefresh: () => _loadAchievements(hard: true)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.game.hasAchievements()) {
      return _buildNoAchievements(context);
    }

    return _buildAchievementDetails(context);
  }
}