class Player {
  final String id;
  final String name;
  final bool isImpostor;
  final bool hasSeenRole;
  final bool isEliminated;

  const Player({
    required this.id,
    required this.name,
    this.isImpostor = false,
    this.hasSeenRole = false,
    this.isEliminated = false,
  });

  factory Player.create(String name) {
    return Player(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
    );
  }

  Player copyWith({
    String? id,
    String? name,
    bool? isImpostor,
    bool? hasSeenRole,
    bool? isEliminated,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      isImpostor: isImpostor ?? this.isImpostor,
      hasSeenRole: hasSeenRole ?? this.hasSeenRole,
      isEliminated: isEliminated ?? this.isEliminated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
