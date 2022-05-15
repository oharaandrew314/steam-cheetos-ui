import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:provider/provider.dart';
import 'package:steamcheetos_flutter/app_state.dart';
import 'package:steamcheetos_flutter/state/achievement_state.dart';
import 'package:steamcheetos_flutter/state/friends_state.dart';
import 'package:steamcheetos_flutter/state/game_state.dart';
import 'package:steamcheetos_flutter/views/screens/games_screen.dart';
import 'package:steamcheetos_flutter/views/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final state = await AppState.getInstance();
  final user = state.getUser();

  final home = user == null
      ? const LoginScreen()
      : GamesScreen(user: user);

  final app = FlutterWebFrame(
      builder: (context) {
        return MaterialApp(
            title: 'Steam Cheetos',
            theme: ThemeData(
              primarySwatch: Colors.grey,
            ),
            home: LimitedBox(
              maxWidth: 512,
              child: home,
            )
        );
      },
      maximumSize: const Size(768, 0),
      enabled: kIsWeb,
  );

  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider<GameState>(create: (_) => GameState()),
          ChangeNotifierProvider<FriendsState>(create: (_) => FriendsState()),
          ChangeNotifierProvider<AchievementState>(create: (_) => AchievementState()),
        ],
        child: app,
    )
  );
}