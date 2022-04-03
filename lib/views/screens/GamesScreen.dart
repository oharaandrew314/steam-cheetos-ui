import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/AppState.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:logger/logger.dart';
import 'package:steamcheetos_flutter/views/screens/LoginScreen.dart';
import 'package:steamcheetos_flutter/views/widgets/Game.dart';
import 'package:steamcheetos_flutter/views/widgets/userProfile.dart';

class GamesScreen extends StatefulWidget {

  final GamesClient client;
  final UserDto user;

  const GamesScreen({required this.client, required this.user, Key? key}) : super(key: key);

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final log = Logger();

  List<GameDto>? _games;

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

  void _doLogout(BuildContext context) async {
    final state = await AppState.getInstance();
    state.logout();

    Navigator.pushReplacement(context, LoginScreen.createRoute());
  }

  @override
  Widget build(BuildContext context) {
    final gamesList = _games != null ? GameList(games: _games!) : null;
    final userMenu = UserMenu(user: widget.user, doLogout: () => _doLogout(context));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Steam Cheetos'),
        actions: [userMenu],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (gamesList != null) gamesList
          ],
        ),
      ),
    );
  }
}

