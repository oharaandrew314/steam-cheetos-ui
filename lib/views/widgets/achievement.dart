import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/state/achievement_state.dart';
import 'package:url_launcher/url_launcher.dart';

class UserAchievementStatus extends StatefulWidget {
  final GameDto game;
  final AchievementDtoV1 achievement;

  const UserAchievementStatus(this.game, this.achievement, {Key? key}): super(key: key);

  @override
  State<UserAchievementStatus> createState() => _UserAchievementStatusState();
}

class _UserAchievementStatusState extends State<UserAchievementStatus> {
  bool expanded = false;

  void _handleTap() {
    setState(() {
      expanded = !expanded;
    });
  }

  void _openHelpWindow() async {
    final uri = Uri.https("www.google.com", "search", {
      "q": "site:trueachievements.com ${widget.game.name} ${widget.achievement.name}"
    });

    await launch(uri.toString());
  }

  Widget _extraInfo() {
    if (widget.achievement.unlockedOn != null) {
      return Text("Unlocked on ${widget.achievement.unlockedOn.toString()}");
    }

    return ElevatedButton(
        onPressed: _openHelpWindow,
        child: const Text("Get Help")
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainContent = Row(
      children: [
        Expanded(
          flex: 8,
          child: AchievementTile(achievement: widget.achievement)
        ),
        Expanded(
          child: AchievementStatus(widget.achievement.toStatus()),
          flex: 1
        ),
      ],
    );

    final allContent = Column(
      children: [
        mainContent,
        if (expanded) _extraInfo()
      ],
    );

    return InkWell(
      onTap: _handleTap,
      child: Card(child: allContent)
    );
  }
}

class AchievementTile extends StatelessWidget {

  final AchievementDtoV1 achievement;

  const AchievementTile({required this.achievement, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          // child: SizedBox(
            child: AchievementImage(achievement),
            // height: 100,
          // ),
          flex: 2,
        ),
        const Padding(padding: EdgeInsets.fromLTRB(5, 0, 5, 0)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievement.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 0)),
              achievement.description != null
                  ? Text(achievement.description!, overflow: TextOverflow.clip,)
                  : const Text(
                      "This is a secret achievement",
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontStyle: FontStyle.italic),
                    )
            ],
          ),
          flex: 8,
        )
      ],
    );
  }
}

class AchievementStatus extends StatelessWidget {

  final AchievementStatusDto status;
  final String? header;

  const AchievementStatus(this.status, { this.header, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (header != null) Text(
          header!,
          style: Theme.of(context).textTheme.titleSmall
        ),
        Icon(
        status.unlocked ? Icons.check : Icons.clear,
          color: status.unlocked ? Colors.green : Colors.red,
        )
      ],
    );
  }
}

class AchievementComparison extends StatelessWidget {

  final AchievementComparisonDto comparison;

  const AchievementComparison(this.comparison, { Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Row(
          children: [
            Expanded(
              child: AchievementTile(achievement: comparison.achievement),
              flex: 4,
            ),
            Expanded(
              child: AchievementStatus(comparison.achievement.toStatus(), header: "You"),
              flex: 1
            ),
            Expanded(
              child: AchievementStatus(comparison.friendStatus, header: "Them"),
              flex: 1
            )
          ],
        )
    );
  }
}

class AchievementImage extends StatelessWidget {

  final AchievementDtoV1 achievement;

  const AchievementImage(this.achievement, { Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final url = achievement.unlocked ? achievement.iconUnlocked : achievement.iconLocked;

    return Image.network(
      url.toString(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const CircularProgressIndicator();
      },
      errorBuilder: (context, exception, stackTrace) {
        return const Icon(Icons.warning, color: Colors.yellow);
      },
      // height: 100,
    );
  }
}