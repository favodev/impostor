import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/game_provider.dart';
import '../../core/theme/app_theme.dart';
import 'voting_screen.dart';

class StartingPlayerScreen extends ConsumerStatefulWidget {
  const StartingPlayerScreen({super.key});

  @override
  ConsumerState<StartingPlayerScreen> createState() =>
      _StartingPlayerScreenState();
}

class _StartingPlayerScreenState extends ConsumerState<StartingPlayerScreen> {
  static final Random _random = Random.secure();
  String? _startingPlayerName;

  @override
  void initState() {
    super.initState();
    final players = ref.read(gameStateProvider).players;
    if (players.isNotEmpty) {
      _startingPlayerName = players[_random.nextInt(players.length)].name;
    }
  }

  void _goToVoting() {
    HapticFeedback.mediumImpact();
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
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundIndigo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.campaign_rounded,
                size: 70,
                color: AppTheme.primaryNeon,
              ),
              const SizedBox(height: 24),
              Text(
                '¿QUIÉN EMPIEZA?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryNeon,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.secondaryNeon.withValues(alpha: 0.45),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _startingPlayerName ?? 'Jugador aleatorio',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.secondaryNeon,
                            fontWeight: FontWeight.w900,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'empieza diciendo una pista',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToVoting,
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
                      const Icon(Icons.how_to_vote_rounded, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'IR A VOTACIÓN',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: AppTheme.backgroundIndigo,
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
}
