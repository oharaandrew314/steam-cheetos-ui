import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/client/cheetos_client.dart';
import 'package:steamcheetos_flutter/views/screens/LoginScreen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  final host = Uri.parse("http://${kIsWeb ? "localhost" : "10.0.2.2"}:8000");
  print("Cheetos Host: $host");

  runApp(MyApp(host: host));
}

class MyApp extends StatelessWidget {
  final Uri host;

  const MyApp({required this.host, Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final client = CheetosClient(host);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(client: client),
    );
  }
}