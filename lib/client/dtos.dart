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
  final int? achievementsTotal;
  final int? achievementsCurrent;
  final Uri displayImage;
  final DateTime achievementsExpire;

  GameDto({
    required this.id,
    required this.name,
    required this.achievementsTotal,
    required this.achievementsCurrent,
    required this.displayImage,
    required this.achievementsExpire
  });

  double getCompletion() => achievementsTotal == null || achievementsCurrent == null ? 0 : achievementsCurrent!.toDouble() / achievementsTotal!;
  bool isCompleted() => achievementsTotal != null && achievementsCurrent == achievementsTotal;
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

int Function(GameDto, GameDto) compareGameCompletionDesc() => (game1, game2) {
  return game2.getCompletion().compareTo(game1.getCompletion());
};

int Function(GameDto, GameDto) compareGameName() => (game1, game2) {
  return game1.name.compareTo(game2.name);
};

int Function(AchievementDtoV1, AchievementDtoV1) compareAchievementCompleted() => (a1, a2) {
  if (a1.unlocked == a2.unlocked) {
    return 0;
  }

  return a1.unlocked ? 1 : 0;
};

int Function(AchievementDtoV1, AchievementDtoV1) compareAchievementId() => (a1, a2) {
  return a1.id.compareTo(a2.id);
};

int Function(AchievementDtoV1, AchievementDtoV1) compareAchievementUnlockedOn() => (a1, a2) {
  if (a1.unlockedOn == null && a2.unlockedOn == null) return 0;
  if (a1.unlockedOn == null) return 1;
  if (a2.unlockedOn == null) return 0;
  return a2.unlockedOn!.compareTo(a1.unlockedOn!);
};

int Function(T, T) chained<T>(int Function(T, T) first, int Function(T, T) second) => (i1, i2) {
  final result1 = first(i1, i2);
  if (result1 == 0) return result1;

  return second(i1, i2);
};