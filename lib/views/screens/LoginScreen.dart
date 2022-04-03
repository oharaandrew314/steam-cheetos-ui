import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/client/cheetos_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:steamcheetos_flutter/client/dtos.dart';

class LoginScreen extends StatefulWidget {

  final CheetosClient client;

  const LoginScreen({required this.client, Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserDto? _user;

  void _doLogin() async {
    final redirectUri = kIsWeb ? Uri.base.resolve("auth.html") : Uri.parse("steamcheetos://auth");
    print('redirect uri: $redirectUri');

    final loginUri = await widget.client.getLoginUri(redirectUri);
    print('login uri: $loginUri');
    final result = await FlutterWebAuth.authenticate(url: loginUri.toString(), callbackUrlScheme: redirectUri.scheme);
    final token = Uri.parse(result).queryParameters["token"]!;
    print('token: $token');

    final user = await widget.client.getUser(token);
    print(user);

    setState(() {
      _user = user;
    });
  }

  void _doLogout() async {
    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final widget = _user == null
      ? TextButton(
          child: Image.asset('assets/login/steam_login_2.png'),
          onPressed: _doLogin
      )
      : Column(
        children: [
          UserProfile(user: _user!),
          ElevatedButton(onPressed: _doLogout, child: const Text('Logout'))
        ]
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('SteamCheetos')
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

class UserProfile extends StatelessWidget {
  final UserDto user;

  const UserProfile({required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (user.avatar != null) Image(
            image: NetworkImage(user.avatar!.toString()),
            color: null,
            width: 48,
            height: 48
        ),
        Text(user.name)
      ],
    );
  }
}