import 'player.dart';
import 'category.dart';

/// Enum que representa las fases del juego
enum GamePhase {
  setup, // Configuración inicial
  roleReveal, // Revelación de roles (pass-the-device)
  debate, // Fase de debate y discusión
  voting, // Fase de votación
  results, // Resultados finales
}

/// Estado completo del juego
///
/// Implementa el patrón State para manejar las diferentes fases
/// Inmutable para optimizar rebuilds y evitar side effects
class GameState {
  final List<Player> players;
  final List<Category> selectedCategories;
  final int impostorCount;
  final String? secretWord;
  final String? secretHint; // Palabra relacionada como pista para el impostor
  final Category? selectedCategory;
  final GamePhase phase;
  final int currentPlayerIndex;
  final int? timerDuration; // En segundos, null = sin timer
  final bool impostorSeesHint; // Si el impostor ve la pista o nada

  const GameState({
    this.players = const [],
    this.selectedCategories = const [],
    this.impostorCount = 1,
    this.secretWord,
    this.secretHint,
    this.selectedCategory,
    this.phase = GamePhase.setup,
    this.currentPlayerIndex = 0,
    this.timerDuration,
    this.impostorSeesHint = true,
  });

  /// Verifica si la configuración es válida para iniciar el juego
  bool get isValidSetup {
    return players.length >= 3 &&
        selectedCategories.isNotEmpty &&
        impostorCount >= 1 &&
        impostorCount < players.length;
  }

  /// Obtiene el jugador actual en la fase de revelación
  Player? get currentPlayer {
    if (currentPlayerIndex < players.length) {
      return players[currentPlayerIndex];
    }
    return null;
  }

  /// Verifica si todos los jugadores han visto su rol
  bool get allPlayersHaveSeenRole {
    return players.every((p) => p.hasSeenRole);
  }

  /// Obtiene los jugadores que aún no han sido eliminados
  List<Player> get activePlayers {
    return players.where((p) => !p.isEliminated).toList();
  }

  /// Obtiene los impostores
  List<Player> get impostors {
    return players.where((p) => p.isImpostor).toList();
  }

  /// Obtiene los ciudadanos (no impostores)
  List<Player> get citizens {
    return players.where((p) => !p.isImpostor).toList();
  }

  GameState copyWith({
    List<Player>? players,
    List<Category>? selectedCategories,
    int? impostorCount,
    String? secretWord,
    String? secretHint,
    Category? selectedCategory,
    GamePhase? phase,
    int? currentPlayerIndex,
    int? timerDuration,
    bool? impostorSeesHint,
  }) {
    return GameState(
      players: players ?? this.players,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      impostorCount: impostorCount ?? this.impostorCount,
      secretWord: secretWord ?? this.secretWord,
      secretHint: secretHint ?? this.secretHint,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      phase: phase ?? this.phase,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      timerDuration: timerDuration ?? this.timerDuration,
      impostorSeesHint: impostorSeesHint ?? this.impostorSeesHint,
    );
  }
}
