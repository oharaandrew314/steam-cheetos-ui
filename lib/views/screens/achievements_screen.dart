import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
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
  List<AchievementDtoV1> _achievements = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future _loadAchievements({bool hard = false}) async {
    setState(() {
      _loading = true;
    });
    final achievements = await (hard ? widget.client.refreshAchievements(widget.game.id) : widget.client.listAchievements(widget.game.id));
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

  @override
  Widget build(BuildContext context) {
    final unlocked = _achievements.where((a) => a.unlocked).toList();
    final locked = _achievements.where((a) => !a.unlocked).toList();


    final scaffold =  Scaffold(
      appBar: AppBar(
        title: Text(widget.game.name),
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
        ),
      ),
      body: Center(
        child: TabBarView(
          children: [
            DeclarativeRefreshIndicator(
                child: AchievementList(placeholder: const LockedPlaceholder(), game: widget.game, achievements: locked),
                refreshing: _loading,
                onRefresh: () => _loadAchievements(hard: true)
            ),
            DeclarativeRefreshIndicator(
                child: AchievementList(placeholder: const UnlockedPlaceholder(), game: widget.game, achievements: unlocked),
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
}