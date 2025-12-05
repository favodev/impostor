import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'debate_screen.dart';

/// Pantalla de revelación de roles (Pass-the-Device)
///
/// Implementa el flujo de pasar el dispositivo donde cada jugador:
/// 1. Ve su nombre en pantalla
/// 2. Mantiene presionado para ver su rol
/// 3. Suelta y la pantalla vuelve a estado neutro
/// 4. Pasa el dispositivo al siguiente jugador
class RoleRevealScreen extends ConsumerStatefulWidget {
  const RoleRevealScreen({super.key});

  @override
  ConsumerState<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends ConsumerState<RoleRevealScreen>
    with TickerProviderStateMixin {
  bool _isRevealing = false;
  bool _hasSeenRole = false;
  bool _isTransitioning = false; // Estado de transición para evitar flicker

  // Controladores de animación
  late AnimationController _pulseController;
  late AnimationController _revealController;
  late AnimationController _impostorGlowController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _revealAnimation;
  late Animation<double> _impostorGlowAnimation;

  @override
  void initState() {
    super.initState();

    // Animación de pulso para el botón "mantener presionado"
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animación de revelación
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    );

    // Animación de brillo para impostor
    _impostorGlowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _impostorGlowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _impostorGlowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _revealController.dispose();
    _impostorGlowController.dispose();
    super.dispose();
  }

