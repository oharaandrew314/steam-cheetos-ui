import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/views/widgets/achievement.dart';
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

  List<AchievementDtoV1> _achievements = [];
  int _pageIndex = 0;
  String _searchTerm = "";
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
    _loadAchievements();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  Future _loadAchievements() async {
    setState(() {
      _loading = true;
    });
    final achievements = await widget.client.listAchievements(widget.game.id);
    setState(() {
      _achievements = achievements;
      _loading = false;
    });
  }

  void _onNavbarTap(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  bool Function(AchievementDtoV1) _pageFilter() => (a) {
    switch(_pageIndex) {
      case lockedPage: return !a.unlocked;
      case unlockedPage: return a.unlocked;
      default: return a.unlocked;
    }
  };

  Widget _buildList(BuildContext context) {
    var results = _achievements
        .where(_pageFilter())
        .toList();

    if (_searchTerm.isNotEmpty) {
      results = extractAllSorted<AchievementDtoV1>(
          query: _searchTerm,
          choices: results,
          getter: (achievement) => achievement.name,
          cutoff: 85
      ).map((e) => e.choice).toList();
    }

    if (_pageIndex == unlockedPage) {
      results.sort(compareAchievementUnlockedOn());
    }

    if (results.isEmpty) {
      return ListView(
        children: [_buildPlaceholder(context)],
      );
    }

    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: results.length,
        itemBuilder: (BuildContext context, int index) {
          final achievement = results[index];
          return Achievement(widget.game, achievement);
        }
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (_loading) return Container();

    if (_searchTerm.isNotEmpty) {
      return Column(
        children: [
          const Icon(
            Icons.question_mark,
            color: Colors.orange,
            size: 128
          ),
          Text(
              "No achievements found",
              style: Theme.of(context).textTheme.titleMedium,
          )
        ],
      );
    }

    switch(_pageIndex) {
      case unlockedPage: {
        return Column(
          children: [
            const Icon(
              Icons.clear,
              color: Colors.red,
              size: 128,
            ),
            Text(
              "You haven't unlocked anything :(",
              style: Theme.of(context).textTheme.titleMedium,
            )
          ]
        );
      }
      case lockedPage: {
        return Column(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 128,
            ),
            Text(
                "You've unlocked everything!",
                style: Theme.of(context).textTheme.titleMedium,
            )
          ],
        );
      }
      default: return const Text("You shouldn't be here!");
    }
  }

  Widget _bottomNavigation() => BottomNavigationBar(
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
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchBar(placeholder: widget.game.name, controller: _searchController),
        actions: [UserMenu(user: widget.user)],
      ),
      body: Center(
        child: DeclarativeRefreshIndicator(
          refreshing: _loading,
          child: _buildList(context),
          onRefresh: _loadAchievements
        )
      ),
      bottomNavigationBar: _bottomNavigation()
    );
  }
}