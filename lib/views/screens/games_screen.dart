import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:steamcheetos_flutter/client/games_client.dart';
import 'package:steamcheetos_flutter/client/dtos.dart';
import 'package:steamcheetos_flutter/views/screens/achievements_screen.dart';
import 'package:steamcheetos_flutter/views/widgets/game.dart';
import 'package:steamcheetos_flutter/views/widgets/search_bar.dart';
import 'package:steamcheetos_flutter/views/widgets/user.dart';

const incompletePage = 0;
const finishedPage = 1;

class GamesScreen extends StatefulWidget {

  final GamesClient client;
  final UserDto user;

  const GamesScreen({required this.client, required this.user, Key? key}) : super(key: key);

  @override
  State<GamesScreen> createState() => _GamesScreenState();

  static Route createRoute(UserDto user, GamesClient client) => PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GamesScreen(
      user: user,
      client: client,
    ),
  );
}

class _GamesScreenState extends State<GamesScreen> {
  final _searchController = TextEditingController();

  List<GameDto> _games = [];
  String _searchTerm = "";
  bool _loading = false;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
    _loadGames();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  Future _loadGames() async {
    setState(() {
      _loading = true;
    });

    final games = await widget.client.listGames();
    setState(() {
      _games = games;
      _loading = false;
    });
  }

  void _handlePressGame(BuildContext context, GameDto game) {
    Navigator.push(context, AchievementsScreen.createRoute(widget.client, widget.user, game));
  }

  void _onNavbarTap(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  bool Function(GameDto) _pageFilter() => (a) {
    switch(_pageIndex) {
      case incompletePage: return !a.isCompleted();
      case finishedPage: return a.isCompleted();
      default: return false;
    }
  };

  Widget _buildGameList(BuildContext context) {
    var results = _games
        .where(_pageFilter())
        .toList();

    if (_searchTerm.isNotEmpty) {
      results = extractAllSorted<GameDto>(
          query:  _searchTerm,
          choices: _games,
          getter: (game) => game.name,
          cutoff: 85
      ).map((e) => e.choice).toList();
    }

    if (results.isEmpty) {
      return ListView(
        children: [_buildPlaceholder()],
      );
    }

    results.sort(compareGameCompletionDesc());

    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: results.length,  // TODO add limit with warning at bottom
        itemBuilder: (BuildContext context, int index) {
          final game = results[index];
          return GameSummary(
              game: game,
              handlePress: () => _handlePressGame(context, game)
          );
        });
  }

  Widget _buildPlaceholder() {
    if (_loading) return Container();

    return Column(
      children: [
        const Icon(
          Icons.question_mark,
          color: Colors.orange,
          size: 128,
        ),
        Text(
          "No games Found",
          style: Theme
              .of(context)
              .textTheme
              .titleMedium,
        )
      ],
    );
  }

  Widget _bottomNavigation() => BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.clear),
        label: 'In Progress',
      ),
      BottomNavigationBarItem(
          icon: Icon(Icons.check_circle),
          label: 'Finished'
      ),
    ],
    currentIndex: _pageIndex,
    onTap: _onNavbarTap,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: SearchBar(placeholder: 'Games', controller: _searchController),
          actions: [UserMenu(user: widget.user)]
      ),
      body: Center(
        child: DeclarativeRefreshIndicator(
            refreshing: _loading,
            child: _buildGameList(context),
            onRefresh: _loadGames
        ),
      ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }
}

