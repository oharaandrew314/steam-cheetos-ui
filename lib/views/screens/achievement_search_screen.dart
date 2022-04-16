import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/views/widgets/achievement_list.dart';
import 'package:steamcheetos_flutter/views/widgets/search_bar.dart';

class AchievementSearchScreen extends StatefulWidget {
  final GameDto game;
  final List<AchievementDtoV1> achievements;

  const AchievementSearchScreen({required this.game, required this.achievements, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AchievementSearchScreenState();
}

class _AchievementSearchScreenState extends State<AchievementSearchScreen> {
  final _searchController = TextEditingController();
  var _searchTerm = "";

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = extractAllSorted<AchievementDtoV1>(
        query: _searchTerm,
        choices: widget.achievements,
        getter: (a) => '${a.name} ${a.description}',
        cutoff: 60
    ).map((e) => e.choice).toList();

    return Scaffold(
        appBar: AppBar(
            title: SearchBar(
                placeholder: 'Search Achievements...',
                controller: _searchController,
                autofocus: true
            ),
        ),
        body: Center(
          child: AchievementList(
            game: widget.game,
            achievements: results,
            placeholder: const NoAchievementsPlaceholder(),
          )
        )
    );
  }
}