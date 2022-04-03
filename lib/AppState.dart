import 'package:shared_preferences/shared_preferences.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';

class AppState {

  final SharedPreferences prefs;

  AppState(this.prefs);

  static Future<AppState> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return AppState(prefs);
  }

  String? getAccessToken() {
    return prefs.getString("access_token");
  }

  // void setAccessToken(String token) {
  //   prefs.setString("access_token", token);
  // }

  UserDto? getUser() {
    final name = prefs.getString("username");
    if (name == null) return null;

    final avatar = prefs.getString("avatar");

    return UserDto(
        name: name,
        avatar: avatar == null ? null : Uri.parse(avatar)
    );
  }

  void login(UserDto user, String token) {
    prefs.setString("access_token", token);
    prefs.setString("username", user.name);
    if (user.avatar == null) {
      prefs.remove("avatar");
    } else {
      prefs.setString("avatar", user.avatar.toString());
    }
  }

  void logout() {
    prefs.remove("access_token");
    prefs.remove("username");
    prefs.remove("avatar");
  }
}