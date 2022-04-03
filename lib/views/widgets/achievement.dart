import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';

class Achievement extends StatelessWidget {
  final AchievementDtoV1 achievement;

  const Achievement(this.achievement, {Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final image = achievement.unlocked
      ? achievement.iconUnlocked != null ? Image.network(achievement.iconUnlocked.toString()) : const Icon(Icons.check_circle)
      : achievement.iconLocked != null ? Image.network(achievement.iconLocked.toString()) : const Icon(Icons.check_box)
    ;

    return Row(
      children: [
        image,
        Text(achievement.name)
      ],
    );
  }
}

class AchievementList extends StatefulWidget {
  final List<AchievementDtoV1> achievements;

  const AchievementList(this.achievements, { Key? key}) : super(key: key);

  @override
  State<AchievementList> createState() => _AchievementListState();
}

class _AchievementListState extends State<AchievementList> {
  final List<AchievementDtoV1> sorted = [];

  @override
  void initState() {
    super.initState();

    sorted.addAll(widget.achievements);
    // sorted.sort((a1, game2) => a);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            // padding: const EdgeInsets.all(5),
            itemCount: sorted.length,
            itemBuilder: (BuildContext context, int index) {
              final achievement = sorted[index];
              return SizedBox(
                  height: 100,
                  child: Achievement(achievement)
              );
            }
        )
    );
  }
}