import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/views/widgets/achievement_list.dart';
import 'package:steamcheetos_flutter/views/widgets/search_bar.dart';
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
  List<AchievementDtoV1>? _achievements;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  void _loadAchievements() async {
    final achievements = await widget.client.listAchievements(widget.game.id);
    setState(() {
      _achievements = achievements;
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = _achievements != null
        ? AchievementList(achievements: _achievements!, searchController: searchController)
        : const CircularProgressIndicator()
    ;
    final userMenu = UserMenu(user: widget.user);

    return Scaffold(
      appBar: AppBar(
        title: SearchBar(placeholder: widget.game.name, controller: searchController),
        actions: [userMenu],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [content],
        ),
      ),
    );
  }
}

