import 'package:flutter/material.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:url_launcher/url_launcher.dart';

class Achievement extends StatefulWidget {
  final GameDto game;
  final AchievementDtoV1 achievement;

  const Achievement(this.game, this.achievement, {Key? key}): super(key: key);

  static const iconLocked = Icon(Icons.clear_outlined, color: Colors.red);
  static const iconUnlocked =  Icon(Icons.check_circle_outline, color: Colors.green);

  @override
  State<Achievement> createState() => _AchievementState();
}

class _AchievementState extends State<Achievement> {
  bool expanded = false;

  void _handleTap() {
    setState(() {
      expanded = !expanded;
    });
  }

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

  Widget _lockedIcon() => Icon(
    widget.achievement.unlocked ? Icons.check : Icons.clear_outlined,
    color: widget.achievement.unlocked ? Colors.green : Colors.red,
  );

  Widget _mainDescription() => Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.achievement.name,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 5),
          Text(
            widget.achievement.description ?? "This is a secret achievement", // TODO italicize
            overflow: TextOverflow.clip,
          )
        ],
      )
  );

  Widget _imageIcon() => widget.achievement.unlocked
      ? _achievementImage(widget.achievement.iconUnlocked, Achievement.iconUnlocked)
      : _achievementImage(widget.achievement.iconLocked, Achievement.iconLocked)
      ;

  void _openHelpWindow() async {
    final uri = Uri.https("www.google.com", "search", {
      "q": "site:truesteamachievements.com ${widget.game.name} ${widget.achievement.name}"
    });

    await launch(uri.toString());
  }

  Widget _extraInfo() {
    if (widget.achievement.unlockedOn != null) {
      return Text("Unlocked on ${widget.achievement.unlockedOn.toString()}");
    }

    return ElevatedButton(
        onPressed: _openHelpWindow,
        child: const Text("True Steam Achievements")
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainContent = Row(
      children: [
        Expanded(
          flex: 2,
          child: _imageIcon()
        ),
        Expanded(
          flex: 10,
          child: _mainDescription()
        ),
        Expanded(
            child: _lockedIcon()
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