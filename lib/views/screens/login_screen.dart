import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/AppState.dart';
import 'package:steamcheetos_flutter/client/auth.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';
import 'package:logger/logger.dart';
import 'package:steamcheetos_flutter/client/login.dart';
import 'package:steamcheetos_flutter/views/screens/games_screen.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({Key? key}) : super(key: key);

  static Route createRoute() => PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen()
  );

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final log = Logger();
  bool loading = false;

  void _doLogin(BuildContext context) async {
    setState(() {
      loading = true;
    });

    final token = await AuthManager.getDefault().doLogin();
    final client = GamesClient.create(token);
    final user = await client.getUser();
    log.i('User $user');

    final state = await AppState.getInstance();
    state.login(user, token);

    Navigator.pushReplacement(context, GamesScreen.createRoute(user, client));
  }

  @override
  Widget build(BuildContext context) {
    final widget = loading
        ? const CircularProgressIndicator()
        : LoginButton(() => _doLogin(context))
    ;

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

