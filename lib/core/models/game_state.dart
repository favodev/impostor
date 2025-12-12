import 'player.dart';
import 'category.dart';

enum GamePhase {
  setup,
  roleReveal,
  debate,
  voting,
  results,
}

class GameState {
  final List<Player> players;
  final List<Category> selectedCategories;
  final int impostorCount;
  final String? secretWord;
  final String? secretHint;
  final Category? selectedCategory;
  final GamePhase phase;
  final int currentPlayerIndex;
  final int? timerDuration;
  final bool impostorSeesHint;

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

  bool get isValidSetup {
    return players.length >= 3 &&
        selectedCategories.isNotEmpty &&
        impostorCount >= 1 &&
        impostorCount < players.length;
  }

  Player? get currentPlayer {
    if (currentPlayerIndex < players.length) {
      return players[currentPlayerIndex];
    }
    return null;
  }

  bool get allPlayersHaveSeenRole {
    return players.every((p) => p.hasSeenRole);
  }

  List<Player> get activePlayers {
    return players.where((p) => !p.isEliminated).toList();
  }

  List<Player> get impostors {
    return players.where((p) => p.isImpostor).toList();
  }

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
