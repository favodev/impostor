import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'results_screen.dart';

/// Pantalla de debate y votación
///
/// Implementa:
/// - Timer opcional para el debate
/// - Lista de jugadores con estado (eliminado/activo)
/// - Gestión de eliminaciones durante votación
/// - Botón para revelar identidades al final
class DebateScreen extends ConsumerStatefulWidget {
  const DebateScreen({super.key});

  @override
  ConsumerState<DebateScreen> createState() => _DebateScreenState();
}

class _DebateScreenState extends ConsumerState<DebateScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _timerRunning = false;
  bool _showTimerSetup = true;
  int _selectedMinutes = 3;

  late AnimationController _timerAnimationController;

  @override
  void initState() {
    super.initState();
    _timerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerAnimationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds = _selectedMinutes * 60;
      _timerRunning = true;
      _showTimerSetup = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Verificar si el widget sigue montado para evitar fugas de memoria
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);

        // Vibración en últimos 10 segundos
        if (_remainingSeconds <= 10 && _remainingSeconds > 0) {
          HapticFeedback.lightImpact();
        }
      } else {
        _timer?.cancel();
        setState(() => _timerRunning = false);
        HapticFeedback.heavyImpact();
        _showTimeUpDialog();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _timerRunning = false);
  }

  void _resumeTimer() {
    if (_remainingSeconds > 0) {
      _startTimer();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _timerRunning = false;
      _showTimerSetup = true;
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.dangerNeon, width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.timer_off, color: AppTheme.dangerNeon),
            const SizedBox(width: 12),
            const Text(
              '¡TIEMPO!',
              style: TextStyle(color: AppTheme.dangerNeon),
            ),
          ],
        ),
        content: const Text('El tiempo de debate ha terminado.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text('Más tiempo'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerNeon,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _togglePlayerElimination(String playerId) {
    final player =
        ref.read(gameStateProvider).players.firstWhere((p) => p.id == playerId);

    if (player.isEliminated) {
      ref.read(gameStateProvider.notifier).restorePlayer(playerId);
    } else {
      ref.read(gameStateProvider.notifier).eliminatePlayer(playerId);
    }
    HapticFeedback.mediumImpact();
  }

  void _showRevealConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppTheme.secondaryNeon.withValues(alpha: 0.5),
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.visibility, color: AppTheme.secondaryNeon),
            const SizedBox(width: 12),
            const Text('Revelar identidades'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que quieres revelar las identidades de todos los jugadores?\n\nEsto terminará la partida.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _goToResults();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryNeon,
            ),
            child: const Text('Revelar'),
          ),
        ],
      ),
    );
  }

  void _goToResults() {
    ref.read(gameStateProvider.notifier).showResults();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ResultsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(gameState),

              // Timer section
              _buildTimerSection(),

              // Lista de jugadores
              Expanded(child: _buildPlayersList(gameState)),

              // Botones de acción
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'FASE DE DEBATE',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryNeon,
                  letterSpacing: 3,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(
                icon: Icons.category,
                label: gameState.selectedCategory?.name ?? '',
                color: AppTheme.secondaryNeon,
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                icon: Icons.visibility_off,
                label:
                    '${gameState.impostorCount} impostor${gameState.impostorCount > 1 ? "es" : ""}',
                color: AppTheme.dangerNeon,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    if (_showTimerSetup) {
      return _buildTimerSetup();
    }
    return _buildActiveTimer();
  }

  Widget _buildTimerSetup() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.neonBoxDecoration(
        color: AppTheme.warningNeon,
        glowIntensity: 0.2,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer, color: AppTheme.warningNeon),
              const SizedBox(width: 8),
              const Text(
                'Timer de debate',
                style: TextStyle(
                  color: AppTheme.warningNeon,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '(Opcional)',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1, 2, 3, 5, 10].map((minutes) {
              final isSelected = _selectedMinutes == minutes;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedMinutes = minutes);
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.warningNeon.withValues(alpha: 0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.warningNeon
                          : AppTheme.warningNeon.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    '${minutes}m',
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.warningNeon
                          : AppTheme.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _showTimerSetup = false);
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Sin timer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: BorderSide(
                      color: AppTheme.textMuted.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _startTimer,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Iniciar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warningNeon,
                    foregroundColor: AppTheme.backgroundDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTimer() {
    final progress = _remainingSeconds > 0
        ? _remainingSeconds / (_selectedMinutes * 60)
        : 0.0;

    final isLowTime = _remainingSeconds <= 30;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.neonBoxDecoration(
        color: isLowTime ? AppTheme.dangerNeon : AppTheme.warningNeon,
        glowIntensity: isLowTime ? 0.4 : 0.2,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _timerRunning ? Icons.timer : Icons.pause,
                color: isLowTime ? AppTheme.dangerNeon : AppTheme.warningNeon,
              ),
              const SizedBox(width: 12),
              Text(
                _formatTime(_remainingSeconds),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: isLowTime
                          ? AppTheme.dangerNeon
                          : AppTheme.warningNeon,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.surfaceDark,
              valueColor: AlwaysStoppedAnimation(
                isLowTime ? AppTheme.dangerNeon : AppTheme.warningNeon,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _timerRunning ? _pauseTimer : _resumeTimer,
                icon: Icon(
                  _timerRunning ? Icons.pause : Icons.play_arrow,
                  color: AppTheme.primaryNeon,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryNeon.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.surfaceDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersList(GameState gameState) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: gameState.players.length,
      itemBuilder: (context, index) {
        final player = gameState.players[index];
        return _buildPlayerTile(player);
      },
    );
  }

  Widget _buildPlayerTile(Player player) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _togglePlayerElimination(player.id),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: player.isEliminated
                  ? AppTheme.dangerNeon.withValues(alpha: 0.1)
                  : AppTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: player.isEliminated
                    ? AppTheme.dangerNeon
                    : AppTheme.primaryNeon.withValues(alpha: 0.2),
                width: player.isEliminated ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: player.isEliminated
                        ? AppTheme.dangerNeon.withValues(alpha: 0.2)
                        : AppTheme.primaryNeon.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      player.isEliminated ? Icons.close : Icons.person,
                      color: player.isEliminated
                          ? AppTheme.dangerNeon
                          : AppTheme.primaryNeon,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    player.name,
                    style: TextStyle(
                      color: player.isEliminated
                          ? AppTheme.textMuted
                          : AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: player.isEliminated
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: player.isEliminated
                      ? Container(
                          key: const ValueKey('eliminated'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.dangerNeon.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ELIMINADO',
                            style: TextStyle(
                              color: AppTheme.dangerNeon,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Icon(
                          key: const ValueKey('active'),
                          Icons.radio_button_unchecked,
                          color: AppTheme.textMuted,
                          size: 20,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppTheme.backgroundDark.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showNewRoundConfirmation,
              icon: const Icon(Icons.refresh),
              label: const Text('Nueva ronda'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: BorderSide(
                  color: AppTheme.textMuted.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: NeonButton(
              text: 'REVELAR TODOS',
              icon: Icons.visibility,
              color: AppTheme.secondaryNeon,
              onPressed: _showRevealConfirmation,
            ),
          ),
        ],
      ),
    );
  }

  void _showNewRoundConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.refresh, color: AppTheme.primaryNeon),
            SizedBox(width: 12),
            Text('Nueva ronda'),
          ],
        ),
        content: const Text(
          '¿Quieres iniciar una nueva ronda con los mismos jugadores y categorías?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(gameStateProvider.notifier).newRound();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Nueva ronda'),
          ),
        ],
      ),
    );
  }
}
