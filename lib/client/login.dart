import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback doLogin;

  const LoginButton(this.doLogin, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: Image.asset('assets/login/steam_login_2.png'),
        onPressed: doLogin
    );
  }
}