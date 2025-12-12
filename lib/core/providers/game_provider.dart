import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/game_state.dart';
import '../models/player.dart';

class GameEngine {
  static final Random _secureRandom = Random.secure();

  static List<T> _shuffle<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = _secureRandom.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    return shuffled;
  }

  static Category selectRandomCategory(List<Category> categories) {
    if (categories.isEmpty) {
      throw ArgumentError('Debe haber al menos una categoría seleccionada');
    }
    final index = _secureRandom.nextInt(categories.length);
    return categories[index];
  }

  static SecretWord selectRandomSecretWord(Category category) {
    if (category.secretWords.isEmpty) {
      throw ArgumentError('La categoría debe tener al menos una palabra');
    }
    final index = _secureRandom.nextInt(category.secretWords.length);
    return category.secretWords[index];
  }

  static String selectRandomWord(Category category) {
    return selectRandomSecretWord(category).word;
  }

  static List<Player> assignRoles(List<Player> players, int impostorCount) {
    if (players.length < 3) {
      throw ArgumentError('Se necesitan al menos 3 jugadores');
    }
    if (impostorCount < 1 || impostorCount >= players.length) {
      throw ArgumentError('Número de impostores inválido');
    }

    final indices = List.generate(players.length, (i) => i);
    final shuffledIndices = _shuffle(indices);
    final impostorIndices = shuffledIndices.take(impostorCount).toSet();

    return players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      return player.copyWith(
        isImpostor: impostorIndices.contains(index),
        hasSeenRole: false,
        isEliminated: false,
      );
    }).toList();
  }

  static GameState initializeGame({
    required List<Player> players,
    required List<Category> selectedCategories,
    required int impostorCount,
    int? timerDuration,
    bool impostorSeesHint = true,
  }) {
    final category = selectRandomCategory(selectedCategories);
    final secretWordData = selectRandomSecretWord(category);
    final playersWithRoles = assignRoles(players, impostorCount);
    final shuffledPlayers = _shuffle(playersWithRoles);

    return GameState(
      players: shuffledPlayers,
      selectedCategories: selectedCategories,
      impostorCount: impostorCount,
      secretWord: secretWordData.word,
      secretHint: secretWordData.hint,
      selectedCategory: category,
      phase: GamePhase.roleReveal,
      currentPlayerIndex: 0,
      timerDuration: timerDuration,
      impostorSeesHint: impostorSeesHint,
    );
  }
}

final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((
  ref,
) {
  return GameStateNotifier();
});

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(const GameState());

  void addPlayer(String name) {
    if (name.trim().isEmpty) return;
    final player = Player.create(name);
    state = state.copyWith(players: [...state.players, player]);
  }

  void removePlayer(String playerId) {
    state = state.copyWith(
      players: state.players.where((p) => p.id != playerId).toList(),
    );
  }

  void updateSelectedCategories(List<Category> categories) {
    state = state.copyWith(selectedCategories: categories);
  }

  void setImpostorCount(int count) {
    final maxImpostors = (state.players.length - 1).clamp(1, 10);
    state = state.copyWith(impostorCount: count.clamp(1, maxImpostors));
  }

  void setTimerDuration(int? duration) {
    state = state.copyWith(timerDuration: duration);
  }

  void setImpostorSeesHint(bool value) {
    state = state.copyWith(impostorSeesHint: value);
  }

  void startGame() {
    if (!state.isValidSetup) return;

    final newState = GameEngine.initializeGame(
      players: state.players,
      selectedCategories: state.selectedCategories,
      impostorCount: state.impostorCount,
      timerDuration: state.timerDuration,
      impostorSeesHint: state.impostorSeesHint,
    );

    state = newState;
  }

  void currentPlayerSawRole() {
    final updatedPlayers = state.players.map((player) {
      if (player.id == state.currentPlayer?.id) {
        return player.copyWith(hasSeenRole: true);
      }
      return player;
    }).toList();

    state = state.copyWith(players: updatedPlayers);
  }

  void nextPlayer() {
    if (state.currentPlayerIndex < state.players.length - 1) {
      state = state.copyWith(currentPlayerIndex: state.currentPlayerIndex + 1);
    } else {
      state = state.copyWith(phase: GamePhase.debate);
    }
  }

  void eliminatePlayer(String playerId) {
    final updatedPlayers = state.players.map((player) {
      if (player.id == playerId) {
        return player.copyWith(isEliminated: true);
      }
      return player;
    }).toList();

    state = state.copyWith(players: updatedPlayers);
  }

  void restorePlayer(String playerId) {
    final updatedPlayers = state.players.map((player) {
      if (player.id == playerId) {
        return player.copyWith(isEliminated: false);
      }
      return player;
    }).toList();

    state = state.copyWith(players: updatedPlayers);
  }

  void showResults() {
    state = state.copyWith(phase: GamePhase.results);
  }

  void resetGame() {
    final cachedPlayers = state.players
        .map(
          (p) => p.copyWith(
            isImpostor: false,
            hasSeenRole: false,
            isEliminated: false,
          ),
        )
        .toList();

    state = GameState(
      players: cachedPlayers,
      selectedCategories: state.selectedCategories,
      impostorCount: state.impostorCount,
      impostorSeesHint: state.impostorSeesHint,
      phase: GamePhase.setup,
    );
  }

  void newRound() {
    state = state.copyWith(
      phase: GamePhase.setup,
      currentPlayerIndex: 0,
      secretWord: null,
      selectedCategory: null,
      players: state.players
          .map(
            (p) => p.copyWith(
              isImpostor: false,
              hasSeenRole: false,
              isEliminated: false,
            ),
          )
          .toList(),
    );
  }
}

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
  return CategoriesNotifier();
});

class CategoriesNotifier extends StateNotifier<List<Category>> {
  CategoriesNotifier()
      : super(
          PredefinedCategories.all
              .map((c) => c.copyWith(isSelected: true))
              .toList(),
        );

  void toggleCategory(String categoryId) {
    state = state.map((category) {
      if (category.id == categoryId) {
        return category.copyWith(isSelected: !category.isSelected);
      }
      return category;
    }).toList();
  }

  void selectAll() {
    state =
        state.map((category) => category.copyWith(isSelected: true)).toList();
  }

  void deselectAll() {
    state =
        state.map((category) => category.copyWith(isSelected: false)).toList();
  }

  List<Category> get selectedCategories {
    return state.where((c) => c.isSelected).toList();
  }
}
