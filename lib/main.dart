import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:steamcheetos_flutter/AppState.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';
import 'package:steamcheetos_flutter/views/screens/games_screen.dart';
import 'package:steamcheetos_flutter/views/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final state = await AppState.getInstance();
  final user = state.getUser();
  final token = state.getAccessToken();

  final home = user == null || token == null
      ? const LoginScreen()
      : GamesScreen(client: GamesClient.create(token), user: user);

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

  runApp(app);
}