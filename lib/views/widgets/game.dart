import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';

class GameSummary extends StatelessWidget {
  final GameDto game;

  const GameSummary({required this.game, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final image = game.displayImage == null ? null
      : Image.network(game.displayImage.toString());

    final top = Row(
      children: [
        if (image != null) image,
        Text(game.name)
      ],
    );

    final bottom = Row(
      children: [
        LinearProgressIndicator(
            value: game.achievementsCurrent.toDouble() / game.achievementsTotal
        ),
        if (game.achievementsCurrent == game.achievementsTotal) const Icon(Icons.star)
      ],
    );

    return top;

    // return Column(
    //     children: [top, bottom]
    // );
  }
}

class GameSummary2 extends StatelessWidget {
  final GameDto game;
  final VoidCallback? handlePress;

  const GameSummary2({required this.game, this.handlePress, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final preview = game.displayImage == null
        ? Text(game.name)
        : Image.network(game.displayImage.toString());

    final completion = game.isCompleted()
        ? const Icon(
            Icons.star,
            size: 80,
            color: Colors.yellow,
          )
        : CircularPercentIndicator(
            radius: 30.0,
            // lineWidth: 5.0,
            percent: game.getCompletion(),
            center: Text("${game.achievementsCurrent} / ${game.achievementsTotal}"),
            // progressColor: Colors.green,
          );

    final content = Row(
        children: [preview, completion],
        crossAxisAlignment: CrossAxisAlignment.center
    );

    return handlePress == null
      ? content
      : ElevatedButton(
          onPressed: handlePress,
          child: content
        );
  }
}