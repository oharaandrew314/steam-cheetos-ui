import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/views/screens/achievements_screen.dart';
import 'package:steamcheetos_flutter/views/widgets/game.dart';
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
  List<GameDto>? _games;
  final log = Logger();

  @override
  void initState() {
    super.initState();

    _loadGames();
  }

  void _loadGames() async {
    final games = await widget.client.listGames();
    setState(() {
      _games = games;
    });
  }

  void _handlePressGame(BuildContext context, GameDto game) {
    log.d("Go to achievements for $game");
    Navigator.push(context, AchievementsScreen.createRoute(widget.client, widget.user, game));
  }

  @override
  Widget build(BuildContext context) {
    final content = _games != null
        ? GameList(
            games: _games!,
            handlePress: (game) => _handlePressGame(context, game)
          )
        : const CircularProgressIndicator()
    ;

    final userMenu = UserMenu(user: widget.user);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Games"),
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

