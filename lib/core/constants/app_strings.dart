abstract class AppStrings {
  // App Info
  static const String appName = 'IMPOSTOR';
  static const String appSubtitle = '¿Quién es el espía?';

  // Roles
  static const String roleImpostor = 'IMPOSTOR';
  static const String roleCitizen = 'CIUDADANO';
  static const String impostorWarning = '¡IMPOSTOR!';
  static const String impostorHint = 'Shhh...';
  static const String impostorAdvice =
      'Intenta descubrir la palabra secreta\nsin que te descubran';
  static const String noHint = 'No tienes ninguna pista';

  // Setup Screen
  static const String players = 'Jugadores';
  static const String categories = 'Categorías';
  static const String settings = 'Configuración';
  static const String playerNameHint = 'Nombre del jugador';
  static const String minPlayersRequired = 'Se necesitan al menos 3 jugadores';
  static const String selectCategoryRequired =
      'Selecciona al menos una categoría';
  static const String addMorePlayers = 'Agrega más jugadores para ajustar';
  static const String impostorCount = 'Impostores:';
  static const String impostorSeesCategory = 'Impostor ve la categoría';
  static const String impostorSeesCategoryOn =
      'El impostor verá la categoría general';
  static const String impostorSeesCategoryOff =
      'El impostor no tendrá ninguna pista';
  static const String startGame = 'INICIAR PARTIDA';
  static const String selectAll = 'Todas';
  static const String deselectAll = 'Ninguna';

  // Role Reveal Screen
  static const String roleReveal = 'REVELACIÓN DE ROLES';
  static const String turnOf = 'Turno de';
  static const String holdToReveal = 'MANTENER\nPRESIONADO';
  static const String roleSeen = 'Rol visto';
  static const String nextPlayer = 'SIGUIENTE JUGADOR';
  static const String startDebate = 'COMENZAR DEBATE';
  static const String privacyWarning =
      'Asegúrate de que nadie más vea la pantalla';
  static const String preparingNextPlayer = 'Preparando siguiente jugador...';
  static const String yourWordIs = 'Tu palabra es:';
  static const String categoryHint = 'Categoría:';

  // Debate Screen
  static const String debatePhase = 'FASE DE DEBATE';
  static const String debateTimer = 'Timer de debate';
  static const String optional = '(Opcional)';
  static const String noTimer = 'Sin timer';
  static const String start = 'Iniciar';
  static const String timeUp = '¡TIEMPO!';
  static const String timeUpMessage = 'El tiempo de debate ha terminado.';
  static const String moreTime = 'Más tiempo';
  static const String continueGame = 'Continuar';
  static const String eliminated = 'ELIMINADO';
  static const String newRound = 'Nueva ronda';
  static const String revealAll = 'REVELAR TODOS';
  static const String revealIdentities = 'Revelar identidades';
  static const String revealConfirmation =
      '¿Estás seguro de que quieres revelar las identidades de todos los jugadores?\n\nEsto terminará la partida.';
  static const String newRoundConfirmation =
      '¿Quieres iniciar una nueva ronda con los mismos jugadores y categorías?';
  static const String cancel = 'Cancelar';
  static const String reveal = 'Revelar';

  // Results Screen
  static const String results = 'RESULTADOS';
  static const String gameOver = '¡La partida ha terminado!';
  static const String secretWordWas = 'La palabra secreta era:';
  static const String revealRoles = 'REVELAR ROLES';
  static const String impostors = 'IMPOSTORES';
  static const String citizens = 'CIUDADANOS';
  static const String newGame = 'Nuevo juego';

  // Categories
  static const String categoryFood = 'Comida';
  static const String categoryPlaces = 'Lugares';
  static const String categoryAnimals = 'Animales';
  static const String categoryTechnology = 'Tecnología';
  static const String categoryMovies = 'Cine';
  static const String categorySports = 'Deportes';
  static const String categoryProfessions = 'Profesiones';
  static const String categoryCountries = 'Países';

  // Validation Messages
  static const String minThreePlayers = 'mín. 3';
  static String categoriesSelected(int count) =>
      '$count categorías seleccionadas';
  static String playerCount(int current, int min) => '$current / $min';
  static String impostorLabel(int count) =>
      '$count impostor${count > 1 ? "es" : ""}';
}
