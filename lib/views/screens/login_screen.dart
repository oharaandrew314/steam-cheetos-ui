import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/AppState.dart';
import 'package:steamcheetos_flutter/client/auth_client.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:logger/logger.dart';
import 'package:steamcheetos_flutter/views/screens/games_screen.dart';

class LoginScreen extends StatelessWidget {
  final log = Logger();

  LoginScreen({Key? key}) : super(key: key);

  static Route createRoute() => PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => LoginScreen()
  );

  void _doLogin(BuildContext context) async {
    final redirectUri = kIsWeb ? Uri.base.resolve("auth.html") : Uri.parse("steamcheetos://auth");
    log.d('redirect uri: $redirectUri');

    final loginUri = await AuthClient.getDefault().getLoginUri(redirectUri);
    log.d('login uri: $loginUri');
    final result = await FlutterWebAuth.authenticate(url: loginUri.toString(), callbackUrlScheme: redirectUri.scheme);
    final token = Uri.parse(result).queryParameters["token"]!;
    log.d('token: $token');

    final user = await GamesClient.create(token).getUser();
    log.i('User $user');

    final state = await AppState.getInstance();
    state.login(user, token);
    
    Navigator.pushReplacement(context, _createGamesScreenRoute(user, GamesClient.create(token)));
  }

  Route _createGamesScreenRoute(UserDto user, GamesClient client) => PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GamesScreen(
        user: user,
        client: client,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final widget = TextButton(
        child: Image.asset('assets/login/steam_login_2.png'),
        onPressed: () => _doLogin(context)
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login with Steam'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [widget]
        ),
      ),
    );
  }
}

