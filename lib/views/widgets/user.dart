import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/app_state.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/views/screens/login_screen.dart';

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

class UserAvatar extends StatelessWidget {
  final UserDto user;

  const UserAvatar({required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatar = user.avatar == null
        ? CircleAvatar(
            child: Text(user.name),
          )
        : CircleAvatar(
            backgroundImage: NetworkImage(user.avatar.toString())
          );
    return avatar;
  }
}

class SquareUserAvatar extends StatelessWidget {
  final UserDto user;

  const SquareUserAvatar({required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatar = user.avatar == null
      ? Text(user.name)
      : Image(image: NetworkImage(user.avatar.toString()))
    ;

    return LimitedBox(
      maxHeight: 100,
      child: avatar,
    );
  }
}

class UserTile extends StatelessWidget {
  final UserDto user;
  final Function(UserDto) handlePressed;

  const UserTile({required this.user, required this.handlePressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Expanded(child: SquareUserAvatar(user: user), flex: 1),
        Expanded(
            child: Text(
                user.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium
            ),
            flex: 4
        )
      ],
    );

    return TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        onPressed: () => handlePressed(user),
        child: Card(child: content)
    );
  }
}

class UserMenu extends StatelessWidget {
  final UserDto user;

  const UserMenu({required this.user, Key? key}): super(key: key);

  void _doLogout(BuildContext context) async {
    final state = await AppState.getInstance();
    state.logout();

    Navigator.pushReplacement(context, LoginScreen.createRoute());
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        icon: UserAvatar(user: user),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Text(user.name),
          ),
          PopupMenuItem(
            child: const Text("Logout"),
            onTap: () => _doLogout(context)
          )
        ]
    );
  }
}