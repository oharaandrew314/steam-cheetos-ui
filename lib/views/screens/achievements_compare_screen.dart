import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/state/achievement_state.dart';
import 'package:steamcheetos_flutter/views/widgets/achievement.dart';

class AchievementsCompareScreen extends StatefulWidget {

  final UserDto friend;
  final GameDto game;

  const AchievementsCompareScreen({required this.friend,  required this.game, Key? key}) : super(key: key);

  @override
  State<AchievementsCompareScreen> createState() => _AchievementsCompareScreenState();

  static Route createRoute(UserDto friend, GameDto game) => PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AchievementsCompareScreen(
        friend: friend,
        game: game,
      )
  );
}

class _AchievementsCompareScreenState extends State<AchievementsCompareScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      context.read<AchievementState>().loadFriend(widget.friend.id, widget.game.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = Consumer<AchievementState>(
        builder: (context, value, child) {
          final comparisons = value.compareWithFriend(widget.game.id, widget.friend.id);
          Logger().i("Loaded ${comparisons.length} comparisons for ${widget.game.name} with ${widget.friend.name}");

          return ListView.builder(
              itemCount: comparisons.length,
              itemBuilder: (context, index) {
                final comparison = comparisons[index];
                return AchievementComparison(comparison);
              },
          );
        },
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.friend.name),
        ),
        body: content,
    );
  }
}