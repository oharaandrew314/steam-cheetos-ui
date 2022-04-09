import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/views/widgets/achievement_list.dart';
import 'package:steamcheetos_flutter/views/widgets/search_bar.dart';
import 'package:steamcheetos_flutter/views/widgets/user.dart';

const lockedPage = 0;
const unlockedPage = 1;

class AchievementsScreen extends StatefulWidget {

  final GamesClient client;
  final UserDto user;
  final GameDto game;

  const AchievementsScreen({required this.client, required this.user, required this.game, Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();

  static Route createRoute(GamesClient client, UserDto user, GameDto game) => PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AchievementsScreen(
        client: client,
        user: user,
        game: game,
      )
  );
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _searchController = TextEditingController();

  List<AchievementDtoV1>? _achievements;
  int _pageIndex = 0;
  String _searchTerm = "";

  @override
  void initState() {
    super.initState();
    _loadAchievements();

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

  void _loadAchievements() async {
    final achievements = await widget.client.listAchievements(widget.game.id);
    setState(() {
      _achievements = achievements;
    });
  }

  void _onNavbarTap(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  bool Function(AchievementDtoV1) _achievementFilter() => (a) {
    switch(_pageIndex) {
      case lockedPage: return !a.unlocked;
      case unlockedPage: return a.unlocked;
      default: return a.unlocked;
    }
  };

  @override
  Widget build(BuildContext context) {
    List<AchievementDtoV1>? achievements = _achievements;
    if (achievements != null) {
      achievements = achievements.where(_achievementFilter()).toList();
      if (_searchTerm.isNotEmpty) {
        achievements = extractAllSorted<AchievementDtoV1>(
            query: _searchTerm,
            choices: achievements,
            getter: (achievement) => achievement.name,
            cutoff: 85
        ).map((e) => e.choice).toList();
      }
      if (_pageIndex == unlockedPage) {
        achievements.sort(compareAchievementUnlockedOn());
      }
    }

    final content = achievements != null
        ? AchievementList(game: widget.game, achievements: achievements)
        : const CircularProgressIndicator()
    ;
    final userMenu = UserMenu(user: widget.user);

    return Scaffold(
      appBar: AppBar(
        title: SearchBar(placeholder: widget.game.name, controller: _searchController),
        actions: [userMenu],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [content],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.lock),
              label: 'Locked',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.lock_open),
            label: 'Unlocked'
          ),
        ],
        currentIndex: _pageIndex,
        onTap: _onNavbarTap,
      ),
    );
  }
}