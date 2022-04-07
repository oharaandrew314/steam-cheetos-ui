import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';

class Achievement extends StatelessWidget {
  final AchievementDtoV1 achievement;

  const Achievement(this.achievement, {Key? key}): super(key: key);

  static const iconLocked = Icon(Icons.clear_outlined, color: Colors.red);
  static const iconUnlocked =  Icon(Icons.check_circle_outline, color: Colors.green);

  Widget _achievementImage(Uri? uri, Icon fallback) {
    if (uri == null) return fallback;

    return Image.network(
      uri.toString(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const CircularProgressIndicator();
      },
      errorBuilder: (context, exception, stackTrace) {
        return fallback;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = achievement.unlocked
      ? _achievementImage(achievement.iconUnlocked, iconUnlocked)
      : _achievementImage(achievement.iconLocked, iconLocked)
    ;

    return Row(
      children: [
        Expanded(
          child: LimitedBox(
            maxHeight: 75,
            child: image
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 5),
                Text(
                  achievement.description ?? "Secret Achievement",
                  overflow: TextOverflow.clip,
                )
              ],
            )
          )
        )
      ],
    );
  }
}