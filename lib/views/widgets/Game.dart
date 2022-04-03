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

  const GameSummary2({required this.game, Key? key}) : super(key: key);

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

    return Row(
      children: [preview, completion],
      crossAxisAlignment: CrossAxisAlignment.center
    );
  }
}

class GameList extends StatefulWidget {
  final List<GameDto> games;

  const GameList({required this.games, Key? key}) : super(key: key);

  @override
  State<GameList> createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  final List<GameDto> sorted = [];

  @override
  void initState() {
    super.initState();

    sorted.addAll(widget.games);
    sorted.sort((game1, game2) => game2.getCompletion().compareTo(game1.getCompletion()));
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
              final game = sorted[index];
              return SizedBox(
                  height: 100,
                  child: GameSummary2(game: game)
              );
            }
        )
    );
  }
}