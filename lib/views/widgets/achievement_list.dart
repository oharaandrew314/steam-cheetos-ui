import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/views/widgets/achievement.dart';

class AchievementList extends StatelessWidget {
  final Widget placeholder;
  final GameDto game;
  final List<AchievementDtoV1> achievements;

  const AchievementList({required this.placeholder, required this.game, required this.achievements, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: achievements.length,
        itemBuilder: (BuildContext context, int index) {
          final achievement = achievements[index];
          return Achievement(game, achievement);
        }
    );
  }
}

class LockedPlaceholder extends StatelessWidget {
  const LockedPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          const Icon(
            Icons.clear,
            color: Colors.red,
            size: 128,
          ),
          Text(
            "You haven't unlocked anything :(",
            style: Theme.of(context).textTheme.titleMedium,
          )
        ]
    );
  }
}

class UnlockedPlaceholder extends StatelessWidget {
  const UnlockedPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 128,
        ),
        Text(
          "You've unlocked everything!",
          style: Theme.of(context).textTheme.titleMedium,
        )
      ],
    );
  }
}

class NoAchievementsPlaceholder extends StatelessWidget {
  const NoAchievementsPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.question_mark,
          color: Colors.orange,
          size: 128,
        ),
        Text(
          "No Achievements Found",
          style: Theme.of(context).textTheme.titleMedium,
        )
      ],
    );
  }
}