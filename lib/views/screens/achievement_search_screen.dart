import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/state/achievement_state.dart';
import 'package:steamcheetos_flutter/views/widgets/achievement_list.dart';
import 'package:steamcheetos_flutter/views/widgets/search_bar.dart';

class AchievementSearchScreen extends StatefulWidget {
  final UserDto user;
  final GameDto game;

  const AchievementSearchScreen({ required this.user, required this.game, Key? key}) : super(key: key);

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
    return Scaffold(
        appBar: AppBar(
            title: SearchBar(
                placeholder: 'Search Achievements...',
                controller: _searchController,
                autofocus: true
            ),
        ),
        body: Center(
          child: Consumer<AchievementState>(
            builder: (context, value, child) => AchievementList(
              game: widget.game,
              achievements: value.achievements(widget.game.id, term: _searchTerm),
              placeholder: const NoAchievementsPlaceholder(),
            )
          )
        )
    );
  }
}