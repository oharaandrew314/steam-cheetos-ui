import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/views/widgets/user.dart';

class UserList extends StatelessWidget {
  final List<UserDto> users;
  final Function(UserDto) handlePressed;

  const UserList({required this.users, required this.handlePressed, Key? key}) : super(key: key);

  Widget _buildPlaceholder(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.question_mark,
          color: Colors.orange,
          size: 128,
        ),
        Text(
          "You have no friends :'(",
          style: Theme.of(context).textTheme.titleMedium,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return ListView(
        children: [
          Center(
            child: _buildPlaceholder(context),
          )
        ],
      );
    }

    return ListView.builder(
      itemCount: users.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        final user =  users[index];
        return UserTile(user: user, handlePressed: handlePressed);
      }
    );
  }

}