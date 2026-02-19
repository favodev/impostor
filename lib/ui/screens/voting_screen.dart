import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/player.dart';
import '../../core/providers/game_provider.dart';
import '../../core/theme/app_theme.dart';

class VotingScreen extends ConsumerStatefulWidget {
  const VotingScreen({super.key});

  @override
  ConsumerState<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends ConsumerState<VotingScreen> {
  Player? _selectedPlayer;
  int _currentRound = 1;
  Timer? _gameTimer;
  int? _remainingSeconds;
  bool _timeoutHandled = false;
  bool _didAlert45Seconds = false;

  @override
  void initState() {
    super.initState();
    _initializeGameTimer();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _initializeGameTimer() {
    final timerMinutes = ref.read(gameStateProvider).timerDuration;
    if (timerMinutes == null) return;

    _remainingSeconds = timerMinutes * 60;
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _timeoutHandled) {
        timer.cancel();
        return;
      }

      final currentSeconds = _remainingSeconds;
      if (currentSeconds == null) {
        timer.cancel();
        return;
      }

      if (currentSeconds == 45 && !_didAlert45Seconds) {
        _didAlert45Seconds = true;
        _triggerShortTimeWarning();
      }

      if (currentSeconds <= 1) {
        setState(() {
          _remainingSeconds = 0;
        });
        timer.cancel();
        _handleTimeout();
        return;
      }

      setState(() {
        _remainingSeconds = currentSeconds - 1;
      });
    });
  }

  Future<void> _triggerShortTimeWarning() async {
    HapticFeedback.lightImpact();

    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 120);
    }
  }

  void _handleTimeout() {
    if (_timeoutHandled) return;
    _timeoutHandled = true;

    final activeImpostors = ref
        .read(gameStateProvider)
        .activePlayers
        .where((player) => player.isImpostor)
        .map((player) => player.name)
        .join(', ');

    final impostorNames = activeImpostors.isEmpty
        ? ref.read(gameStateProvider).impostors.map((player) => player.name).join(', ')
        : activeImpostors;

    _showTimeoutDialog(impostorNames);
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _vote() async {
    if (_selectedPlayer == null) return;

    final votedPlayer = _selectedPlayer!;
    ref.read(gameStateProvider.notifier).eliminatePlayer(votedPlayer.id);
    final updatedState = ref.read(gameStateProvider);
    final remainingPlayers = updatedState.activePlayers;
    final remainingImpostors =
        remainingPlayers.where((player) => player.isImpostor).toList();
    final remainingCitizens =
        remainingPlayers.where((player) => !player.isImpostor).toList();

    final isImpostor = votedPlayer.isImpostor;
    if (isImpostor) {
      HapticFeedback.heavyImpact();
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 500);
      }

      if (!mounted) return;

      if (remainingImpostors.isEmpty) {
        final allImpostors = updatedState.impostors.map((p) => p.name).join(', ');
        _showVictoryDialog(allImpostors);
      } else {
        _showImpostorFoundDialog(votedPlayer.name, remainingImpostors.length);
      }
    } else {
      setState(() {
        _selectedPlayer = null;
        _currentRound++;
      });

      HapticFeedback.mediumImpact();

      final shouldEndByImpostorWin =
          remainingCitizens.isEmpty ||
          (remainingImpostors.length == 1 && remainingCitizens.length == 1);

      if (shouldEndByImpostorWin) {
        final impostorNames = remainingImpostors.map((p) => p.name).join(', ');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showDefeatDialog(impostorNames);
          }
        });
      }
    }
  }

  void _showImpostorFoundDialog(String impostorName, int remainingImpostors) {
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
              Icon(
                Icons.search_rounded,
                size: 64,
                color: AppTheme.accentNeon,
              ),
              const SizedBox(height: 20),
              Text(
                '¡IMPOSTOR DESCUBIERTO!',
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentNeon,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 14),
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
                remainingImpostors == 1
                    ? 'Queda 1 impostor por encontrar'
                    : 'Quedan $remainingImpostors impostores por encontrar',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedPlayer = null;
                      _currentRound++;
                    });
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
                  child: Text(
                    'SEGUIR VOTANDO',
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 14,
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

  void _showTimeoutDialog(String impostorNames) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.backgroundIndigo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppTheme.warningNeon,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_off_rounded,
                color: AppTheme.warningNeon,
                size: 64,
              ),
              const SizedBox(height: 22),
              Text(
                '¡SE ACABÓ EL TIEMPO!',
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.warningNeon,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Los impostores ganan esta partida.',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                impostorNames,
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  fontSize: 18,
                  color: AppTheme.dangerNeon,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _gameTimer?.cancel();
                    ref.read(gameStateProvider.notifier).resetGame();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warningNeon,
                    foregroundColor: AppTheme.backgroundIndigo,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'VOLVER A JUGAR',
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 14,
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

  void _showDefeatDialog(String impostorNames) {
    _timeoutHandled = true;
    _gameTimer?.cancel();

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
              Text(
                impostorNames,
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(gameStateProvider.notifier).resetGame();
                    Navigator.of(context).popUntil((route) => route.isFirst);
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

  void _showVictoryDialog(String impostorNames) {
    _timeoutHandled = true;
    _gameTimer?.cancel();

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
              Text(
                impostorNames,
                style: GoogleFonts.rajdhani(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.dangerNeon,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'eran los impostores',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(gameStateProvider.notifier).resetGame();
                    Navigator.of(context).popUntil((route) => route.isFirst);
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
    final activePlayers = gameState.activePlayers;

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
                      'RONDA $_currentRound',
                      style: GoogleFonts.orbitron(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNeon,
                        letterSpacing: 3,
                      ),
                    ),
                    if (_remainingSeconds != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentNeon.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppTheme.accentNeon.withValues(alpha: 0.55),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_rounded,
                              size: 18,
                              color: AppTheme.accentNeon,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(_remainingSeconds!),
                              style: GoogleFonts.orbitron(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentNeon,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
