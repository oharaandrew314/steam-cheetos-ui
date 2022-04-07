import 'package:flutter/widgets.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/views/widgets/achievement.dart';

class AchievementList extends StatefulWidget {
  final List<AchievementDtoV1> achievements;
  final TextEditingController searchController;

  const AchievementList({required this.achievements, required this.searchController, Key? key}) : super(key: key);

  @override
  State<AchievementList> createState() => _AchievementListState();
}

class _AchievementListState extends State<AchievementList> {
  final List<AchievementDtoV1> sorted = [];

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
    final results = extractAllSorted<AchievementDtoV1>(
        query:  text,
        choices: widget.achievements,
        getter: (achievement) => achievement.name,
        cutoff: 85
    );

    setState(() {
      sorted.clear();
      sorted.addAll(results.map((e) => e.choice));
    });
  }

  void _clear() {
    setState(() {
      sorted.clear();
      sorted.addAll(widget.achievements);
      // sorted.sort((a1, a2) => game2.getCompletion().compareTo(game1.getCompletion()));
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
              final achievement = sorted[index];
              return Achievement(achievement);
              // return LimitedBox(
              //     maxHeight: 100,
              //     child: Achievement(achievement)
              // );
            }
        )
    );
  }
}