  Future<void> _onRevealStart() async {
    if (_hasSeenRole) return;

    setState(() => _isRevealing = true);
    _revealController.forward();

    final currentPlayer = ref.read(gameStateProvider).currentPlayer;

    // Vibración si es impostor
    if (currentPlayer?.isImpostor ?? false) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Patrón de vibración intenso para impostor
        Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 200]);
      }
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  void _onRevealEnd() {
    if (!_isRevealing) return;

    setState(() {
      _isRevealing = false;
      _hasSeenRole = true;
    });
    _revealController.reverse();

    // Marcar que el jugador vio su rol
    ref.read(gameStateProvider.notifier).currentPlayerSawRole();
  }

  void _nextPlayer() async {
    final gameState = ref.read(gameStateProvider);

    if (gameState.currentPlayerIndex < gameState.players.length - 1) {
      // Estado de transición para evitar flicker
      setState(() => _isTransitioning = true);

      // Esperar a que la animación de salida termine
      await Future.delayed(const Duration(milliseconds: 200));

      // Verificar que el widget siga montado
      if (!mounted) return;

      ref.read(gameStateProvider.notifier).nextPlayer();
      setState(() {
        _hasSeenRole = false;
        _isTransitioning = false;
      });
      HapticFeedback.lightImpact();
    } else {
      // Todos han visto su rol, ir a fase de debate
      ref.read(gameStateProvider.notifier).nextPlayer();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DebateScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final currentPlayer = gameState.currentPlayer;

    if (currentPlayer == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Column(
            children: [
              // Header con progreso
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'REVELACIÓN DE ROLES',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryNeon,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(height: 16),
                    PlayerProgressIndicator(
                      current: gameState.currentPlayerIndex,
                      total: gameState.players.length,
                    ),
                  ],
                ),
              ),

              // Contenido principal
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isTransitioning
                        ? _buildTransitionState() // Pantalla neutra durante transición
                        : _isRevealing
                            ? _buildRoleReveal(currentPlayer, gameState)
                            : _buildWaitingState(currentPlayer),
                  ),
                ),
              ),

              // Botón siguiente (solo visible después de ver el rol)
              Padding(
                padding: const EdgeInsets.all(24),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _hasSeenRole ? 1.0 : 0.0,
                  child: IgnorePointer(
                    ignoring: !_hasSeenRole,
                    child: NeonButton(
                      text: gameState.currentPlayerIndex <
                              gameState.players.length - 1
                          ? 'SIGUIENTE JUGADOR'
                          : 'COMENZAR DEBATE',
                      icon: gameState.currentPlayerIndex <
                              gameState.players.length - 1
                          ? Icons.arrow_forward
                          : Icons.forum,
                      expanded: true,
                      color: AppTheme.accentNeon,
                      onPressed: _nextPlayer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Estado de transición - pantalla neutra para evitar flicker
  Widget _buildTransitionState() {
    return Container(
      key: const ValueKey('transition'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(AppTheme.primaryNeon),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Preparando siguiente jugador...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  /// Estado de espera - muestra el nombre del jugador
  Widget _buildWaitingState(Player player) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Nombre del jugador
        Text(
          'Turno de',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          player.name.toUpperCase(),
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppTheme.primaryNeon,
            shadows: [
              Shadow(
                color: AppTheme.primaryNeon.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),

        // Botón de revelación
        if (!_hasSeenRole)
          GestureDetector(
            onLongPressStart: (_) => _onRevealStart(),
            onLongPressEnd: (_) => _onRevealEnd(),
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cardDark,
                      border: Border.all(color: AppTheme.primaryNeon, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryNeon.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 48,
                          color: AppTheme.primaryNeon,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'MANTENER\nPRESIONADO',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: AppTheme.primaryNeon),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.accentNeon.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentNeon),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppTheme.accentNeon),
                const SizedBox(width: 12),
                Text(
                  'Rol visto',
                  style: TextStyle(
                    color: AppTheme.accentNeon,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),
        if (!_hasSeenRole)
          Text(
            'Asegúrate de que nadie más vea la pantalla',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
          ),
      ],
    );
  }

  /// Estado de revelación - muestra el rol
  Widget _buildRoleReveal(Player player, GameState gameState) {
    if (player.isImpostor) {
      return _buildImpostorReveal(gameState);
    } else {
      return _buildCitizenReveal(gameState);
    }
  }

  /// Revelación para ciudadano - muestra la palabra secreta
  Widget _buildCitizenReveal(GameState gameState) {
    return FadeTransition(
      opacity: _revealAnimation,
      child: ScaleTransition(
        scale: _revealAnimation,
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: AppTheme.neonBoxDecoration(
            color: AppTheme.accentNeon,
            glowIntensity: 0.5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentNeon.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 48, color: AppTheme.accentNeon),
              ),
              const SizedBox(height: 24),
              Text(
                'CIUDADANO',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.accentNeon,
                      letterSpacing: 3,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  gameState.selectedCategory?.name ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tu palabra es:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                gameState.secretWord ?? '',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Revelación para impostor - muestra alerta roja
  Widget _buildImpostorReveal(GameState gameState) {
    return FadeTransition(
      opacity: _revealAnimation,
      child: ScaleTransition(
        scale: _revealAnimation,
        child: AnimatedBuilder(
          animation: _impostorGlowAnimation,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dangerNeon, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.dangerNeon.withValues(
                      alpha: _impostorGlowAnimation.value,
                    ),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícono de silencio animado
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: (1 - value) * 0.5,
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.dangerNeon.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.priority_high,
                              size: 56,
                              color: AppTheme.dangerNeon,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [AppTheme.dangerNeon, AppTheme.secondaryNeon],
                    ).createShader(bounds),
                    child: Text(
                      '¡IMPOSTOR!',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ícono de silencio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.volume_off,
                        color: AppTheme.dangerNeon.withValues(alpha: 0.7),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Shhh...',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: AppTheme.dangerNeon.withValues(alpha: 0.7),
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Pista de categoría (opcional)
                  if (gameState.impostorSeesCategory) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warningNeon.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.warningNeon.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.warningNeon,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Categoría: ${gameState.selectedCategory?.name ?? ""}',
                            style: TextStyle(
                              color: AppTheme.warningNeon,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      'No tienes ninguna pista',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Text(
                    'Intenta descubrir la palabra secreta\nsin que te descubran',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
