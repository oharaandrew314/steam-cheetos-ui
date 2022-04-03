class UserDto {
  final String name;
  final Uri? avatar;

  UserDto({required this.name, required this.avatar});

  @override
  String toString() => 'User $name: $avatar';
}

class GameDto {
  final String id;
  final String name;
  final int achievementsTotal;
  final int achievementsCurrent;
  final Uri? displayImage;
  final DateTime? lastUpdated;

  GameDto({
    required this.id,
    required this.name,
    required this.achievementsTotal,
    required this.achievementsCurrent,
    required this.displayImage,
    required this.lastUpdated
  });

  double getCompletion() => achievementsCurrent.toDouble() / achievementsTotal;
  bool isCompleted() => achievementsCurrent == achievementsTotal;

  @override
  String toString() => 'Game [$id] $name ($achievementsCurrent of $achievementsTotal)';
}