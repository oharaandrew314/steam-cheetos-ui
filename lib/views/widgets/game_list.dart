import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/views/widgets/game.dart';

class GameList extends StatelessWidget {
  final List<GameDto> games;
  final Function(GameDto) handlePressGame;

  const GameList({
    required this.games,
    required this.handlePressGame,
    Key? key
  }) : super(key: key);

  Widget _buildPlaceholder(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.question_mark,
          color: Colors.orange,
          size: 128,
        ),
        Text(
          "No games Found",
          style: Theme.of(context).textTheme.titleMedium,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return Center(
        child: _buildPlaceholder(context)
      );
    }

    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: games.length,  // TODO add limit with warning at bottom
      itemBuilder: (BuildContext context, int index) {
        final game = games[index];
        return GameSummary(
            game: game,
            handlePress: () => handlePressGame(game)
        );
      });
  }
}

