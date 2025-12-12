import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/player.dart';
import '../../core/providers/game_provider.dart';
import '../../core/theme/app_theme.dart';

/// Pantalla de votación simple
///
/// Permite a los jugadores votar por quien creen que es el impostor
/// en cada ronda hasta descubrirlo
class VotingScreen extends ConsumerStatefulWidget {
  const VotingScreen({super.key});

  @override
  ConsumerState<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends ConsumerState<VotingScreen> {
  Player? _selectedPlayer;
  int _currentRound = 1;
  final Set<String> _eliminatedPlayerIds = {};

  void _vote() async {
    if (_selectedPlayer == null) return;

    final votedPlayer = _selectedPlayer!;

    final isImpostor = votedPlayer.isImpostor;
    if (isImpostor) {
      HapticFeedback.heavyImpact();
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 500);
      }

      if (mounted) {
        _showVictoryDialog(votedPlayer.name);
      }
    } else {
      setState(() {
        _eliminatedPlayerIds.add(votedPlayer.id);
        _selectedPlayer = null;
        _currentRound++;
      });

      HapticFeedback.mediumImpact();

      final gameState = ref.read(gameStateProvider);
      final remainingPlayers = gameState.players
          .where((p) => !_eliminatedPlayerIds.contains(p.id))
          .toList();

      if (remainingPlayers.length <= 2) {
        final impostor = remainingPlayers.firstWhere((p) => p.isImpostor);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showDefeatDialog(impostor.name);
          }
        });
      }
    }
  }

  void _showDefeatDialog(String impostorName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.backgroundIndigo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppTheme.dangerNeon,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.dangerNeon.withValues(alpha: 0.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.dangerNeon.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppTheme.dangerNeon,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),

              // Título
              Text(
                '¡GANÓ EL IMPOSTOR!',
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.dangerNeon,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              // Nombre del impostor
              Text(
                impostorName,
                style: GoogleFonts.rajdhani(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.dangerNeon,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'era el impostor',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),

              // Botón volver a jugar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(gameStateProvider.notifier).resetGame();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.dangerNeon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.replay_rounded, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'VOLVER A JUGAR',
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVictoryDialog(String impostorName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.backgroundIndigo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppTheme.accentNeon,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono de éxito
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentNeon.withValues(alpha: 0.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentNeon.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.accentNeon,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),

              // Título
              Text(
                '¡IMPOSTOR DESCUBIERTO!',
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentNeon,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              // Nombre del impostor
              Text(
                impostorName,
                style: GoogleFonts.rajdhani(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.dangerNeon,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'era el impostor',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),

              // Botón volver a jugar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(gameStateProvider.notifier).resetGame();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
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
                      const Icon(Icons.replay_rounded, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'VOLVER A JUGAR',
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final activePlayers = gameState.players
        .where((player) => !_eliminatedPlayerIds.contains(player.id))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundIndigo,
      body: Container(
        color: AppTheme.backgroundIndigo,
        child: SafeArea(
          child: Column(
            children: [
              // Header con ronda
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'RONDA $_currentRound',
                      style: GoogleFonts.orbitron(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNeon,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '¿Quién es el impostor?',
                      style: GoogleFonts.rajdhani(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de jugadores activos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: activePlayers.length,
                  itemBuilder: (context, index) {
                    final player = activePlayers[index];
                    final isSelected = _selectedPlayer == player;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPlayer = player;
                          });
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.dangerNeon.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.dangerNeon
                                  : Colors.white.withValues(alpha: 0.1),
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.dangerNeon
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.dangerNeon
                                      : AppTheme.primaryNeon
                                          .withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: isSelected
                                      ? AppTheme.backgroundIndigo
                                      : AppTheme.primaryNeon,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Nombre
                              Expanded(
                                child: Text(
                                  player.name,
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppTheme.dangerNeon
                                        : Colors.white,
                                  ),
                                ),
                              ),

                              // Radio indicator
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.dangerNeon
                                        : Colors.white.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? AppTheme.dangerNeon
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: AppTheme.backgroundIndigo,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Botón votar
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedPlayer != null ? _vote : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.dangerNeon,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          Colors.white.withValues(alpha: 0.1),
                      disabledForegroundColor:
                          Colors.white.withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.how_to_vote_rounded, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'VOTAR',
                          style: GoogleFonts.orbitron(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 16,
                          ),
                        ),
                      ],
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
}
