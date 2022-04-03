import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/AppState.dart';
import 'package:steamcheetos_flutter/client/auth_client.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:logger/logger.dart';
import 'package:steamcheetos_flutter/views/screens/GamesScreen.dart';
import 'package:steamcheetos_flutter/views/widgets/userProfile.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();

  static Route createRoute() => PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen()
  );
}

class _LoginScreenState extends State<LoginScreen> {
  UserDto? _user;
  final log = Logger();
  final _authClient = AuthClient.getDefault();

  @override
  void initState() {
    super.initState();

    _loadUser();
  }

  void _loadUser() async {
    final state = await AppState.getInstance();
    setState(() {
      _user = state.getUser();
    });
  }

  void _doLogin(BuildContext context) async {
    final redirectUri = kIsWeb ? Uri.base.resolve("auth.html") : Uri.parse("steamcheetos://auth");
    log.d('redirect uri: $redirectUri');

    final loginUri = await _authClient.getLoginUri(redirectUri);
    log.d('login uri: $loginUri');
    final result = await FlutterWebAuth.authenticate(url: loginUri.toString(), callbackUrlScheme: redirectUri.scheme);
    final token = Uri.parse(result).queryParameters["token"]!;
    log.d('token: $token');

    final user = await GamesClient.create(token).getUser();
    log.i('User $user');

    final state = await AppState.getInstance();
    state.login(user, token);
    
    Navigator.pushReplacement(context, _createGamesScreenRoute(user, GamesClient.create(token)));

    // setState(() {
    //   _user = user;
    // });
  }

  void _doLogout() async {
    final state = await AppState.getInstance();
    state.logout();

    setState(() {
      _user = null;
    });
  }

  Route _createGamesScreenRoute(UserDto user, GamesClient client) => PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GamesScreen(
        user: user,
        client: client,
    ),
    // transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //   return child;
    // }
  );

  @override
  Widget build(BuildContext context) {
    final widget = _user == null
      ? TextButton(
          child: Image.asset('assets/login/steam_login_2.png'),
          onPressed: () => _doLogin(context)
      )
      : Column(
        children: [
          UserProfile(user: _user!),
          ElevatedButton(onPressed: _doLogout, child: const Text('Logout'))
        ]
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Steam Cheetos'),
        actions: [
          if (_user != null) UserMenu(user: _user!, doLogout: _doLogout)
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget
          ],
        ),
      ),
    );
  }
}

