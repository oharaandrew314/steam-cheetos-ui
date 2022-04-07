import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/views/widgets/game.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

class GameList extends StatefulWidget {
  final List<GameDto> games;
  final Function(GameDto)? handlePress;
  final TextEditingController searchController;

  const GameList({required this.games, required this.searchController, this.handlePress, Key? key}) : super(key: key);

  @override
  State<GameList> createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  final List<GameDto> sorted = [];
  final log = Logger();

  @override
  void initState() {
    super.initState();

    _clear();
    widget.searchController.addListener(() {
      final text = widget.searchController.text;
      text.isEmpty ? _clear() : _filter(text);
    });
  }

  void _filter(String text) {
    final results = extractAllSorted<GameDto>(
        query:  text,
        choices: widget.games,
        getter: (game) => game.name,
        cutoff: 85
    );

    setState(() {
      sorted.clear();
      sorted.addAll(results.map((e) => e.choice));
    });
  }

  void _clear() {
    setState(() {
      sorted.addAll(widget.games);
      sorted.sort((game1, game2) => game2.getCompletion().compareTo(game1.getCompletion()));
    });
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
                  child: GameSummary2(
                      game: game,
                      handlePress: widget.handlePress == null
                          ? null
                          : () => widget.handlePress!.call(game)
                  )
              );
            }
        )
    );
  }
}