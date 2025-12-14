import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import '../../core/models/game_state.dart';
import '../../core/models/player.dart';
import '../../core/providers/game_provider.dart';
import '../../core/theme/app_theme.dart';
import 'voting_screen.dart';

class RoleRevealScreen extends ConsumerStatefulWidget {
  const RoleRevealScreen({super.key});

  @override
  ConsumerState<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends ConsumerState<RoleRevealScreen>
    with TickerProviderStateMixin {
  bool _isRevealing = false;
  bool _isTransitioning = false;

  late AnimationController _revealController;
  late AnimationController _impostorGlowController;

  late Animation<double> _revealAnimation;
  late Animation<double> _impostorGlowAnimation;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    );

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
    _revealController.dispose();
    _impostorGlowController.dispose();
    super.dispose();
  }

  Future<void> _toggleReveal() async {
    if (_isRevealing) return;

    setState(() => _isRevealing = true);
    _revealController.forward();

    final currentPlayer = ref.read(gameStateProvider).currentPlayer;

    if (currentPlayer?.isImpostor ?? false) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 200]);
      }
    } else {
      HapticFeedback.mediumImpact();
    }

    ref.read(gameStateProvider.notifier).currentPlayerSawRole();
  }

  void _nextPlayer() async {
    final gameState = ref.read(gameStateProvider);

    if (gameState.currentPlayerIndex < gameState.players.length - 1) {
      setState(() => _isTransitioning = true);

      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      ref.read(gameStateProvider.notifier).nextPlayer();

      _revealController.reset();
      setState(() {
        _isRevealing = false;
        _isTransitioning = false;
      });
      HapticFeedback.lightImpact();
    } else {
      ref.read(gameStateProvider.notifier).nextPlayer();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const VotingScreen(),
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
      backgroundColor: AppTheme.backgroundIndigo,
      body: Container(
        color: AppTheme.backgroundIndigo,
        child: SafeArea(
          child: Column(
            children: [
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
                    Text(
                      '${gameState.currentPlayerIndex + 1} / ${gameState.players.length}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isTransitioning
                        ? _buildTransitionState()
                        : _isRevealing
                            ? _buildRoleReveal(currentPlayer, gameState)
                            : _buildWaitingState(currentPlayer),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: _isRevealing
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _nextPlayer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentNeon,
                            foregroundColor: AppTheme.backgroundIndigo,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                gameState.currentPlayerIndex <
                                        gameState.players.length - 1
                                    ? 'SIGUIENTE'
                                    : 'JUGAR',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                gameState.currentPlayerIndex <
                                        gameState.players.length - 1
                                    ? Icons.arrow_forward_rounded
                                    : Icons.play_arrow_rounded,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(height: 66),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildWaitingState(Player player) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
        GestureDetector(
          onTap: _toggleReveal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryNeon.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryNeon,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryNeon.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_rounded,
                  color: AppTheme.primaryNeon,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'VER MI PALABRA',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryNeon,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
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

  Widget _buildRoleReveal(Player player, GameState gameState) {
    if (player.isImpostor) {
      return _buildImpostorReveal(gameState);
    } else {
      return _buildCitizenReveal(gameState);
    }
  }

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
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentNeon.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentNeon.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      gameState.selectedCategory?.icon ?? Icons.category,
                      color: AppTheme.accentNeon,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      gameState.selectedCategory?.name ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.accentNeon,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                  if (gameState.impostorSeesHint) ...[
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
                            'Pista: ${gameState.secretHint ?? ""}',
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
