import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/widgets.dart';

/// Pantalla de resultados finales
///
/// Muestra:
/// - La palabra secreta
/// - Quiénes eran los impostores
/// - Quiénes eran los ciudadanos
/// - Opciones para nueva partida
class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _revealController;
  late AnimationController _confettiController;
  late Animation<double> _revealAnimation;
  bool _showRoles = false;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.elasticOut,
    );

    // Iniciar animación de revelación después de un delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _revealController.forward();
      _triggerVibration();
    });
  }

  Future<void> _triggerVibration() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 500);
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _revealRoles() {
    setState(() => _showRoles = true);
    HapticFeedback.heavyImpact();
    _confettiController.forward();
  }

  void _newRound() {
    ref.read(gameStateProvider.notifier).newRound();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _newGame() {
    ref.read(gameStateProvider.notifier).resetGame();
    ref.read(categoriesProvider.notifier).deselectAll();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                _buildHeader(),

                const SizedBox(height: 32),

                // Palabra secreta
                _buildSecretWordReveal(gameState),

                const SizedBox(height: 32),

                // Botón revelar roles (si aún no se muestran)
                if (!_showRoles)
                  NeonButton(
                    text: 'REVELAR ROLES',
                    icon: Icons.visibility,
                    color: AppTheme.secondaryNeon,
                    expanded: true,
                    onPressed: _revealRoles,
                  )
                else ...[
                  // Lista de impostores
                  _buildRoleSection(
                    title: 'IMPOSTORES',
                    players: gameState.impostors,
                    color: AppTheme.dangerNeon,
                    icon: Icons.visibility_off,
                  ),

                  const SizedBox(height: 24),

                  // Lista de ciudadanos
                  _buildRoleSection(
                    title: 'CIUDADANOS',
                    players: gameState.citizens,
                    color: AppTheme.accentNeon,
                    icon: Icons.person,
                  ),
                ],

                const SizedBox(height: 40),

                // Botones de acción
                _buildActionButtons(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [AppTheme.primaryNeon, AppTheme.secondaryNeon],
          ).createShader(bounds),
          child: Text(
            'RESULTADOS',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  letterSpacing: 4,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '¡La partida ha terminado!',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSecretWordReveal(GameState gameState) {
    return ScaleTransition(
      scale: _revealAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: AppTheme.neonBoxDecoration(
          color: AppTheme.primaryNeon,
          glowIntensity: 0.4,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryNeon.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                gameState.selectedCategory?.icon ?? Icons.help,
                size: 48,
                color: AppTheme.primaryNeon,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'La palabra secreta era:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              gameState.secretWord ?? '',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.primaryNeon,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.secondaryNeon.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.secondaryNeon.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'Categoría: ${gameState.selectedCategory?.name ?? ""}',
                style: TextStyle(
                  color: AppTheme.secondaryNeon,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSection({
    required String title,
    required List<Player> players,
    required Color color,
    required IconData icon,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _showRoles ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        offset: _showRoles ? Offset.zero : const Offset(0, 0.2),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.neonBoxDecoration(
            color: color,
            glowIntensity: 0.3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          letterSpacing: 2,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${players.length}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: players.map((player) {
                  return _buildPlayerChip(player, color);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerChip(Player player, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: player.isEliminated
            ? AppTheme.surfaceDark
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: player.isEliminated
              ? AppTheme.textMuted
              : color.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            player.isEliminated ? Icons.close : Icons.person,
            size: 16,
            color: player.isEliminated ? AppTheme.textMuted : color,
          ),
          const SizedBox(width: 8),
          Text(
            player.name,
            style: TextStyle(
              color: player.isEliminated ? AppTheme.textMuted : color,
              fontWeight: FontWeight.w500,
              decoration:
                  player.isEliminated ? TextDecoration.lineThrough : null,
            ),
          ),
          if (player.isEliminated) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.dangerNeon.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'OUT',
                style: TextStyle(
                  color: AppTheme.dangerNeon,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        NeonButton(
          text: 'NUEVA RONDA',
          icon: Icons.refresh,
          color: AppTheme.accentNeon,
          expanded: true,
          onPressed: _newRound,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _newGame,
          icon: const Icon(Icons.home),
          label: const Text('Nuevo juego'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.textSecondary,
            side: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            minimumSize: const Size(double.infinity, 0),
          ),
        ),
      ],
    );
  }
}
