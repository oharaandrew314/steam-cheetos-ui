class UserDto {
  final String name;
  final Uri? avatar;

  UserDto({required this.name, required this.avatar});

  @override
  String toString() => 'User $name: $avatar';
}