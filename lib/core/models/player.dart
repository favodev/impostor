/// Modelo que representa un jugador en el juego
///
/// Implementa inmutabilidad para mejor rendimiento con Riverpod
/// y evitar efectos secundarios no deseados (principio SOLID - SRP)
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

  /// Factory para crear un nuevo jugador con ID único
  factory Player.create(String name) {
    return Player(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
    );
  }

  /// Crea una copia del jugador con los campos modificados
  /// Patrón inmutable para optimizar rebuilds en Flutter
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
