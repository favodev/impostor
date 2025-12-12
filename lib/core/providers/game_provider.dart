import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/game_state.dart';
import '../models/player.dart';

/// Motor lógico del juego - Game Engine
///
/// Responsable de:
/// - Asignación aleatoria de roles (ciudadanos vs impostores)
/// - Selección de categoría y palabra secreta
/// - Gestión del flujo del juego
///
/// ALGORITMO DE ASIGNACIÓN ALEATORIA:
/// 1. Se usa Random.secure() para máxima entropía (criptográficamente seguro)
/// 2. Se baraja la lista de jugadores usando Fisher-Yates shuffle
/// 3. Los primeros N jugadores (N = impostorCount) son asignados como impostores
/// 4. Esto garantiza distribución uniforme y verdaderamente impredecible
class GameEngine {
  static final Random _secureRandom = Random.secure();

  static List<T> _shuffle<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    for (int i = shuffled.length - 1; i > 0; i--) {
      // Genera índice aleatorio entre 0 e i (inclusive)
      final j = _secureRandom.nextInt(i + 1);
      // Intercambia elementos
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    return shuffled;
  }

  /// Selecciona una categoría aleatoria de las categorías seleccionadas
  static Category selectRandomCategory(List<Category> categories) {
    if (categories.isEmpty) {
      throw ArgumentError('Debe haber al menos una categoría seleccionada');
    }
    final index = _secureRandom.nextInt(categories.length);
    return categories[index];
  }

  /// Selecciona una palabra aleatoria de la categoría y retorna la SecretWord completa
  static SecretWord selectRandomSecretWord(Category category) {
    if (category.secretWords.isEmpty) {
      throw ArgumentError('La categoría debe tener al menos una palabra');
    }
    final index = _secureRandom.nextInt(category.secretWords.length);
    return category.secretWords[index];
  }

  /// Selecciona una palabra aleatoria de la categoría (solo el texto)
  static String selectRandomWord(Category category) {
    return selectRandomSecretWord(category).word;
  }

  /// Asigna roles a los jugadores
  ///
  /// PROCESO:
  /// 1. Baraja aleatoriamente la lista de jugadores
  /// 2. Los primeros [impostorCount] jugadores se convierten en impostores
  /// 3. El resto son ciudadanos
  /// 4. Retorna la lista en orden original pero con roles asignados
  static List<Player> assignRoles(List<Player> players, int impostorCount) {
    if (players.length < 3) {
      throw ArgumentError('Se necesitan al menos 3 jugadores');
    }
    if (impostorCount < 1 || impostorCount >= players.length) {
      throw ArgumentError('Número de impostores inválido');
    }

    // Crear lista de índices y barajar
    final indices = List.generate(players.length, (i) => i);
    final shuffledIndices = _shuffle(indices);

    // Crear set de índices que serán impostores
    final impostorIndices = shuffledIndices.take(impostorCount).toSet();

    // Asignar roles manteniendo el orden original
    return players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      return player.copyWith(
        isImpostor: impostorIndices.contains(index),
        hasSeenRole: false, // Resetear para nueva partida
        isEliminated: false,
      );
    }).toList();
  }

  /// Inicializa un nuevo juego con todos los parámetros
  static GameState initializeGame({
    required List<Player> players,
    required List<Category> selectedCategories,
    required int impostorCount,
    int? timerDuration,
    bool impostorSeesHint = true,
  }) {
    // Seleccionar categoría aleatoria
    final category = selectRandomCategory(selectedCategories);

    // Seleccionar palabra secreta con su pista
    final secretWordData = selectRandomSecretWord(category);

    // Asignar roles
    final playersWithRoles = assignRoles(players, impostorCount);

    // Barajar orden de revelación para más aleatoriedad
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

/// Provider del estado del juego
/// Usa StateNotifier para manejo inmutable del estado
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((
  ref,
) {
  return GameStateNotifier();
});

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(const GameState());

  /// Agrega un nuevo jugador
  void addPlayer(String name) {
    if (name.trim().isEmpty) return;
    final player = Player.create(name);
    state = state.copyWith(players: [...state.players, player]);
  }

  /// Elimina un jugador por ID
  void removePlayer(String playerId) {
    state = state.copyWith(
      players: state.players.where((p) => p.id != playerId).toList(),
    );
  }

  /// Actualiza las categorías seleccionadas
  void updateSelectedCategories(List<Category> categories) {
    state = state.copyWith(selectedCategories: categories);
  }

  /// Actualiza el número de impostores
  void setImpostorCount(int count) {
    // Asegurarse de que el count es válido
    final maxImpostors = (state.players.length - 1).clamp(1, 10);
    state = state.copyWith(impostorCount: count.clamp(1, maxImpostors));
  }

  /// Establece la duración del timer (en segundos)
  void setTimerDuration(int? duration) {
    state = state.copyWith(timerDuration: duration);
  }

  /// Configura si el impostor ve la pista
  void setImpostorSeesHint(bool value) {
    state = state.copyWith(impostorSeesHint: value);
  }

  /// Inicia el juego con la configuración actual
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

  /// Marca que el jugador actual ha visto su rol
  void currentPlayerSawRole() {
    final updatedPlayers = state.players.map((player) {
      if (player.id == state.currentPlayer?.id) {
        return player.copyWith(hasSeenRole: true);
      }
      return player;
    }).toList();

    state = state.copyWith(players: updatedPlayers);
  }

  /// Avanza al siguiente jugador en la fase de revelación
  void nextPlayer() {
    if (state.currentPlayerIndex < state.players.length - 1) {
      state = state.copyWith(currentPlayerIndex: state.currentPlayerIndex + 1);
    } else {
      // Todos han visto su rol, pasar a fase de debate
      state = state.copyWith(phase: GamePhase.debate);
    }
  }

  /// Elimina un jugador durante la votación
  void eliminatePlayer(String playerId) {
    final updatedPlayers = state.players.map((player) {
      if (player.id == playerId) {
        return player.copyWith(isEliminated: true);
      }
      return player;
    }).toList();

    state = state.copyWith(players: updatedPlayers);
  }

  /// Restaura un jugador eliminado
  void restorePlayer(String playerId) {
    final updatedPlayers = state.players.map((player) {
      if (player.id == playerId) {
        return player.copyWith(isEliminated: false);
      }
      return player;
    }).toList();

    state = state.copyWith(players: updatedPlayers);
  }

  /// Cambia a la fase de resultados
  void showResults() {
    state = state.copyWith(phase: GamePhase.results);
  }

  /// Reinicia el juego manteniendo los jugadores previos (caché)
  void resetGame() {
    // Mantener jugadores pero resetear sus estados
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

  /// Reinicia solo la partida actual manteniendo jugadores y categorías
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

/// Provider para las categorías disponibles
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

  /// Alterna la selección de una categoría
  void toggleCategory(String categoryId) {
    state = state.map((category) {
      if (category.id == categoryId) {
        return category.copyWith(isSelected: !category.isSelected);
      }
      return category;
    }).toList();
  }

  /// Selecciona todas las categorías
  void selectAll() {
    state =
        state.map((category) => category.copyWith(isSelected: true)).toList();
  }

  /// Deselecciona todas las categorías
  void deselectAll() {
    state =
        state.map((category) => category.copyWith(isSelected: false)).toList();
  }

  /// Obtiene las categorías seleccionadas
  List<Category> get selectedCategories {
    return state.where((c) => c.isSelected).toList();
  }
}
