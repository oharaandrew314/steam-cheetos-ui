class UserDto {
  final String id;
  final String name;
  final Uri? avatar;

  UserDto({required this.id, required this.name, required this.avatar});

  @override
  String toString() => 'User $name: $avatar';
}

class GameDto {
  final String id;
  final String name;
  final int? achievementsTotal;
  final int? achievementsCurrent;
  final Uri displayImage;
  final DateTime achievementsExpire;
  final bool favourite;

  GameDto({
    required this.id,
    required this.name,
    required this.achievementsTotal,
    required this.achievementsCurrent,
    required this.displayImage,
    required this.achievementsExpire,
    required this.favourite
  });

  double getCompletion() => achievementsTotal == null || achievementsCurrent == null ? 0 : achievementsCurrent!.toDouble() / achievementsTotal!;
  bool isCompleted() => achievementsTotal != null && achievementsTotal! > 0 && achievementsCurrent == achievementsTotal;
  bool isInProgress() => achievementsTotal != null && achievementsCurrent != achievementsTotal;
  bool isAchievementsExpired() => achievementsExpire.isBefore(DateTime.now());
  bool hasLoadedAchievements() => achievementsTotal != null;
  bool shouldLoadAchievements() {
    if (!hasLoadedAchievements()) return true;
    return achievementsExpire.isAfter(DateTime.now());
  }
  bool hasAchievements() {
    return achievementsTotal != null && achievementsTotal! > 0;
  }
  bool hasNoAchievements() {
    return achievementsTotal == 0;
  }
  GameDto withAchievementCounts(List<AchievementDtoV1> achievements) => GameDto(
      id: id,
      name: name,
      achievementsTotal: achievements.length,
      achievementsCurrent: achievements.where((a) => a.unlocked).length,
      displayImage: displayImage,
      achievementsExpire: achievementsExpire,
      favourite: favourite
  );

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

  @override
  String toString() => '($id) $unlocked';
}

class AchievementStatusDto {
  final String id;
  final DateTime? unlockedOn;
  final bool unlocked;

  const AchievementStatusDto({
    required this.id,
    required this.unlocked,
    required this.unlockedOn
  });

  @override
  String toString() => '($id) $unlocked';
}