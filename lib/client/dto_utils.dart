import 'dtos.dart';

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