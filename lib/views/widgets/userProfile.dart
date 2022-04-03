import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';

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

class UserMenu extends StatelessWidget {
  final UserDto user;
  final VoidCallback? doLogout;

  const UserMenu({required this.user, required this.doLogout, Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        icon: UserAvatar(user: user),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Text(user.name),
            value: 1,
          ),
          PopupMenuItem(
            child: const Text("Logout"),
            value: 2,
            onTap: doLogout
          )
        ]
    );
  }
}