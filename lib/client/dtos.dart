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

class AchievementDtoV1 {
  final String id;
  final String name;
  final String? description;
  final bool hidden;
  final Uri? iconLocked;
  final Uri? iconUnlocked;
  final DateTime? unlockedOn;
  final bool unlocked;

  const AchievementDtoV1({
    required this.id,
    required this.name,
    required this.description,
    required this.hidden,
    required this.iconLocked,
    required this.iconUnlocked,
    required this.unlockedOn,
    required this.unlocked
  });
}