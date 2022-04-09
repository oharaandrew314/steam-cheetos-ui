import 'package:flutter/widgets.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/views/widgets/achievement.dart';

class AchievementList extends StatelessWidget {
  final GameDto game;
  final List<AchievementDtoV1> achievements;

  const AchievementList({required this.game, required this.achievements, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            // padding: const EdgeInsets.all(5),
            itemCount: achievements.length,
            itemBuilder: (BuildContext context, int index) {
              final achievement = achievements[index];
              return Achievement(game, achievement);
            }
        )
    );
  }
}