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

  UserDto? getUser() {
    final id = prefs.getString("user_id");
    if (id == null) return null;

    final name = prefs.getString("username");
    if (name == null) return null;

    final avatar = prefs.getString("avatar");

    return UserDto(
        id: id,
        name: name,
        avatar: avatar == null ? null : Uri.parse(avatar)
    );
  }

  void login(UserDto user, String token) {
    prefs.setString("user_id", user.id);
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